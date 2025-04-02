//
//  PhotoCardRecord.swift
//  GGNA
//
//  Created by Lee Wonsun on 3/30/25.
//

import Foundation
import RealmSwift

final class PhotoCardRecord: Object, Identifiable {
    @Persisted(primaryKey: true) var id: ObjectId
    @Persisted var imageData: Data?
    @Persisted var videoData: Data?
    @Persisted var filter: String
    @Persisted var isSelectedMain: Bool
    @Persisted var cardContent: CardContent?
    
    // 부모폴더 역참조
    @Persisted(originProperty: "photoCards") var parentFolder: LinkingObjects<Folder>
    
    convenience init(
        imageData: Data,
        videoData: Data,
        filter: String,
        isSelectedMain: Bool,
        cardContent: CardContent
    ) {
        self.init()
        self.imageData = imageData
        self.videoData = videoData
        self.filter = filter
        self.isSelectedMain = isSelectedMain
        self.cardContent = cardContent
    }
}

