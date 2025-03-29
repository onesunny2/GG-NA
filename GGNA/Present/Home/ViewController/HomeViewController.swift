//
//  HomeViewController.swift
//  GGNA
//
//  Created by Lee Wonsun on 3/30/25.
//

import UIKit
import SnapKit
import RxCocoa
import RxSwift

final class HomeViewController: BaseViewController {
    
    private let viewModel: HomeViewModel
    private let disposeBag = DisposeBag()
    
    private let suffleButton = CustomBarButton(ImageLiterals.shuffle)
    private let palleteButton = CustomBarButton(ImageLiterals.paintpalette)
    
    private let rightStackView = UIStackView()
    
    init(viewModel: HomeViewModel) {
        self.viewModel = viewModel
        super.init()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        
    }
    
    override func configureBind() {
        
        let input = HomeViewModel.Input()
        let output = viewModel.transform(from: input)
        
        CurrentTheme.$currentTheme
            .bind(with: self) { owner, value in
                
                let theme = value.theme
                let color = value.color
                let colors = color.setColor(for: theme)
                
                let attribute: [NSAttributedString.Key: Any] = [.foregroundColor: colors.text]
                
                owner.view.backgroundColor = colors.background
                owner.navigationController?.navigationBar.largeTitleTextAttributes = attribute
                owner.navigationController?.navigationBar.tintColor = colors.text
            }
            .disposed(by: disposeBag)
    }
    
    override func configureNavigation() {
        
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.title = NavigationTitle.홈.title
        
        let rightStackBarButtonItem = UIBarButtonItem(customView: rightStackView)
        navigationItem.rightBarButtonItem = rightStackBarButtonItem
    }

    override func configureView() {
        rightStackView.distribution = .equalSpacing
        rightStackView.axis = .horizontal
        rightStackView.alignment = .center
        rightStackView.spacing = 15
    }
    
    override func configureHierarchy() {
        
        rightStackView.addArrangedSubviews(suffleButton, palleteButton)
    }
}
