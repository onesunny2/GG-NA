//
//  TestViewController.swift
//  GGNA
//
//  Created by Lee Wonsun on 3/28/25.
//

import UIKit

import SnapKit
import RxSwift
import RxCocoa

final class TestViewController: UIViewController {
    
    private let disposBag = DisposeBag()
    
    private let button: UIButton = {
       
        let button = UIButton()
        button.setTitle("바뀌어라 얍", for: .normal)
        
        return button
    }()
    
    private let testView = UIView()
    private let testLabel = UILabel()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        configure()
        for family in UIFont.familyNames {
            print(family)
            
            for name in UIFont.fontNames(forFamilyName: family) {
                print(">>> \(name)")
            }
        }
    }

    func configure() {
        
        navigationController?.navigationBar.isHidden = true
        
        [button, testView, testLabel].forEach {
            view.addSubview($0)
        }
        
        
        button.snp.makeConstraints {
            $0.top.horizontalEdges.equalTo(view.safeAreaLayoutGuide)
        }
        
        testView.snp.makeConstraints {
            $0.centerY.equalTo(view.safeAreaLayoutGuide)
            $0.horizontalEdges.equalTo(view.safeAreaLayoutGuide)
            $0.height.equalTo(150)
        }
        
        testLabel.snp.makeConstraints {
            $0.center.equalTo(testView)
        }
        
        button.rx.tap
            .bind(with: self) { owner, _ in
                
                let list: [ThemeSet] = [(.light, .primary), (.light, .secondary), (.dark, .primary), (.dark, .secondary)]
                
                CurrentTheme.currentTheme = list.randomElement()!
                print("버튼 클릭 후 테마: \(CurrentTheme.currentTheme)")
                
                owner.view.window?.overrideUserInterfaceStyle = CurrentTheme.currentTheme.theme.userInterfaceStyle
                
            }
            .disposed(by: disposBag)
        
        testLabel.text = "현재 테마의 텍스트 색상입니다."
        testLabel.font = FontLiterals.folderCount
        testLabel.textColor = .label

        button.setTitleColor(.label, for: .normal)
        
        CurrentTheme.$currentTheme
            .bind(with: self) { this, value in
                
                let colors = value.color.setColor(for: value.theme)
                
                this.testLabel.textColor = colors.text
                this.testView.backgroundColor = colors.main
                this.view.backgroundColor = colors.background
            }
            .disposed(by: disposBag)
    }
}
