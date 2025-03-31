//
//  CreateCardViewController.swift
//  GGNA
//
//  Created by Lee Wonsun on 3/31/25.
//

import UIKit
import SnapKit
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
    
    private let switchStackView = UIStackView()
    private let photoButton = OnlyImageButton(image: ImageLiterals.photoCircleFill, isSelected: true)
    private let writingButton = OnlyImageButton(image: ImageLiterals.pencilCircleFill, isSelected: false)

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func configureBind() {
        
        photoButton.rx.tap
            .bind(with: self) { owner, _ in
                        
                guard !owner.photoButton.isSelected else { return }
                owner.photoButton.isSelected = true
                owner.writingButton.isSelected = false
            }
            .disposed(by: disposeBag)
                
        writingButton.rx.tap
            .bind(with: self) { owner, _ in
                        
                guard !owner.writingButton.isSelected else { return }
                owner.photoButton.isSelected = false
                owner.writingButton.isSelected = true
            }
            .disposed(by: disposeBag)
        
        closeButton.rx.tap
            .bind(with: self) { owner, _ in
                owner.dismiss(animated: true)
            }
            .disposed(by: disposeBag)
        
        CurrentTheme.$currentTheme
            .bind(with: self) { owner, value in
                
                let theme = value.theme
                let color = value.color
                let colors = color.setColor(for: theme)

                owner.view.backgroundColor = colors.background
                owner.closeButton.setTitleColor(colors.text, for: .normal)
                owner.saveButton.setTitleColor(colors.text, for: .normal)
                owner.navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: colors.text]
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
    
    override func configureView() {
        switchStackView.axis = .horizontal
        switchStackView.spacing = 12
        switchStackView.alignment = .fill
    }
    
    override func configureHierarchy() {
        view.addSubviews(switchStackView)
        switchStackView.addArrangedSubviews(photoButton, writingButton)
    }
    
    override func configureLayout() {
        switchStackView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide).inset(20)
            $0.centerX.equalTo(view.safeAreaLayoutGuide)
        }
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
