//
//  ShareWithWidget.swift
//  GGNA
//
//  Created by Lee Wonsun on 4/29/25.
//

import Foundation

struct ShareWithWidget: Codable, Identifiable {
    var id = UUID()
    let folder: String
    let photoInfo: [SharePhoto]
}

struct SharePhoto: Codable {
    let imageName: String
    let filter: Filter
    let filterValue: Double
    let title: String
}
