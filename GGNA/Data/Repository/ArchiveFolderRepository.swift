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
}

final class DefaultArchiveFolderRepository {
    
}

final class DummyArchiveFolderRepository: ArchiveFolderRepository {
    
    func getFolderInfo() -> [ArchiveFolderEntity] {
        
        return [
            ArchiveFolderEntity(folderName: "타이틀1", photoCount: "+10", mainImage: UIImage(named: "gg2")!),
            ArchiveFolderEntity(folderName: "타이틀2", photoCount: "+11", mainImage: UIImage(named: "gg3")!),
            ArchiveFolderEntity(folderName: "타이틀3", photoCount: "+12", mainImage: UIImage(named: "gg4")!),
            ArchiveFolderEntity(folderName: "타이틀4", photoCount: "+13", mainImage: UIImage(named: "gg5")!),
            ArchiveFolderEntity(folderName: "타이틀5", photoCount: "+14", mainImage: UIImage(named: "gg6")!),
            ArchiveFolderEntity(folderName: "타이틀6", photoCount: "+15", mainImage: UIImage(named: "gg1")!)
        ]
    }
}
