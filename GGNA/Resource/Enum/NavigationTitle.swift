//
//  NavigationTitle.swift
//  GGNA
//
//  Created by Lee Wonsun on 3/30/25.
//

import Foundation

enum NavigationTitle {
    case 홈
    case 보관함
    case 카드테마
    case 테마색상
    case 카드생성
    case 폴더삭제
    
    var title: String {
        switch self {
        case .홈: return "그 때의 나는,"
        case .보관함: return "나의 추억들"
        case .카드테마: return "카드 테마"
        case .테마색상: return "테마 색상"
        case .카드생성: return "추억남기기"
        case .폴더삭제: return "삭제할 폴더 선택"
        }
    }
}
