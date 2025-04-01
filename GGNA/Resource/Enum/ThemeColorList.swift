//
//  ThemeColorList.swift
//  GGNA
//
//  Created by Lee Wonsun on 4/1/25.
//

import UIKit

enum ThemeColorList {
    case darkPink
    case lightPink
    
    var theme: String {
        switch self {
        case .darkPink: return "Dark"
        case .lightPink: return "Light"
        }
    }
    
    var color: UIColor {
        switch self {
        case .darkPink: return .ggDarkPink
        case .lightPink: return .ggLightPink
        }
    }
}
