//
//  HomePhotoRepository.swift
//  GGNA
//
//  Created by Lee Wonsun on 3/30/25.
//

import UIKit
import RealmSwift

protocol HomePhotoRepository: AnyObject {
    func getFolders() -> [HomeFolderEntity]
    func getPhotosFromFolder(folderName: String) -> [HomePhotoCardEntity]
}

final class DefaultHomePhotoRepository: HomePhotoRepository {
    
    func getFolders() -> [HomeFolderEntity] {
        
        let realm = try! Realm()
        let folderData = Array(realm.objects(Folder.self))
        
        var result: [HomeFolderEntity] = []
        
        for folder in folderData {
            
            let value = HomeFolderEntity(
                folderName: folder.folderName,
                createDate: folder.createFolderDate
            )
            
            result.append(value)
        }
        
        result.sort { $0.createDate < $1.createDate }
        
        return result
    }
    
    func getPhotosFromFolder(folderName: String) -> [HomePhotoCardEntity] {
        
        let theme = CurrentTheme.currentTheme.theme
        let color = CurrentTheme.currentTheme.color
        let image = color.replaceMainImage(for: theme)
        
        let realm = try! Realm()
        let data = realm.objects(Folder.self).filter { $0.folderName == folderName }
        
        guard let folder = data.first else { return [] }
        
        let photos = Array(folder.photoCards)
        var entities: [HomePhotoCardEntity] = []
        var mainImage: [HomePhotoCardEntity] = []
        
        for element in photos {
            
            let result = HomePhotoCardEntity(
                imageData: loadImageFromDocument(foldername: folderName, fileName: element.imageName),
                videoData: Data(),
                filter: Filter.original.type,
                isSelectedMain: element.isSelectedMain,
                createDate: element.cardContent?.createDate ?? Date(),
                cardTitle: element.cardContent?.title,
                cardDetail: element.cardContent?.detail,
                cardDate: element.cardContent?.date,
                cardLocation: element.cardContent?.location,
                secretMode: element.cardContent?.secretMode ?? false
            )
            
            if result.isSelectedMain {
                mainImage.append(result)
            } else if !result.secretMode {
                entities.append(result)
            }
        }
        
        entities.sort { $0.createDate < $1.createDate }
        if let main = mainImage.first {
            entities.insert(main, at: 0)
        }
        
        // 폴더 내 모든 사진 삭제 되었을 때 디폴트 이미지
        guard entities.isEmpty else { return entities }
        
        let defaultImg = HomePhotoCardEntity(
            imageData: image,
            videoData: Data(),
            filter: Filter.original.type,
            isSelectedMain: true,
            createDate: Date(),
            cardTitle: "GG.NA",
            cardDetail: "",
            cardDate: "",
            cardLocation: "",
            secretMode: false
        )
        
        return [defaultImg]
    }
    
    func loadImageFromDocument(foldername: String, fileName: String) -> UIImage? {
        
        guard let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return nil
        }
        
        // 폴더 경로
        let folderURL = documentDirectory.appendingPathComponent(foldername)
        
        if !FileManager.default.fileExists(atPath: folderURL.path) {
            print("\(foldername)폴더가 존재하지 않습니다.")
            return nil
        }
        
        let fileURL = folderURL.appendingPathComponent("\(fileName).jpg")
        
        if FileManager.default.fileExists(atPath: fileURL.path) {
            return UIImage(contentsOfFile: fileURL.path)
        } else {
            return nil // TODO: nil 일 때 어떻게 처리할건지도 고민 필요
        }
    }
}

final class DummyHomePhotoRepository: HomePhotoRepository {
    
    func getFolders() -> [HomeFolderEntity] {
        return []
    }
    
    func getPhotosFromFolder(folderName: String) -> [HomePhotoCardEntity] {
        
        return []
    }
}
