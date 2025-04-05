//
//  FolderPhotosEntity.swift
//  GGNA
//
//  Created by Lee Wonsun on 4/2/25.
//

import UIKit

struct FolderPhotosEntity: Hashable {
    let image: UIImage
    let imageName: String
    let isSelectedMain: Bool
    let title: String
    let date: String
    let createDate: Date
    let secretMode: Bool
}
