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
    case 메인사진_설정
    case 기본폴더_삭제
    
    var message: String {
        switch self {
        case .카드저장_실패: return "필수사항이 누락되어 저장에 실패했습니다 :<"
        case .카드저장_성공: return "포토카드가 저장되었습니다 :>"
        case .메인사진_설정: return "해당 폴더에 이미 등록된 메인 추억이 있다면 대체됩니다 :)"
        case .기본폴더_삭제: return "기본 폴더는 삭제할 수 없습니다 :<"
        }
    }
}
