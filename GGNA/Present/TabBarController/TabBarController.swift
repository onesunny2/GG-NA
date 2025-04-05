//
//  TabBarController.swift
//  GGNA
//
//  Created by Lee Wonsun on 3/29/25.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

final class CustomTabBarController: UITabBarController {
    
    private let disposeBag = DisposeBag()
    private let centerButton = UIButton()
    private let customTabBarView = UIView()
    private var tabButtons: [UIButton] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCustomTabBar()
        setupTabBarItems()
        setupCenterButton()
        configureBind()
        adjustSafeAreaForCustomTabBar()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        positionCustomTabBar()
    }
    
    private func setupCustomTabBar() {
        tabBar.isHidden = true
        customTabBarView.layer.cornerRadius = 32.5
        view.addSubview(customTabBarView)
    }
    
    private func positionCustomTabBar() {
            customTabBarView.snp.makeConstraints {
                $0.width.equalTo(290)
                $0.height.equalTo(65)
                $0.centerX.equalToSuperview()
                $0.bottom.equalTo(view.snp.bottom).offset(-40) 
            }
        }
    
    private func setupTabBarItems() {

        let initialTheme = CurrentTheme.currentTheme
        let initialColors = initialTheme.color.setColor(for: initialTheme.theme)
        setupTabBarItems(selected: initialColors.main, unselected: initialColors.unselectedTabBar)
        selectedIndex = 0
    }
    
    private func setupTabBarItems(selected: UIColor, unselected: UIColor) {
        
        let symbolConfig = UIImage.SymbolConfiguration(pointSize: 20, weight: .medium)
        
        let home = ImageLiterals.home?.withConfiguration(symbolConfig)
        let homeButton = createTabButton(
            image: home ?? UIImage(),
            tag: 0,
            selected: selected,
            unselected: unselected,
            isSelected: true
        )
        customTabBarView.addSubview(homeButton)
        
        let folder = ImageLiterals.folder?.withConfiguration(symbolConfig)
        let folderButton = createTabButton(
            image: folder ?? UIImage(),
            tag: 1,
            selected: selected,
            unselected: unselected,
            isSelected: false
        )
        customTabBarView.addSubview(folderButton)
        
        tabButtons = [homeButton, folderButton]
        updateTabButtonAppearance(selectedIndex: 0, selected: selected, unselected: unselected)
        
        homeButton.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.right.equalTo(customTabBarView.snp.centerX).offset(-65)
        }
        
        folderButton.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.left.equalTo(customTabBarView.snp.centerX).offset(65)
        }
        
        homeButton.rx.tap
            .bind(with: self) { owner, _ in
                owner.selectedIndex = 0
                let colors = CurrentTheme.currentTheme.color.setColor(for: CurrentTheme.currentTheme.theme)
                owner.updateTabButtonAppearance(selectedIndex: 0, selected: colors.main, unselected: colors.gray)
            }
            .disposed(by: disposeBag)
        
        folderButton.rx.tap
            .bind(with: self) { owner, _ in
                owner.selectedIndex = 1
                let colors = CurrentTheme.currentTheme.color.setColor(for: CurrentTheme.currentTheme.theme)
                owner.updateTabButtonAppearance(selectedIndex: 1, selected: colors.main, unselected: colors.gray)
            }
            .disposed(by: disposeBag)
    }
    
    private func createTabButton(image: UIImage, tag: Int, selected: UIColor, unselected: UIColor, isSelected: Bool) -> UIButton {
        let button = UIButton()
        button.setImage(image, for: .normal)
        button.tintColor = isSelected ? selected : unselected
        button.tag = tag
        return button
    }
    
    private func updateTabButtonAppearance(selectedIndex: Int, selected: UIColor, unselected: UIColor) {
        
        for (index, button) in tabButtons.enumerated() {
            UIView.animate(withDuration: 0.2) {
                button.tintColor = (index == selectedIndex) ? selected : unselected
                button.transform = (index == selectedIndex) ?
                    CGAffineTransform(scaleX: 1.15, y: 1.15) :
                    CGAffineTransform.identity
            }
        }
    }
    
    private func setupCenterButton() {
        
        let symbolConfig = UIImage.SymbolConfiguration(pointSize: 30, weight: .semibold)
        let plus = ImageLiterals.plus?.withConfiguration(symbolConfig)
        
        centerButton.setImage(plus, for: .normal)
        centerButton.layer.cornerRadius = 20
        view.addSubview(centerButton)
        
        centerButton.snp.makeConstraints {
            $0.width.height.equalTo(40)
            $0.center.equalTo(customTabBarView)
        }
        
        view.bringSubviewToFront(centerButton)
        
        let initialColors = CurrentTheme.currentTheme.color.setColor(for: CurrentTheme.currentTheme.theme)
        centerButton.backgroundColor = initialColors.plusBtn
        centerButton.tintColor = initialColors.main
    }
    
    private func configureBind() {
        
        CurrentTheme.$currentTheme
            .bind(with: self, onNext: { owner, value in
                let colors = value.color.setColor(for: value.theme)
                
                // 커스텀 탭바 배경 색상
                owner.customTabBarView.backgroundColor = colors.tabBar
                
                // 센터 버튼 색상
                owner.centerButton.backgroundColor = colors.plusBtn
                owner.centerButton.tintColor = colors.main
                
                // 탭 버튼 색상 업데이트
                owner.updateTabButtonAppearance(
                    selectedIndex: 0,
                    selected: colors.main,
                    unselected: colors.unselectedTabBar
                )
            })
            .disposed(by: disposeBag)
        
        centerButton.rx.tap
            .bind(with: self) { owner, _ in
                owner.presentAddScreen()
            }
            .disposed(by: disposeBag)
    }
    
    // MARK: 플러스 버튼 액션
    private func presentAddScreen() {
        
        let vm = CreateCardViewModel()
        let vc = CreateCardViewController(viewModel: vm)
        let nv = UINavigationController(rootViewController: vc)
        viewTransition(type: .fullScreen, vc: nv)
    }
    
    private func adjustSafeAreaForCustomTabBar() {
        let customTabBarHeight: CGFloat = 65
        let bottomOffset: CGFloat = 40
        additionalSafeAreaInsets = UIEdgeInsets(top: 0, left: 0, bottom: customTabBarHeight + bottomOffset, right: 0)
    }
}

extension CustomTabBarController {
    static func create() -> CustomTabBarController {
        
        let tabBarController = CustomTabBarController()
        
        let homeRP = DefaultHomePhotoRepository()
        let homeVM = HomeViewModel(repository: homeRP)
        let homeVC = HomeViewController(viewModel: homeVM)
        let homeNav = UINavigationController(rootViewController: homeVC)
        
        let folderRP = DefaultArchiveFolderRepository()
        let folderVM = ArchiveFolderViewModel(repository: folderRP)
        let folderVC = ArchiveFolderViewController(viewModel: folderVM)
        let folderNav = UINavigationController(rootViewController: folderVC)
        
        tabBarController.viewControllers = [homeNav, folderNav]
        
        return tabBarController
    }
}
