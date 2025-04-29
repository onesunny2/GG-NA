//
//  ShareDefaultsManager.swift
//  GGNA
//
//  Created by Lee Wonsun on 4/24/25.
//

import UIKit
import RealmSwift

/*
 < 위젯과 공유해야 하는 내용 >
 1. 사용자가 저장한 folder 이름
 2. 각 folder에 저장된 사진 사진 + 필터정보 + 타이틀 가져오기
 3. 구조체로 저장해서 변환해서 전달하면 -> 위젯 쪽에서 AppEntity에 맞게 가공
 */

struct ShareWithWidget {
    let id = UUID()
    let folder: String
    let photoInfo: [SharePhoto]
}

struct SharePhoto {
    let imageName: String
    let filter: Filter
    let filterValue: Double
    let title: String
}

final class ShareDefaultsManager {
    static let shared = ShareDefaultsManager()
    private init() { }
    
    static let encoder = JSONEncoder()
    static let decoder = JSONDecoder()
    
    // Realm를 통해 [ShareWithWidget] 변환
    func getFolderInfo() -> [ShareWithWidget] {
        
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
