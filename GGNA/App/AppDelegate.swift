//
//  AppDelegate.swift
//  GGNA
//
//  Created by Lee Wonsun on 3/26/25.
//

import UIKit
import FirebaseCore
import FirebaseMessaging
import RealmSwift

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        // 파이어베이스
        FirebaseApp.configure()
        
//        UNUserNotificationCenter.current().delegate = self
//        
//        let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
//        UNUserNotificationCenter.current().requestAuthorization(options: authOptions) { granted, error in
//            if let error = error {
//                print("Notification authorization error: \(error)")
//            } else {
//                print("Notification authorization granted: \(granted)")
//                DispatchQueue.main.async {
//                    application.registerForRemoteNotifications()
//                }
//            }
//        }
//        
//        application.registerForRemoteNotifications()
//        
//        Messaging.messaging().delegate = self
//        
//        // 현재 토큰 정보 가져오기 (꼭 App Delegate일 필요 없고, 다른 설정에서 해도 됨)
//        Messaging.messaging().token { token, error in
//          if let error = error {
//            print("Error fetching FCM registration token: \(error)")
//          } else if let token = token {
//            print("FCM registration token: \(token)")
//          }
//        }
        
        // 카메라 권한 설정
        AppPermissionManager.requestCameraPermission()
        
        // Realm
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

// Realm Migration
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

/* extension AppDelegate: UNUserNotificationCenterDelegate {
    
    // foreground에 띄워줄지말지
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        
        completionHandler([.list, .banner, .badge, .sound])
    }
    
    // 푸시 클릭 시
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        completionHandler()
    }
    
    // 디바이스 토큰 얻기
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        
        let deviceTokenString = deviceToken.reduce("", { $0 + String(format: "%02X", $1) })
        print("애플 APNS deviceToken:\(deviceTokenString)")
        
        // 애플 디바이스 토큰을 파이어베이스로 보내기
        Messaging.messaging().apnsToken = deviceToken
    }
} */

// firebase Messaging
/* extension AppDelegate: MessagingDelegate {
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        print("Firebase registration token: \(String(describing: fcmToken))")
        
        let dataDict: [String: String] = ["token": fcmToken ?? ""]
        NotificationCenter.default.post(
            name: Notification.Name("FCMToken"),
            object: nil,
            userInfo: dataDict
        )
        
        // Topic 구독: "all_users" Topic에 등록
        if let fcmToken = fcmToken {
            Messaging.messaging().subscribe(toTopic: "all_users") { error in
                if let error = error {
                    print("Topic 구독 실패: \(error)")
                } else {
                    print("all_users Topic 구독 성공")
                }
            }
        }
    }
} */
