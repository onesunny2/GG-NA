//
//  HomePhotoCardEntity.swift
//  GGNA
//
//  Created by Lee Wonsun on 3/30/25.
//

import UIKit

struct HomePhotoCardEntity: Hashable {
    let id = UUID()
    let imageData: UIImage?
    let videoData: Data?
    let filter: String
    let isSelectedMain: Bool
    let cardTitle: String?
    let cardDetail: String?
    let cardDate: String?
    let cardLocation: String?
    let secretMode: Bool
}
