//
//  WidgetInfo.swift
//  GGNA
//
//  Created by Lee Wonsun on 4/23/25.
//

import Foundation

enum WidgetInfo {
    case firstWidgetKind
    case firstDisplayName
    case secondWidgetKind
    case secondDisplayName
    case widgetDescription
    
    var text: String {
        switch self {
        case .firstWidgetKind: return "GGNAWidget_1"
        case .firstDisplayName: return "끄나 ver.1"
        case .secondWidgetKind: return "GGNAWidget_2"
        case .secondDisplayName: return "끄나 ver.2"
        case .widgetDescription: return "등록한 폴더의 이미지를 볼 수 있습니다."
        }
    }
}
