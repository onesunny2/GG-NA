//
//  ShareDefaultsManager.swift
//  GGNA
//
//  Created by Lee Wonsun on 4/24/25.
//

import UIKit
import RealmSwift
import WidgetKit

/*
 < 위젯과 공유해야 하는 내용 >
 1. 사용자가 저장한 folder 이름
 2. 각 folder에 저장된 사진 사진 + 필터정보 + 타이틀 가져오기
 3. 구조체로 저장해서 변환해서 전달하면 -> 위젯 쪽에서 AppEntity에 맞게 가공
 */

final class ShareDefaultsManager {
    static let shared = ShareDefaultsManager()
    private init() { }
    
    static let encoder = JSONEncoder()
    static let decoder = JSONDecoder()
    
    // 이미지 공유 컨테이너로 복사하기 (앱이 background or 죽을 때 복사할 예정)
    func copyImagesToShareContainer() {
        guard let sharedContainerUrl = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.ws.ggna.widget") else {
            print("공유 컨테이너 url 호출 오류")
            return
        }
        
        print("기본 공유 컨테이너 URL: \(sharedContainerUrl.path)")
        
        let folderInfo = getFolderInfo()
        
        for info in folderInfo {
            let folderName = info.folder
            
            let sharedFolderUrl = sharedContainerUrl.appendingPathComponent(folderName, isDirectory: true)
            try? FileManager.default.createDirectory(at: sharedFolderUrl, withIntermediateDirectories: true)
            
            for photoInfo in info.photoInfo {
                let imageName = photoInfo.imageName
                
                // 원본
                let appDocumentUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
                let sourceImageUrl = appDocumentUrl.appendingPathComponent(folderName).appendingPathComponent("\(imageName).jpg")
                
                // 공유공간
                let destinationImageUrl = sharedFolderUrl.appendingPathComponent("\(imageName).jpg")
                
                if FileManager.default.fileExists(atPath: destinationImageUrl.path) {
                    try? FileManager.default.removeItem(at: destinationImageUrl)
                }
                
                do {
                     try FileManager.default.copyItem(at: sourceImageUrl, to: destinationImageUrl)
                 } catch {
                     print("이미지 복사 실패: \(folderName)/\(imageName).jpg, 에러: \(error)")
                 }
            }
        }
        
        saveToUserdefaults()
        
        WidgetCenter.shared.reloadAllTimelines()
    }
    
    // userDafaults에 구조체 데이터 저장
    private func saveToUserdefaults() {
        let shareData = getFolderInfo()
        
        do {
            let data = try ShareDefaultsManager.encoder.encode(shareData)
            let userDefaults = UserDefaults.groupShared
            userDefaults.set(data, forKey: "shareFolderInfo")
            userDefaults.synchronize()
        } catch {
            print("shareFolderInfo 인코딩실패: \(error)")
        }
    }
    
    // Realm를 통해 [ShareWithWidget] 변환
    private func getFolderInfo() -> [ShareWithWidget] {
        
        let realm = try! Realm()
        let folders = Array(realm.objects(Folder.self))
        
        var folderInfo: [String: [PhotoCardRecord]] = [:]
        var shareInfo: [ShareWithWidget] = []
        
        folders.forEach {
            folderInfo[$0.folderName] = Array($0.photoCards)
        }
        
        folderInfo.forEach { (key, value) in
            
            let photos = value.compactMap { photo in
                
                if let content = photo.cardContent, !content.secretMode {
                    
                    do {
                        let filterInfo = try ShareDefaultsManager.decoder.decode(FilterInfo.self, from: photo.filterInfo)
                        
                        return SharePhoto(
                            imageName: photo.imageName,
                            filter: filterInfo.filter,
                            filterValue: filterInfo.filterValue,
                            title: photo.cardContent?.title ?? ""
                        )
                        
                    } catch {
                        print("decoding Failed: \(error)")
                        return nil
                    }
                } else { return nil }
            }
            
            let data = ShareWithWidget(
                folder: key,
                photoInfo: photos
            )
            
            shareInfo.append(data)
        }
        
        return shareInfo
    }
}
