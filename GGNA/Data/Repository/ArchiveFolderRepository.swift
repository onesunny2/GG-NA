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
    func getPhotosFromFolder() -> [FolderPhotosEntity]
}

final class DefaultArchiveFolderRepository {
    
}

final class DummyArchiveFolderRepository: ArchiveFolderRepository {
    
    func getFolderInfo() -> [ArchiveFolderEntity] {
        
        return [
            ArchiveFolderEntity(folderName: "타이틀1입니다", photoCount: "+10,000", mainImage: UIImage(named: "gg2")!),
            ArchiveFolderEntity(folderName: "타이틀2졸려요", photoCount: "+11,111", mainImage: UIImage(named: "gg3")!),
            ArchiveFolderEntity(folderName: "타이틀3히히", photoCount: "+12,222", mainImage: UIImage(named: "gg4")!),
            ArchiveFolderEntity(folderName: "타이틀4얍", photoCount: "+13", mainImage: UIImage(named: "gg5")!),
            ArchiveFolderEntity(folderName: "타이틀5", photoCount: "+14", mainImage: UIImage(named: "gg6")!),
            ArchiveFolderEntity(folderName: "타이틀6", photoCount: "+15", mainImage: UIImage(named: "gg1")!)
        ]
    }
    
    func getPhotosFromFolder() -> [FolderPhotosEntity] {
        return [
            FolderPhotosEntity(image: UIImage(named: "gg1")!, isSelectedMain: false, title: "잠이 온다", date: "2025.04.01 화요일", secretMode: false),
            FolderPhotosEntity(image: UIImage(named: "gg2")!, isSelectedMain: false, title: "잠이 온다", date: "2025.04.02 수요일", secretMode: false),
            FolderPhotosEntity(image: UIImage(named: "gg3")!, isSelectedMain: false, title: "잠이 온다", date: "2025.04.03 목요일", secretMode: false),
            FolderPhotosEntity(image: UIImage(named: "gg4")!, isSelectedMain: false, title: "잠이 온다", date: "2025.04.04 금요일", secretMode: false),
            FolderPhotosEntity(image: UIImage(named: "gg5")!, isSelectedMain: false, title: "잠이 온다", date: "2025.04.05 토요일", secretMode: false),
            FolderPhotosEntity(image: UIImage(named: "gg6")!, isSelectedMain: false, title: "잠이 온다", date: "2025.04.06 일요일", secretMode: false)
        ]
    }
}
