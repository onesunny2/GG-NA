//
//  Folder.swift
//  GGNA
//
//  Created by Lee Wonsun on 4/1/25.
//

import Foundation
import RealmSwift

final class Folder: Object, Identifiable {
    @Persisted(primaryKey: true) var id: ObjectId
    @Persisted var folderName: String
    @Persisted var bgm: String?
    @Persisted var photoCards: List<PhotoCardRecord>
    
    convenience init(
        folderName: String,
        bgm: String? = nil,
        photoCards: List<PhotoCardRecord>
    ) {
        self.init()
        self.folderName = folderName
        self.bgm = bgm
        self.photoCards = photoCards
    }
}
