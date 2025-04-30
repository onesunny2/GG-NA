//
//  UserDefaultsManager.swift
//  GGNA
//
//  Created by Lee Wonsun on 4/23/25.
//

import Foundation

struct PhotoCard: Codable, Identifiable {
    var id: String { imageName }  // Realm의 ObjectID를 이미지이름으로 해뒀음
    var title: String
    var imageName: String
    
    enum CodingKeys: String, CodingKey {
        case title, imageName
    }
}

struct PhotoFolder: Codable, Identifiable {
    // name을 id로 직접 사용 (폴더명이 고유하다면)
    var id: String { name }
    var name: String
    var photos: [PhotoCard]
    
    enum CodingKeys: String, CodingKey {
        case name, photos
    }
}

final class UserDefaultsManager {
    static let shared = UserDefaultsManager()
    
    // App Group 식별자 - 실제 App Group ID로 변경 필요
    private let appGroupIdentifier = "group.ws.ggna.widget"
    
    private init() {}
    
    // App Group 컨테이너 URL 가져오기
    private func getContainerURL() -> URL? {
        return FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: appGroupIdentifier)
    }
    
    // 폴더 목록 가져오기
    func getFolders() -> [PhotoFolder] {
        guard let containerURL = getContainerURL() else { return [] }
        let foldersURL = containerURL.appendingPathComponent("folders.json")
        
        do {
            let data = try Data(contentsOf: foldersURL)
            let folders = try JSONDecoder().decode([PhotoFolder].self, from: data)
            return folders
        } catch {
            print("Error loading folders: \(error)")
            return [PhotoFolder(name: "기본", photos: [PhotoCard(title: "Test1", imageName: "test1")])]
        }
    }
    
    // 폴더 이름 목록만 가져오기
    func getFolderNames() -> [String] {
        return getFolders().map { $0.name }
    }
    
    // 특정 폴더 가져오기
    func getFolder(withName name: String) -> PhotoFolder? {
        return getFolders().first(where: { $0.name == name })
    }
    
    // 이미지 URL 가져오기
    func getImageURL(forPhoto photo: PhotoCard) -> URL? {
        guard let containerURL = getContainerURL() else { return nil }
        return containerURL.appendingPathComponent("Images/\(photo.imageName)")
    }
}
