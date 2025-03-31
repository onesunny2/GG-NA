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
    
    private let photoUploadView = UploadPhotoView()
    private let writingView = WritingView()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        photoUploadView.isHidden = false
        writingView.isHidden = true
        photoUploadView.transform = CGAffineTransform(translationX: photoUploadView.bounds.width, y: 0)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        view.endEditing(true)
    }

    override func configureBind() {
        
        photoUploadView.tappedUploadButton
            .bind(with: self) { owner, _ in
                print("tappedUploadButton") // TODO: 앨범 연결
            }
            .disposed(by: disposeBag)
        
        photoButton.rx.tap
            .bind(with: self) { owner, _ in
                guard !owner.photoButton.isSelected else { return }
                owner.photoButton.isSelected = true
                owner.writingButton.isSelected = false

                owner.photoUploadView.transform = CGAffineTransform(translationX: -owner.photoUploadView.bounds.width, y: 0)
                owner.photoUploadView.isHidden = false
                
                UIView.animate(withDuration: 0.3,
                    delay: 0.0,
                    options: [.curveEaseInOut],
                    animations: {
                        owner.writingView.transform = CGAffineTransform(translationX: owner.writingView.bounds.width, y: 0)
                        owner.photoUploadView.transform = .identity
                    }) { _ in
                        owner.writingView.isHidden = true
                        owner.writingView.transform = .identity
                    }
            }
            .disposed(by: disposeBag)

        writingButton.rx.tap
            .bind(with: self) { owner, _ in
                guard !owner.writingButton.isSelected else { return }
                owner.photoButton.isSelected = false
                owner.writingButton.isSelected = true
                
                owner.writingView.transform = CGAffineTransform(translationX: owner.writingView.bounds.width, y: 0)
                owner.writingView.isHidden = false
                
                UIView.animate(withDuration: 0.3,
                    delay: 0.0,
                    options: [.curveEaseInOut],
                    animations: {
                        owner.photoUploadView.transform = CGAffineTransform(translationX: -owner.photoUploadView.bounds.width, y: 0)
                        owner.writingView.transform = .identity
                    }) { _ in
                        owner.photoUploadView.isHidden = true
                        owner.photoUploadView.transform = .identity
                    }
            }
            .disposed(by: disposeBag)
        
        closeButton.rx.tap
            .bind(with: self) { owner, _ in
                owner.dismiss(animated: true)
            }
            .disposed(by: disposeBag)
    }

    override func configureNavigation() {
        
        let theme = CurrentTheme.currentTheme.theme
        let color = CurrentTheme.currentTheme.color
        let colors = color.setColor(for: theme)
        
        view.backgroundColor = colors.background
        
        navigationItem.title = NavigationTitle.카드생성.title
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: closeButton)
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: saveButton)
        
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .clear
        appearance.titleTextAttributes = [.foregroundColor: colors.text]
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
        closeButton.setTitleColor(colors.text, for: .normal)
        saveButton.setTitleColor(colors.text, for: .normal)
    }
    
    override func configureView() {
        switchStackView.axis = .horizontal
        switchStackView.spacing = 12
        switchStackView.alignment = .fill
    }
    
    override func configureHierarchy() {
        view.addSubviews(switchStackView, photoUploadView, writingView)
        switchStackView.addArrangedSubviews(photoButton, writingButton)
    }
    
    override func configureLayout() {
        
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first  else { return }
        
        switchStackView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide).inset(20)
            $0.centerX.equalTo(view.safeAreaLayoutGuide)
        }
        
        photoUploadView.snp.makeConstraints {
            $0.top.equalTo(switchStackView.snp.bottom).offset(20)
            $0.horizontalEdges.equalTo(view.safeAreaLayoutGuide)
            $0.height.equalTo(window.bounds.height / 2)
        }
        
        writingView.snp.makeConstraints {
            $0.top.equalTo(switchStackView.snp.bottom).offset(20)
            $0.horizontalEdges.bottom.equalTo(view.safeAreaLayoutGuide)
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
