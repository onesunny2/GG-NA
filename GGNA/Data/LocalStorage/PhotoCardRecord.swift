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
//            print("encoding filterInfo: \(self.filterInfo)")
        } catch {
            print("Failed encoding Filter: \(error)")
        }
        
        self.isSelectedMain = isSelectedMain
        self.cardContent = cardContent
    }
    
    func getFilterInfo() -> FilterInfo? {
        do {
//            print("Filter data length: \(self.filterInfo.count) bytes")
            if self.filterInfo.isEmpty {
                print("Warning: Filter data is empty!")
                return nil
            }
            
            if let jsonString = String(data: self.filterInfo, encoding: .utf8) {
                print("Raw JSON: \(jsonString)")
            } else {
                print("Could not convert filter data to string - possibly corrupt")
            }
            
            let decoder = JSONDecoder()
            return try decoder.decode(FilterInfo.self, from: self.filterInfo)
        } catch {
            print("Failed Decoding Filter: \(error)")
            return nil
        }
    }
}

