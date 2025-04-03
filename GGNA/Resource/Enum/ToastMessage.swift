//
//  ToastMessage.swift
//  GGNA
//
//  Created by Lee Wonsun on 4/4/25.
//

import Foundation

enum ToastMessage {
    case 카드저장_실패
    case 카드저장_성공
    
    var message: String {
        switch self {
        case .카드저장_실패: return "필수사항이 누락되어 저장에 실패했습니다 :<"
        case .카드저장_성공: return "포토카드가 저장되었습니다 :>"
        }
    }
}
