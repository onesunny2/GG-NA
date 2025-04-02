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
    
    private let theme1BgCardView = UIView()
    private let theme1FirstCardView = FisrtThemeCardView()
    
    init(viewModel: HomeViewModel) {
        self.viewModel = viewModel
        super.init()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func configureBind() {
        
        let input = HomeViewModel.Input(
            viewDidLoad: Observable.just(())
        )
        let output = viewModel.transform(from: input)
        
        output.currentPhotos
            .drive(with: self) { owner, photos in
                
                guard let photo = photos.first else { return }
                owner.theme1FirstCardView.setImage(photo)
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
                
                let attribute: [NSAttributedString.Key: Any] = [.foregroundColor: colors.text]
                
                owner.navigationController?.navigationBar.largeTitleTextAttributes = attribute
                owner.navigationController?.navigationBar.tintColor = colors.text
                owner.theme1BgCardView.backgroundColor = colors.main
                owner.view.backgroundColor = colors.background
            }
            .disposed(by: disposeBag)
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
        
        theme1BgCardView.cornerRadius30()
        theme1BgCardView.transform = CGAffineTransform(rotationAngle: CGFloat.pi / 60)
    }
    
    override func configureHierarchy() {
        rightStackView.addArrangedSubviews(suffleButton, palleteButton)
        view.addSubviews(theme1BgCardView, theme1FirstCardView)
    }
    
    override func configureLayout() {
        theme1BgCardView.snp.makeConstraints {
            $0.centerX.equalTo(view.safeAreaLayoutGuide)
            $0.centerY.equalTo(view.safeAreaLayoutGuide).offset(17)
            $0.width.equalTo(view.snp.width).multipliedBy(0.8)
            $0.height.equalTo(view.snp.height).multipliedBy(0.6)
        }
        
        theme1FirstCardView.snp.makeConstraints {
            $0.centerX.equalTo(view.safeAreaLayoutGuide)
            $0.centerY.equalTo(view.safeAreaLayoutGuide).offset(17)
            $0.width.equalTo(view.snp.width).multipliedBy(0.8)
            $0.height.equalTo(view.snp.height).multipliedBy(0.6)
        }
    }
}
