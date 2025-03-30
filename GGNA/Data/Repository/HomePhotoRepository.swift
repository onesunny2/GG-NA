//
//  HomePhotoRepository.swift
//  GGNA
//
//  Created by Lee Wonsun on 3/30/25.
//

import Foundation
import RealmSwift

protocol HomePhotoRepository: AnyObject {
    func getPhotosFromFolder() -> [PhotoCardRecord]
}

final class DefaultHomePhotoRepository {
    
}

final class DummyHomePhotoRepository: HomePhotoRepository {
    
    func getPhotosFromFolder() -> [PhotoCardRecord] {
        
        return [
            PhotoCardRecord(imageData: Data(), videoData: Data(), filter: "original", isSelectedMain: false, cardContent: CardContent()),
            PhotoCardRecord(imageData: Data(), videoData: Data(), filter: "original", isSelectedMain: false, cardContent: CardContent()),
            PhotoCardRecord(imageData: Data(), videoData: Data(), filter: "original", isSelectedMain: false, cardContent: CardContent()),
            PhotoCardRecord(imageData: Data(), videoData: Data(), filter: "original", isSelectedMain: false, cardContent: CardContent()),
            PhotoCardRecord(imageData: Data(), videoData: Data(), filter: "original", isSelectedMain: false, cardContent: CardContent())
        ]
    }
}
