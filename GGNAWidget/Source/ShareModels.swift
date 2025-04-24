////
////  ShareModels.swift
////  GGNA
////
////  Created by Lee Wonsun on 4/24/25.
////
//
//import Foundation
//import WidgetKit
//import AppIntents
//
//public struct WidgetCard: AppEntity {
//    public var id: String
//    public var folder: String
//    public var photos: [CardDetail]
//    
//    public init(id: String, folder: String, photos: [CardDetail]) {
//        self.id = id
//        self.folder = folder
//        self.photos = photos
//    }
//    
//    public static var typeDisplayRepresentation: TypeDisplayRepresentation = "Widget Card"
//    public static var defaultQuery = WidgetCardQuery()
//    
//    public var displayRepresentation: DisplayRepresentation {
//        DisplayRepresentation(title: "\(folder)")
//    }
//    
//    public static let allFolders: [WidgetCard] = [
//        WidgetCard(id: "기본1", folder: "냥팔자상팔자", photos: [CardDetail(imageName: "몰루", title: "이짜몽후루루")]),
//        WidgetCard(id: "기본2", folder: "이원선상팔자", photos: [CardDetail(imageName: "몰루", title: "선선선선후루")]),
//        WidgetCard(id: "기본3", folder: "김기영상팔자", photos: [CardDetail(imageName: "몰루", title: "버네너후루루")])
//    ]
//}
//
//public struct CardDetail {
//    public var id: String { imageName }
//    public var imageName: String
//    public var title: String
//    
//    public init(imageName: String, title: String) {
//        self.imageName = imageName
//        self.title = title
//    }
//}
//
//public struct WidgetCardQuery: EntityQuery {
//    public func entities(for identifiers: [WidgetCard.ID]) async throws -> [WidgetCard] {
//        WidgetCard.allFolders.filter {
//            identifiers.contains($0.id)
//        }
//    }
//    
//    public func suggestedEntities() async throws -> [WidgetCard] {
//        WidgetCard.allFolders
//    }
//    
//    public func defaultResult() async -> WidgetCard? {
//        WidgetCard.allFolders.first
//    }
//}
//
