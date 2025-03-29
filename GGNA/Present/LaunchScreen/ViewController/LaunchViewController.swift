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
    
    private let disposeBag = DisposeBag()
    
    // TODO: 메인화면에서 테마 변경기능 생기면 지우기
    private let button: UIButton = {
       
        let button = UIButton()
        button.setTitle("바뀌어라 얍", for: .normal)
        
        return button
    }()
    private let launchImage = BaseUIImageView(image: nil)

    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    override func configureBind() {
        button.rx.tap
            .bind(with: self) { owner, _ in
                
                let list: [ThemeSet] = [(.light, .primary), (.light, .secondary), (.dark, .primary), (.dark, .secondary)]
                
                CurrentTheme.currentTheme = list.randomElement()!
                print("버튼 클릭 후 테마: \(CurrentTheme.currentTheme)")
                
                owner.view.window?.overrideUserInterfaceStyle = CurrentTheme.currentTheme.theme.userInterfaceStyle
                
            }
            .disposed(by: disposeBag)
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
        
        button.setTitleColor(.label, for: .normal)
    }
    
    override func configureHierarchy() {
        view.addSubview(launchImage)
        view.addSubview(button)
        
    }
    
    override func configureLayout() {
        button.snp.makeConstraints {
            $0.top.horizontalEdges.equalTo(view.safeAreaLayoutGuide)
        }
        
        launchImage.snp.makeConstraints {
            $0.center.equalTo(view.safeAreaLayoutGuide)
        }
    }
}
