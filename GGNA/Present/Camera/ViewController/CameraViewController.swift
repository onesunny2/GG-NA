//
//  CameraViewController.swift
//  GGNA
//
//  Created by Lee Wonsun on 4/10/25.
//

import UIKit
import SnapKit
import RxCocoa
import RxSwift

final class CameraViewController: BaseViewController {
    
    private let disposeBag = DisposeBag()
    
    private let closeButton: BaseUIButton

    private let cameraView = UIView()
    private let bottomBarView = UIView()
    private let appNameBGView = UIView()
    private let appNameLabel: BaseUILabel
    private let captureBGView = UIView()
    private let captureButton: BaseUIButton
    private let changeModeBGView = UIView()
    private let changeModeButton: BaseUIButton
    
    override init() {
        
        let theme = CurrentTheme.currentTheme.theme
        let color = CurrentTheme.currentTheme.color
        let colors = color.setColor(for: theme)
        
        closeButton = BaseUIButton(image: ImageLiterals.xmark, foreground: colors.text)
        
        appNameLabel = BaseUILabel(
            text: StringLiteral.앱이름.text,
            color: colors.main,
            alignment: .center,
            font: FontLiterals.cameraTitle
        )
        
        captureButton = BaseUIButton(
            image: ImageLiterals.circleFill,
            foreground: colors.main
        )
        
        changeModeButton = BaseUIButton(
            image: ImageLiterals.rotateCircleFill,
            foreground: colors.text
        )
        
        super.init()
        
        configureSpecificView(colors: colors)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func configureBind() {
        
        captureButton.rx.tap
            .bind(with: self) { owner, _ in
                owner.dismiss(animated: true)
            }
            .disposed(by: disposeBag)
        
        changeModeButton.rx.tap
            .bind(with: self) { owner, _ in
                print("tapped changemodebutton")
            }
            .disposed(by: disposeBag)
        
        closeButton.rx.tap
            .bind(with: self) { owner, _ in
                owner.dismiss(animated: true)
            }
            .disposed(by: disposeBag)
    }
    
    override func configureNavigation() {
        let leftBarButtonItem = UIBarButtonItem(customView: closeButton)
        navigationItem.leftBarButtonItem = leftBarButtonItem
        
        let theme = CurrentTheme.currentTheme.theme
        let color = CurrentTheme.currentTheme.color
        let colors = color.setColor(for: theme)
        
        let appearance = UINavigationBarAppearance()
        appearance.configureWithTransparentBackground()
        appearance.backgroundColor = colors.background.withAlphaComponent(0.7)
        
        appearance.shadowColor = .clear
        
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
        navigationController?.navigationBar.compactAppearance = appearance
    }
    
    override func configureView() {
        view.backgroundColor = .clear
        cameraView.backgroundColor = .ggDarkWhite  // TODO: 카메라 연결되면 clear로
        captureBGView.backgroundColor = .clear
        captureBGView.layer.borderWidth = 1.5
        captureBGView.layer.cornerRadius = 32
        captureBGView.clipsToBounds = true
        appNameBGView.backgroundColor = .clear
        changeModeBGView.backgroundColor = .clear
    }
    
    private func configureSpecificView(colors: ColorSet) {
        captureBGView.layer.borderColor = colors.text.cgColor
        bottomBarView.backgroundColor = colors.background.withAlphaComponent(0.7)
    }
    
    override func configureHierarchy() {
        view.addSubviews(cameraView, bottomBarView, appNameBGView, appNameLabel, captureBGView, captureButton, changeModeBGView, changeModeButton)
    }
    
    override func configureLayout() {
        cameraView.snp.makeConstraints {
            $0.edges.equalTo(view)
        }
        
        bottomBarView.snp.makeConstraints {
            $0.horizontalEdges.bottom.equalToSuperview()
            $0.height.equalTo(125)
        }
        
        appNameBGView.snp.makeConstraints {
            $0.leading.equalTo(view.safeAreaLayoutGuide)
            $0.trailing.equalTo(captureBGView.snp.leading)
            $0.height.equalTo(10)
        }
        
        appNameLabel.snp.makeConstraints {
            $0.centerX.equalTo(appNameBGView)
            $0.centerY.equalTo(bottomBarView)
        }
        
        captureBGView.snp.makeConstraints {
            $0.centerX.equalTo(view.safeAreaLayoutGuide)
            $0.centerY.equalTo(bottomBarView)
            $0.size.equalTo(64)
        }
        
        captureButton.snp.makeConstraints {
            $0.centerX.equalTo(view.safeAreaLayoutGuide)
            $0.centerY.equalTo(bottomBarView)
            $0.size.equalTo(54)
        }
        
        changeModeBGView.snp.makeConstraints {
            $0.trailing.equalTo(view.safeAreaLayoutGuide)
            $0.leading.equalTo(captureBGView.snp.trailing)
            $0.height.equalTo(10)
        }
        
        changeModeButton.snp.makeConstraints {
            $0.centerX.equalTo(changeModeBGView)
            $0.centerY.equalTo(bottomBarView)
            $0.size.equalTo(38)
        }
    }
}

extension CameraViewController {
    
    enum StringLiteral {
        case 앱이름
        case 화면나가기
        
        var text: String {
            switch self {
            case .앱이름: return "GG.NA"
            case .화면나가기: return "닫기"
            }
        }
    }
}
