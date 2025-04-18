//
//  UIViewController+.swift
//  GGNA
//
//  Created by Lee Wonsun on 3/29/25.
//

import UIKit
import SnapKit
import RxCocoa
import RxSwift

extension UIViewController {
    
    func viewTransition(type: ViewTransition, vc: UIViewController) {
        
        switch type {
        case .navigation:
            navigationController?.pushViewController(vc, animated: true)
        case .changeRootVC:
            guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                  let window = windowScene.windows.first else { return }
            
            guard let snapshot = window.snapshotView(afterScreenUpdates: false) else { return }
            
            vc.view.addSubview(snapshot)
            window.rootViewController = vc
            
            UIView.animate(withDuration: 0.3, animations: {
                snapshot.alpha = 0
            }, completion: { _ in
                snapshot.removeFromSuperview()
            })
            
            window.makeKeyAndVisible()
            
        case .fullScreen:
            vc.modalPresentationStyle = .fullScreen
            present(vc, animated: true)
        }
    }
    
    func textFieldAlert(completion: @escaping ((String) -> ())) {
        
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
                guard let text = alert.textFields?.first?.text, !text.isEmpty else { return }
                
                let folderName = String(text.prefix(7))
                completion(folderName)
            }
        
        let cancelAction = UIAlertAction(title: "취소", style: .default)
        
        alert.addAction(cancelAction)
        alert.addAction(createAction)
    
        alert.view.tintColor = colors.main
        
        self.present(alert, animated: true)
    }
    
    func closeButtonAlert() {
        
        let theme = CurrentTheme.currentTheme.theme
        let color = CurrentTheme.currentTheme.color
        let colors = color.setColor(for: theme)
        
        let alert = UIAlertController(
            title: "경고",
            message: "현재 수정 중인 데이터가 사라집니다.",
            preferredStyle: .alert
        )
        
        let cancelAction = UIAlertAction(title: "취소", style: .default)
        let okayAction = UIAlertAction(title: "확인", style: .default) { _ in
            DatePickerManager.shared.resetDate()
            self.dismiss(animated: true)
        }
        
        alert.addAction(cancelAction)
        alert.addAction(okayAction)
        
        alert.view.tintColor = colors.main
        
        self.present(alert, animated: true)
    }
    
    func deleteFoldersAlert(completion: @escaping (() -> ())) {
        let theme = CurrentTheme.currentTheme.theme
        let color = CurrentTheme.currentTheme.color
        let colors = color.setColor(for: theme)
        
        let alert = UIAlertController(
            title: "경고",
            message: "해당 폴더에 있는 사진도 함께 삭제됩니다.",
            preferredStyle: .alert
        )
        
        let deleteAction = UIAlertAction(
            title: "삭제",
            style: .default) { _ in
                completion()
            }
        
        let cancelAction = UIAlertAction(title: "취소", style: .default)
        
        alert.addAction(cancelAction)
        alert.addAction(deleteAction)
    
        alert.view.tintColor = colors.main
        
        self.present(alert, animated: true)
    }
    
    func customToast(type: ToastMessage) {
        
        let theme = CurrentTheme.currentTheme.theme
        let color = CurrentTheme.currentTheme.color
        let colors = color.setColor(for: theme)
        
        view.subviews.filter { $0.tag == 777 }.forEach { $0.removeFromSuperview() }
        
        let containerView = UIView()
        containerView.tag = 777
        containerView.backgroundColor = colors.background.withAlphaComponent(0.8)
        containerView.layer.cornerRadius = 16
        containerView.clipsToBounds = true
        
        let message = BaseUILabel(
            text: type.message,
            color: colors.main,
            alignment: .center,
            font: FontLiterals.basicBadge15,
            line: 0
        )
        
        containerView.addSubview(message)
        view.addSubview(containerView)
        
        // layout
        message.snp.makeConstraints {
            $0.verticalEdges.equalToSuperview().inset(12)
            $0.horizontalEdges.equalToSuperview().inset(16)
        }
        
        containerView.snp.makeConstraints {
            $0.center.equalToSuperview()
        }
        
        UIView.animate(withDuration: 0.3, animations: {
            containerView.alpha = 1
         }, completion: { _ in
             UIView.animate(withDuration: 0.3, delay: 0.8, options: .curveEaseOut, animations: {
                 containerView.alpha = 0
             }, completion: { _ in
                 containerView.removeFromSuperview()
                 
                 // 저장완료면 애니메이션 끝나고 닫히도록
                 guard type == .카드저장_성공 else { return }
                 self.dismiss(animated: true)
             })
         })
    }
    
    // TODO: 통일 필요함
    func deletePhotoFromFolder(folderName: String, imageName: String) {
        
        guard let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return
        }
        
        let folderURL = documentDirectory.appendingPathComponent(folderName)
        
        let imageJpgName = imageName + ".jpg"
        let imageURL = folderURL.appendingPathComponent(imageJpgName)
        
        do {
            
            if FileManager.default.fileExists(atPath: imageURL.path) {
                try FileManager.default.removeItem(at: imageURL)
            } else {
                print("삭제할 이미지를 찾을 수 없음: \(imageName)")
            }
            
        } catch {
            print("이미지 삭제 오류: \(error.localizedDescription)")
        }
    }
}
