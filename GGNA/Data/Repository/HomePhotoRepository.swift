//
//  HomePhotoRepository.swift
//  GGNA
//
//  Created by Lee Wonsun on 3/30/25.
//

import UIKit
import RealmSwift

protocol HomePhotoRepository: AnyObject {
    func getPhotosFromFolder(folderName: String) -> [HomePhotoCardEntity]
}

final class DefaultHomePhotoRepository: HomePhotoRepository {
    
    func getPhotosFromFolder(folderName: String) -> [HomePhotoCardEntity] {
        
        let realm = try! Realm()
        let data = realm.objects(Folder.self).filter { $0.folderName == folderName }
        
        guard let folder = data.first else { return [] }
        
        let photos = Array(folder.photoCards)
        var entities: [HomePhotoCardEntity] = []
        
        for element in photos {
            
            let result = HomePhotoCardEntity(
                imageData: loadImageFromDocument(foldername: folderName, fileName: element.imageName),
                videoData: Data(),
                filter: Filter.original.name,
                isSelectedMain: element.isSelectedMain,
                cardTitle: element.cardContent?.title,
                cardDetail: element.cardContent?.detail,
                cardDate: element.cardContent?.date,
                cardLocation: element.cardContent?.location,
                secretMode: element.cardContent?.secretMode ?? false
            )
            
            entities.append(result)
        }
        
        return entities
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
    
    func getPhotosFromFolder(folderName: String) -> [HomePhotoCardEntity] {
        
        return [
            HomePhotoCardEntity(imageData: UIImage(named: "gg5"), videoData: Data(), filter: Filter.original.name, isSelectedMain: false, cardTitle: "도레미파솔라시도레미", cardDetail: "cardDetail", cardDate: "2025.03.28", cardLocation: "서울시", secretMode: false),
            HomePhotoCardEntity(imageData: UIImage(named: "gg2"), videoData: Data(), filter: Filter.original.name, isSelectedMain: false, cardTitle: "cardTitle2", cardDetail: "cardDetail", cardDate: "2025.03.28", cardLocation: "서울시", secretMode: false),
            HomePhotoCardEntity(imageData: UIImage(named: "gg3"), videoData: Data(), filter: Filter.original.name, isSelectedMain: false, cardTitle: "cardTitle3", cardDetail: "cardDetail", cardDate: "2025.03.28", cardLocation: "서울시", secretMode: false),
            HomePhotoCardEntity(imageData: UIImage(named: "gg4"), videoData: Data(), filter: Filter.original.name, isSelectedMain: false, cardTitle: "cardTitle4", cardDetail: "cardDetail", cardDate: "2025.03.28", cardLocation: "서울시", secretMode: false),
            HomePhotoCardEntity(imageData: UIImage(named: "gg5"), videoData: Data(), filter: Filter.original.name, isSelectedMain: false, cardTitle: "cardTitle5", cardDetail: "cardDetail", cardDate: "2025.03.28", cardLocation: "서울시", secretMode: false),
            HomePhotoCardEntity(imageData: UIImage(named: "gg6"), videoData: Data(), filter: Filter.original.name, isSelectedMain: false, cardTitle: "cardTitle6", cardDetail: "cardDetail", cardDate: "2025.03.28", cardLocation: "서울시", secretMode: false)
        ]
    }
}
