//
//  HomePhotoCardEntity.swift
//  GGNA
//
//  Created by Lee Wonsun on 3/30/25.
//

import UIKit

struct HomePhotoCardEntity {
    let imageData: UIImage?
    let videoData: Data?
    let isSelectedMain: Bool
    let createDate: Date
    let cardTitle: String?
    let cardDetail: String?
    let cardDate: String?
    let cardLocation: String?
    let secretMode: Bool
}
