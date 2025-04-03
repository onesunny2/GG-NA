//
//  Toast.swift
//  GGNA
//
//  Created by Lee Wonsun on 4/3/25.
//

import UIKit
import Toast

enum Toast {
    case 카드저장실패
    case 카드저장완료
    
    var message: String {
        switch self {
        case .카드저장실패: return "필수사항이 누락되어 저장에 실패했습니다 :<"
        case .카드저장완료: return "포토카드가 저장되었습니다 :>"
        }
    }

    static func setToast(type: Toast, position: ToastPosition = .center) {
        if let scene = UIApplication.shared.connectedScenes.first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene {
            let keyWindow = scene.windows.first(where: { $0.isKeyWindow })
            
            keyWindow?.rootViewController?.view.makeToast(type.message, duration: 1.5, position: position)
        }
    }
}
