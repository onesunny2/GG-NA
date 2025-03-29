//
//  LaunchViewController.swift
//  GGNA
//
//  Created by Lee Wonsun on 3/28/25.
//

import UIKit

import SnapKit
import RxCocoa
import RxSwift

final class LaunchViewController: BaseViewController {
    
    private let viewModel: LaunchScreenViewModel
    private let disposeBag = DisposeBag()
    
    private let launchImage = BaseUIImageView(image: nil)

    init(viewModel: LaunchScreenViewModel) {
        self.viewModel = viewModel
        super.init()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    override func configureBind() {
        
        let input = LaunchScreenViewModel.Input(
            viewDidLoad: Observable.just(())
        )
        
        let output = viewModel.transform(from: input)
        
        output.endTimer
            .drive(with: self) { owner, _ in
                let vc = CustomTabBarController.create()
                owner.viewTransition(type: .changeRootVC, vc: vc)
            }
            .disposed(by: disposeBag)
    }
    
    override func configureNavigation() {
        navigationController?.navigationBar.isHidden = true
    }

    override func configureView() {
        
        CurrentTheme.$currentTheme
            .bind(with: self) { owner, value in
                
                let colors = value.color.setColor(for: value.theme)
                let image = value.color.setLaunchImage(for: value.theme)
                
                owner.view.backgroundColor = colors.background
                owner.launchImage.image = image
            }
            .disposed(by: disposeBag)
    }
    
    override func configureHierarchy() {
        view.addSubview(launchImage)
        
    }
    
    override func configureLayout() {
        launchImage.snp.makeConstraints {
            $0.center.equalTo(view.safeAreaLayoutGuide)
        }
    }
}
