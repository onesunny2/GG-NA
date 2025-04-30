//
//  UserDefaults+.swift
//  GGNA
//
//  Created by Lee Wonsun on 4/24/25.
//

import Foundation

extension UserDefaults {
    
    static var groupShared: UserDefaults {
        let appID = "group.ws.ggna.widget"
        return UserDefaults(suiteName: appID)!
    }
}
