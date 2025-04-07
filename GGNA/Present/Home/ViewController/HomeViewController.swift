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
    
    private let viewWillAppear = PublishRelay<Void>()
    
    private let shuffleButton = CustomBarButton(ImageLiterals.change)
    private let palleteButton = CustomBarButton(ImageLiterals.paintpalette)
    private let rightStackView = UIStackView()
    
    private let themeView = FirstThemeView()
    
    init(viewModel: HomeViewModel) {
        self.viewModel = viewModel
        super.init()
        
        // TODO: 2차에 테마 업데이트 할 때 hidden 제거
        shuffleButton.isHidden = false
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewWillAppear.accept(())
    }
    
    private func presentColorThemeSheet() {
        
        let modalVC = ThemeColorModalView()
        
        if let sheet = modalVC.sheetPresentationController {
            
            if #available(iOS 16.0, *) {
                let customDetent = UISheetPresentationController.Detent.custom { context in
                    // 화면 높이의 1/3 반환
                    return context.maximumDetentValue / 3
                }
                sheet.detents = [customDetent]
            } else {
                sheet.detents = [.medium()]
            }
            
            sheet.prefersGrabberVisible = true
            sheet.preferredCornerRadius = 20
        }
        
        present(modalVC, animated: true)
    }
    
    override func configureBind() {
        
        let input = HomeViewModel.Input(
            viewWillAppear: viewWillAppear.asObservable()
        )
        let output = viewModel.transform(from: input)
        
        output.currentPhotos
            .drive(with: self) { owner, photos in
                owner.themeView.setupCardViews(with: photos)
            }
            .disposed(by: disposeBag)
        
        palleteButton.rx.tap
            .bind(with: self) { owner, _ in
                owner.presentColorThemeSheet()
            }
            .disposed(by: disposeBag)
        
        CurrentTheme.$currentTheme
            .bind(with: self) { owner, value in
                
                let theme = value.theme
                let color = value.color
                let colors = color.setColor(for: theme)
                
                // 네비게이션 바 스타일 업데이트
                let attribute: [NSAttributedString.Key: Any] = [.foregroundColor: colors.text]
                owner.navigationController?.navigationBar.largeTitleTextAttributes = attribute
                owner.navigationController?.navigationBar.tintColor = colors.text
                
                // themeView에 색상 전달
                owner.themeView.updateThemeColors(with: colors)
                
                // 배경색 업데이트
                owner.view.backgroundColor = colors.background
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
        rightStackView.spacing = 12
    }
    
    override func configureHierarchy() {
        rightStackView.addArrangedSubviews(palleteButton, shuffleButton)
        view.addSubview(themeView)
    }
    
    override func configureLayout() {
        themeView.snp.makeConstraints {
            $0.edges.equalTo(view.safeAreaLayoutGuide)
        }
    }
}
