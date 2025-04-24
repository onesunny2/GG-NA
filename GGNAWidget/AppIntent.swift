//
//  AppIntent.swift
//  GGNAWidget
//
//  Created by Lee Wonsun on 4/23/25.
//

import WidgetKit
import AppIntents

struct SelectFolderAppIntent: WidgetConfigurationIntent {
    static var title: LocalizedStringResource { "Widget Selected Folder" }
    static var description: IntentDescription { "포토카드 폴더를 선택해주세요." }

    @Parameter(title: "폴더 변경")
    var selectedFolder: WidgetCard?
}

struct WidgetCard: AppEntity {
    var id: String
    var folder: String
    var photos: [CardDetail]
    
    static var typeDisplayRepresentation: TypeDisplayRepresentation = "Widget Card"
    static var defaultQuery = WidgetCardQuery()
    
    var displayRepresentation: DisplayRepresentation {
        DisplayRepresentation(title: "\(folder)")
    }
    
    static let allFolders: [WidgetCard] = [
        WidgetCard(id: "기본1", folder: "냥팔자상팔자", photos: [CardDetail(imageName: "몰루", title: "이짜몽후루루")]),
        WidgetCard(id: "기본2", folder: "이원선상팔자", photos: [CardDetail(imageName: "몰루", title: "선선선선후루")]),
        WidgetCard(id: "기본3", folder: "김기영상팔자", photos: [CardDetail(imageName: "몰루", title: "버네너후루루")])
    ]
}

struct CardDetail {
    var id: String { imageName }
    var imageName: String
    var title: String
}

struct WidgetCardQuery: EntityQuery {
    func entities(for identifiers: [WidgetCard.ID]) async throws -> [WidgetCard] {
        WidgetCard.allFolders.filter {
            identifiers.contains($0.id)
        }
    }
    
    func suggestedEntities() async throws -> [WidgetCard] {
        WidgetCard.allFolders
    }
    
    func defaultResult() async -> WidgetCard? {
        WidgetCard.allFolders.first
    }
}
