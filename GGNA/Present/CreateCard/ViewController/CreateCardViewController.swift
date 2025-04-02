//
//  CreateCardViewController.swift
//  GGNA
//
//  Created by Lee Wonsun on 3/31/25.
//

import UIKit
import PhotosUI
import SnapKit
import RxCocoa
import RxSwift
import UniformTypeIdentifiers

final class CreateCardViewController: BaseViewController {
    
    private let viewModel: CreateCardViewModel
    private let disposeBag = DisposeBag()
    private let pickedImageData = PublishRelay<Data>()
    
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

    init(viewModel: CreateCardViewModel) {
        self.viewModel = viewModel
        super.init()
    }
    
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
        
        let input = CreateCardViewModel.Input(
            pickedImageData: pickedImageData.asObservable()
        )
        let output = viewModel.transform(from: input)
        
        photoUploadView.tappedUploadButton
            .bind(with: self) { owner, _ in
                owner.openphotoPicker()
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
    
    private func openphotoPicker() {
        var configuration = PHPickerConfiguration()
        configuration.filter = .images
        configuration.selectionLimit = 1
        // MARK: mode 사용하려면 17+ 가능
        
        let picker = PHPickerViewController(configuration: configuration)
        picker.delegate = self
        present(picker, animated: true)
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

extension CreateCardViewController: PHPickerViewControllerDelegate {
    
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        
        guard let result = results.first else {
            print("선택한 이미지가 없습니다.")
            return
        }
        
        Task {
            do {
                let imageData = try await loadImageData(from: result.itemProvider)
                print("imageData: \(imageData)")
                // TODO: Data 결과값 반환 필요
                pickedImageData.accept(imageData)
                
            } catch {
                print("이미지 데이터 로드 실패: \(error.localizedDescription)")
            }
        }
        
        dismiss(animated: true)
    }
    
    private func loadImageData(from itemProvider: NSItemProvider) async throws -> Data {
        return try await withCheckedThrowingContinuation { continuation in
            
            let typeIdentifier = UTType.image.identifier
            
            itemProvider.loadDataRepresentation(forTypeIdentifier: typeIdentifier) { (data, error) in
                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }
                
                guard let imageData = data else {
                    continuation.resume(throwing: NSError(domain: "ImageLoadError", code: -1, userInfo: [NSLocalizedDescriptionKey: "이미지 데이터를 로드할 수 없습니다."]))
                    return
                }
                
                continuation.resume(returning: imageData)
            }
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
