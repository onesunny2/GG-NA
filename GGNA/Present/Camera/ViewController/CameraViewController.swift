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
    
    private let cameraManager: CameraManager
    private let videoView: VideoView
    
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
    
    let capturedImageRelay = PublishRelay<Data>()
    
    init(cameraManager: CameraManager, videoView: VideoView) {
        
        self.cameraManager = cameraManager
        self.videoView = videoView
        
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
        setupCamera()
    }
    
    private func setupCamera() {
        // 카메라 뷰에 VideoView 추가
        cameraView.addSubview(videoView)
        videoView.frame = cameraView.bounds
        videoView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        // 카메라 매니저 설정
        cameraManager.setupCamera(view: videoView)
    }
    
    override func configureBind() {
        
        captureButton.rx.tap
            .bind(with: self) { owner, _ in
                
                if let capturedImage = owner.cameraManager.takePhoto() {
                    
                    owner.capturedImageRelay.accept(capturedImage)
                    // 세션 다시 시작 (사진 촬영 후)
                    owner.cameraManager.startSession()
                }
                
                owner.dismiss(animated: true)
            }
            .disposed(by: disposeBag)
        
        changeModeButton.rx.tap
            .bind(with: self) { owner, _ in
                owner.cameraManager.changeDevicePotision()
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
    }
    
    override func configureView() {
        cameraView.backgroundColor = .clear
        captureBGView.backgroundColor = .clear
        captureBGView.layer.borderWidth = 1.5
        captureBGView.layer.cornerRadius = 32
        captureBGView.clipsToBounds = true
        appNameBGView.backgroundColor = .clear
        changeModeBGView.backgroundColor = .clear
    }
    
    private func configureSpecificView(colors: ColorSet) {
        view.backgroundColor = colors.background
        captureBGView.layer.borderColor = colors.text.cgColor
        bottomBarView.backgroundColor = colors.background.withAlphaComponent(0.7)
    }
    
    override func configureHierarchy() {
        view.addSubviews(cameraView, bottomBarView, appNameBGView, appNameLabel, captureBGView, captureButton, changeModeBGView, changeModeButton)
    }
    
    override func configureLayout() {
        cameraView.snp.makeConstraints {
            $0.edges.equalTo(view.snp.edges)
        }
        
        bottomBarView.snp.makeConstraints {
            $0.horizontalEdges.bottom.equalToSuperview()
            $0.height.equalTo(125)
        }
        
        appNameBGView.snp.makeConstraints {
            $0.leading.equalTo(view.safeAreaLayoutGuide)
            $0.trailing.equalTo(captureBGView.snp.leading)
            $0.centerY.equalTo(bottomBarView)
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
            $0.centerY.equalTo(bottomBarView)
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
