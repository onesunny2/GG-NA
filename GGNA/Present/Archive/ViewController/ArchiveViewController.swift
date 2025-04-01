//
//  ArchiveViewController.swift
//  GGNA
//
//  Created by Lee Wonsun on 4/1/25.
//

import UIKit
import SnapKit
import RxCocoa
import RxSwift

final class ArchiveViewController: BaseViewController {
    
    private let disposeBag = DisposeBag()
    
    private let addFolderButton = CustomBarButton(ImageLiterals.folderPlus)

    override func viewDidLoad() {
        super.viewDidLoad()

        
    }
    
    override func configureBind() {
        
        addFolderButton.rx.tap
            .bind(with: self) { owner, _ in
                owner.textFieldAlert()
            }
            .disposed(by: disposeBag)
        
        CurrentTheme.$currentTheme
            .bind(with: self) { owner, value in
                
                let theme = value.theme
                let color = value.color
                let colors = color.setColor(for: theme)
                
                let attribute: [NSAttributedString.Key: Any] = [.foregroundColor: colors.text]
                
                owner.navigationController?.navigationBar.largeTitleTextAttributes = attribute
                owner.navigationController?.navigationBar.tintColor = colors.text
                owner.view.backgroundColor = colors.background
            }
            .disposed(by: disposeBag)
    }
    
    override func configureNavigation() {
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.title = NavigationTitle.보관함.title
        
        let rightBarButtonItem = UIBarButtonItem(customView: addFolderButton)
        navigationItem.rightBarButtonItem = rightBarButtonItem
    }
}
