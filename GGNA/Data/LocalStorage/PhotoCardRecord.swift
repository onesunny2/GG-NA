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
    @Persisted var filterInfo: Data
    @Persisted var isSelectedMain: Bool
    @Persisted var cardContent: CardContent?
    
    // 부모폴더 역참조
    @Persisted(originProperty: "photoCards") var parentFolder: LinkingObjects<Folder>
    
    convenience init(
        imageScale: Bool,
        videoData: Data,
        filterInfo: FilterInfo,
        isSelectedMain: Bool,
        cardContent: CardContent
    ) {
        self.init()
        self.imageName = self.id.stringValue
        self.imageScale = imageScale
        self.videoData = videoData
        
        do {
            let encoder = JSONEncoder()
            self.filterInfo = try encoder.encode(filterInfo)
            
        } catch {
            print("Failed encoding Filter: \(error)")
        }
        
        self.isSelectedMain = isSelectedMain
        self.cardContent = cardContent
    }
    
    func getFilterInfo() -> FilterInfo? {
        
        do {
            let decoder = JSONDecoder()
            return try decoder.decode(FilterInfo.self, from: self.filterInfo)
            
        } catch {
            print("Failed Decoding Filter: \(error)")
            return nil
        }
    }
}

