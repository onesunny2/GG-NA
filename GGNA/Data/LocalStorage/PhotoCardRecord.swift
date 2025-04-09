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
    @Persisted var imageName: String
    @Persisted var imageScale: Bool
    @Persisted var videoData: Data?
    @Persisted var filter: String
    @Persisted var filterValue: Double
    @Persisted var isSelectedMain: Bool
    @Persisted var cardContent: CardContent?
    
    // 부모폴더 역참조
    @Persisted(originProperty: "photoCards") var parentFolder: LinkingObjects<Folder>
    
    convenience init(
        imageScale: Bool,
        videoData: Data,
        filter: String,
        filterValue: Double,
        isSelectedMain: Bool,
        cardContent: CardContent
    ) {
        self.init()
        self.imageName = self.id.stringValue
        self.imageScale = imageScale
        self.videoData = videoData
        self.filter = filter
        self.filterValue = filterValue
        self.isSelectedMain = isSelectedMain
        self.cardContent = cardContent
    }
}

