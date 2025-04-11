//
//  AppDelegate.swift
//  GGNA
//
//  Created by Lee Wonsun on 3/26/25.
//

import UIKit
import RealmSwift

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        AppPermissionManager.requestCameraPermission()
        
        migration()
        
        let realm = try! Realm()
        
        // 현재 사용자가 쓰고 있는 DB Schema Version 확인
        do {
            let version = try schemaVersionAtURL(realm.configuration.fileURL!)
            print("Schema Version", version)
        } catch {
            print("Schema Failed")
        }
        
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }


}

extension AppDelegate {
    
    func migration() {
        let config = Realm.Configuration(schemaVersion: 1) { migration, oldSchemaVersion in
            
            // 0 -> 1: PhotoCardRecord에 filterInfo(Data) 추가
            if oldSchemaVersion < 1 {
                migration.enumerateObjects(ofType: PhotoCardRecord.className()) { oldObject, newObject in
                    guard let newObject else { return }
                    
                    if let oldObject = oldObject {
                        let oldFilter = oldObject["filter"] as? String ?? "original"
                        
                        let filter: Filter
                        switch oldFilter {
                        default: filter = .original
                        }
                        
                        let filterValue = 0.0
                        
                        let filterInfo = FilterInfo(filter: filter, filterValue: filterValue)
                        
                        do {
                            let encoder = JSONEncoder()
                            let filterInfoData = try encoder.encode(filterInfo)
                            newObject["filterInfo"] = filterInfoData
                        } catch {
//                            print("Migration encoding error: \(error)")
                            
                            let defaultFilter = FilterInfo(filter: .original, filterValue: 0.0)
                            if let defaultData = try? JSONEncoder().encode(defaultFilter) {
                                newObject["filterInfo"] = defaultData
                            } else {
                                newObject["filterInfo"] = Data()
                            }
                        }
                    } else {
                        let defaultFilter = FilterInfo(filter: .original, filterValue: 0.0)
                        if let defaultData = try? JSONEncoder().encode(defaultFilter) {
                            newObject["filterInfo"] = defaultData
                        } else {
                            newObject["filterInfo"] = Data()
                        }
                    }
                }
            }
        }

        Realm.Configuration.defaultConfiguration = config
    }
}
