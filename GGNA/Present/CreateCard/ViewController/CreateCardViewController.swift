//
//  CreateCardViewController.swift
//  GGNA
//
//  Created by Lee Wonsun on 3/31/25.
//

import UIKit
import RxCocoa
import RxSwift

final class CreateCardViewController: BaseViewController {
    
    private let disposeBag = DisposeBag()
    
    private let closeButton: UIButton = {
        let button = UIButton()
        button.setTitle(CreateCardBarButton.close.title, for: .normal)
        return button
    }()
    private let saveButton: UIButton = {
        let button = UIButton()
        button.setTitle(CreateCardBarButton.save.title, for: .normal)
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func configureView() {
    }
    
    override func configureBind() {
        
        CurrentTheme.$currentTheme
            .bind(with: self) { owner, value in
                
                let theme = value.theme
                let color = value.color
                let colors = color.setColor(for: theme)
                
                owner.navigationController?.navigationBar.tintColor = colors.text
                owner.view.backgroundColor = colors.background
            }
            .disposed(by: disposeBag)
    }

    override func configureNavigation() {
        navigationItem.title = NavigationTitle.카드생성.title
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: closeButton)
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: saveButton)
        
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .clear
        self.navigationController?.navigationBar.standardAppearance = appearance
        self.navigationController?.navigationBar.scrollEdgeAppearance = appearance
    }
}

extension CreateCardViewController {
    
    enum CreateCardBarButton {
        case close
        case save
        
        var title: String {
            switch self {
            case .close: return "닫기"
            case .save: return "저장"
            }
        }
    }
}
