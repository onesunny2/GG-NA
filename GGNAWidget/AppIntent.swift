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
}

struct CardDetail {
    var id: String { imageName }
    var imageName: String
    var title: String
    var filter: Filter
    var filterValue: Double
}

struct WidgetCardQuery: EntityQuery {
    func entities(for identifiers: [WidgetCard.ID]) async throws -> [WidgetCard] {
        WidgetCard.allFolders.filter {
            identifiers.contains($0.id)
        }.filter {
            !$0.photos.isEmpty
        }
    }
    
    func suggestedEntities() async throws -> [WidgetCard] {
        WidgetCard.allFolders
    }
    
    func defaultResult() async -> WidgetCard? {
        WidgetCard.allFolders.randomElement()
    }
}

func loadWidgetCardsFromSharedDefaults() -> [WidgetCard] {
    
    let userDefaults = UserDefaults.groupShared
    
    guard let data = userDefaults.data(forKey: "shareFolderInfo") else {
        print("위젯: UserDefaults에서 데이터를 찾을 수 없습니다")
        return []
    }
    
    do {
        // 공유된 구조체 형식으로 디코딩
        let shareData = try JSONDecoder().decode([ShareWithWidget].self, from: data)
        
        // WidgetCard 배열로 변환
        let widgetCards = shareData.map { folderInfo -> WidgetCard in
            // 각 폴더 내 사진 정보를 CardDetail로 변환
            let cardDetails = folderInfo.photoInfo.map { photo -> CardDetail in
                return CardDetail(
                    imageName: photo.imageName,
                    title: photo.title,
                    filter: photo.filter,
                    filterValue: photo.filterValue
                )
            }
            
            return WidgetCard(
                id: folderInfo.folder,
                folder: folderInfo.folder,
                photos: cardDetails
            )
        }
        
        return widgetCards.filter { !$0.photos.isEmpty }
    } catch {
        print("위젯: 데이터 디코딩 실패: \(error)")
        return []
    }
}

extension WidgetCard {
    
    static var allFolders: [WidgetCard] {
        let loadedCards = loadWidgetCardsFromSharedDefaults()
        return loadedCards.isEmpty ? fallbackFolders : loadedCards
    }
   
    static let fallbackFolders: [WidgetCard] = [
        WidgetCard(id: "noData", folder: "No Photo", photos: [CardDetail(imageName: "", title: "저장된 사진없음", filter: .bloom, filterValue: 0.5)])
    ]
}
