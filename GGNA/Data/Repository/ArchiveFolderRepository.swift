//
//  ArchiveFolderRepository.swift
//  GGNA
//
//  Created by Lee Wonsun on 4/1/25.
//

import UIKit
import RealmSwift

protocol ArchiveFolderRepository: AnyObject {
    func getFolderInfo() -> [ArchiveFolderEntity]
    func getPhotosFromFolder(folderName: String) -> [FolderPhotosEntity]
}

final class DefaultArchiveFolderRepository: ArchiveFolderRepository {
    
    func getFolderInfo() -> [ArchiveFolderEntity] {
        
        let theme = CurrentTheme.currentTheme.theme
        let color = CurrentTheme.currentTheme.color
        let image = color.replaceMainImage(for: theme)
        
        let realm = try! Realm()
        let folders = Array(realm.objects(Folder.self))
        
        var entities: [ArchiveFolderEntity] = []
        
        folders.forEach {
            
            let mainCard = Array($0.photoCards.filter { $0.isSelectedMain == true }).first
            
            guard let mainCard else {
                
                switch $0.photoCards.count {
                case 0:
                    let value = ArchiveFolderEntity(
                        folderName: $0.folderName,
                        createDate: $0.createFolderDate,
                        photoCount: "+" + $0.photoCards.count.formatted(),
                        mainImage: loadImageFromDocument(foldername: $0.folderName, fileName: mainCard?.imageName ?? "") ?? (image ?? UIImage(resource: .defaultDarkPink))
                    )
                    
                    entities.append(value)
                    
                default:  // MARK: 사진은 있는데 메인으로 지정한 사진이 없을 때 (가장 처음 사진으로)
                    
                    let recent = $0.photoCards.sorted { $0.cardContent?.createDate ?? Date() < $1.cardContent?.createDate ?? Date() }.first!
                    
                    let value = ArchiveFolderEntity(
                        folderName: $0.folderName,
                        createDate: $0.createFolderDate,
                        photoCount: "+" + $0.photoCards.count.formatted(),
                        mainImage: loadImageFromDocument(foldername: $0.folderName, fileName: recent.imageName) ?? (image ?? UIImage(resource: .defaultDarkPink))
                    )
                    
                    entities.append(value)
                }

                return
            }
            
            let value = ArchiveFolderEntity(
                folderName: $0.folderName,
                createDate: $0.createFolderDate,
                photoCount: "+" + $0.photoCards.count.formatted(),
                mainImage: loadImageFromDocument(foldername: $0.folderName, fileName: mainCard.imageName) ?? UIImage()
            )
            
            entities.append(value)
        }
        
        entities.sort { $0.createDate < $1.createDate }
        
        return entities
    }
    
    func getPhotosFromFolder(folderName: String) -> [FolderPhotosEntity] {
        
        let theme = CurrentTheme.currentTheme.theme
        let color = CurrentTheme.currentTheme.color
        let image = color.replaceMainImage(for: theme)
        
        let realm = try! Realm()
        
        guard let folder = realm.objects(Folder.self).where({ $0.folderName == folderName }).first else { return [] }
        let photos = folder.photoCards
        
        var entities: [FolderPhotosEntity] = []
        
        photos.forEach {
            
            let result = FolderPhotosEntity(
                image: loadImageFromDocument(foldername: folderName, fileName: $0.imageName) ?? (image ?? UIImage(resource: .defaultDarkPink)),
                isSelectedMain: $0.isSelectedMain,
                title: $0.cardContent?.title ?? "",
                date: $0.cardContent?.date ?? "",
                createDate: $0.cardContent?.createDate ?? Date(),
                secretMode: $0.cardContent?.secretMode ?? false
            )
            
            entities.append(result)
        }
        
        entities.sort { $0.createDate < $1.createDate }
        
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

final class DummyArchiveFolderRepository: ArchiveFolderRepository {
    
    func getFolderInfo() -> [ArchiveFolderEntity] {
        
        return [
//            ArchiveFolderEntity(folderName: "타이틀1입니다", photoCount: "+10,000", mainImage: UIImage(named: "gg2")!),
//            ArchiveFolderEntity(folderName: "타이틀2졸려요", photoCount: "+11,111", mainImage: UIImage(named: "gg3")!),
//            ArchiveFolderEntity(folderName: "타이틀3히히", photoCount: "+12,222", mainImage: UIImage(named: "gg4")!),
//            ArchiveFolderEntity(folderName: "타이틀4얍", photoCount: "+13", mainImage: UIImage(named: "gg5")!),
//            ArchiveFolderEntity(folderName: "타이틀5", photoCount: "+14", mainImage: UIImage(named: "gg6")!),
//            ArchiveFolderEntity(folderName: "타이틀6", photoCount: "+15", mainImage: UIImage(named: "gg1")!)
        ]
    }
    
    func getPhotosFromFolder(folderName: String) -> [FolderPhotosEntity] {
        return [
//            FolderPhotosEntity(image: UIImage(named: "gg1")!, isSelectedMain: false, title: "잠이 온다1", date: "2025.04.01 화요일", secretMode: false),
//            FolderPhotosEntity(image: UIImage(named: "gg2")!, isSelectedMain: false, title: "잠이 온다2", date: "2025.04.02 수요일", secretMode: true),
//            FolderPhotosEntity(image: UIImage(named: "gg3")!, isSelectedMain: false, title: "잠이 온다3", date: "2025.04.03 목요일", secretMode: true),
//            FolderPhotosEntity(image: UIImage(named: "gg4")!, isSelectedMain: false, title: "잠이 온다4", date: "2025.04.04 금요일", secretMode: false),
//            FolderPhotosEntity(image: UIImage(named: "gg5")!, isSelectedMain: false, title: "잠이 온다5", date: "2025.04.05 토요일", secretMode: false),
//            FolderPhotosEntity(image: UIImage(named: "gg6")!, isSelectedMain: false, title: "잠이 온다6", date: "2025.04.06 일요일", secretMode: true)
        ]
    }
}
