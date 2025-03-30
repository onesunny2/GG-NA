//
//  HomePhotoRepository.swift
//  GGNA
//
//  Created by Lee Wonsun on 3/30/25.
//

import UIKit
import RealmSwift

protocol HomePhotoRepository: AnyObject {
    func getPhotosFromFolder() -> [HomePhotoCardEntity]
}

final class DefaultHomePhotoRepository {
    
}

final class DummyHomePhotoRepository: HomePhotoRepository {
    
    func getPhotosFromFolder() -> [HomePhotoCardEntity] {
        
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
