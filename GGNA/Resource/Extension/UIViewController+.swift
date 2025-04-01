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
    
    func textFieldAlert() {
        
        let theme = CurrentTheme.currentTheme.theme
        let color = CurrentTheme.currentTheme.color
        let colors = color.setColor(for: theme)
        
        let alert = UIAlertController(
            title: "새로운 폴더 이름",
            message: nil,
            preferredStyle: .alert
        )
        
        // textfield 추가
        alert.addTextField { textfield in
            textfield.placeholder = "7자 이내로 적어주세요 :)"
            textfield.autocapitalizationType = .none
            textfield.autocorrectionType = .no
            textfield.tintColor = colors.main
        }
        
        let createAction = UIAlertAction(
            title: "생성",
            style: .default) { _ in
                // 텍스트필드 입력된 값 가져오기
                guard let text = alert.textFields?.first?.text else { return }
                
                print("입력한 텍스트: \(text)")
            }
        
        let cancelAction = UIAlertAction(title: "취소", style: .default)
        
        alert.addAction(cancelAction)
        alert.addAction(createAction)
    
        alert.view.tintColor = colors.main
        
        self.present(alert, animated: true)
    }
}
