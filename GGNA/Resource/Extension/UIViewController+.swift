//
//  UIViewController+.swift
//  GGNA
//
//  Created by Lee Wonsun on 3/29/25.
//

import UIKit

extension UIViewController {
    
    func viewTransition(type: ViewTransition, vc: UIViewController) {
        
        switch type {
        case .navigation:
            navigationController?.pushViewController(vc, animated: true)
        case .changeRootVC:
            guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                  let window = windowScene.windows.first else { return }
            
            Task {
                window.rootViewController = vc
                window.makeKeyAndVisible()
            }
            
        case .fullScreen:
            vc.modalPresentationStyle = .fullScreen
            present(vc, animated: true)
        }
    }
}
