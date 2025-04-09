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
        
        // 환경을 어떤 내용으로 바꿀건데?: 버전을 1로 바꿀거야
        let config = Realm.Configuration(schemaVersion: 1) { migration, oldSchemaVersion in
            
            // MARK: 모든 마이그레이션 코드는 여기에
            // 0 -> 1: PhotoCardRecord에 filterValue(Double) 추가
            if oldSchemaVersion < 1 { }
        }
        
        // 아래의 defaultConfiguration 환경을 바꿔주려는 것
        Realm.Configuration.defaultConfiguration = config
    }
}
