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

final class CreateCardViewController: BaseViewController {

    private let viewModel: CreateCardViewModel
    private let disposeBag = DisposeBag()
    
    private let pickedImageData = PublishRelay<Data>()
    private let zoomStatus = PublishRelay<Bool>()
    private let selectedFilter = PublishRelay<FilterInfo>()
    
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
    
    private let photoBtnBgView = UIView()
    private let writingBtnView = UIView()
    
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
            pickedImageData: pickedImageData.asObservable(),
            tappedCloseButton: closeButton.rx.tap.asObservable(),
            inputTitleText: writingView.inputTitleText.asObservable(),
            tappedSaveButton: saveButton.rx.tap.asObservable(),
            isSelectedMainImage: writingView.isMainImage.asObservable(),
            selectedFolder: writingView.selectFolderButton.tappedSelectedFolder.asObservable(),
            inputDetailText: writingView.inputDetailText.asObservable(),
            zoomStatus: zoomStatus.asObservable(),
            isSecretMode: writingView.isSecretMode.asObservable(),
            filterInfo: selectedFilter.asObservable()
        )
        let output = viewModel.transform(from: input)
        
        output.downSampledImage
            .drive(with: self) { owner, image in
                owner.photoUploadView.switchCollectionViewHidden(isSelectedImg: true)
                owner.photoUploadView.setImage(image)
                owner.photoUploadView.pickedImage.accept(image)
                owner.photoUploadView.reloadCollectionView()
            }
            .disposed(by: disposeBag)
        
        Observable.combineLatest(
            pickedImageData,
            photoUploadView.selectedFilter,
            photoUploadView.filterValue
        )
        .bind(with: self) { owner, value in
            
            let imageData = value.0
            let filter = value.1
            let filterValue = value.2
            var image: UIImage?
            
            guard filter != .original else {
                image = ImageFilterManager.applyFilterFromData(filter, to: imageData)
                owner.photoUploadView.setImage(image)
                
                let filterInfo = FilterInfo(filter: filter, filterValue: 0.0)
                owner.selectedFilter.accept(filterInfo)
                
                return
            }
            
            image = ImageFilterManager.applyFilterFromData(filter, to: imageData, value: filterValue)
            
            owner.photoUploadView.setImage(image)
            
            guard filter.effect != nil else {
                let filterInfo = FilterInfo(filter: filter, filterValue: 0.0)
                owner.selectedFilter.accept(filterInfo)
                return
            }
            let filterInfo = FilterInfo(filter: filter, filterValue: filterValue)
            owner.selectedFilter.accept(filterInfo)
        }
        .disposed(by: disposeBag)
        
        writingView.selectFolderButton.tappedAddFolder  // 폴더 생성 눌렀을 때
            .bind(with: self) { owner, _ in
                owner.textFieldAlert { newName in
                    owner.writingView.selectFolderButton.addNewFolder(name: newName)
                }
            }
            .disposed(by: disposeBag)
        
        writingView.isMainImage
            .bind(with: self) { owner, value in
                
                guard value else { return }
                owner.customToast(type: .메인사진_설정)
            }
            .disposed(by: disposeBag)
        
        photoUploadView.zoomStatus
            .bind(with: self) { owner, status in
                owner.photoUploadView.setZoomIcon(status)
                owner.zoomStatus.accept(status)
            }
            .disposed(by: disposeBag)
        
        photoUploadView.tappedImageView
            .bind(with: self) { owner, _ in
                owner.openphotoPicker()
            }
            .disposed(by: disposeBag)
        
        photoUploadView.tappedAlbumButton
            .bind(with: self) { owner, _ in
                owner.openphotoPicker()
            }
            .disposed(by: disposeBag)
        
        photoUploadView.tappedCameraButton
            .bind(with: self) { owner, _ in
                
                let cm = CameraManager()
                let videoView = VideoView()
                let vc = CameraViewController(cameraManager: cm, videoView: videoView)
                
                vc.capturedImageRelay
                    .bind(with: self) { owner, image in
                        owner.zoomStatus.accept(true)
                        owner.pickedImageData.accept(image)
                    }
                    .disposed(by: owner.disposeBag)
                
                let nv = UINavigationController(rootViewController: vc)
                owner.viewTransition(type: .fullScreen, vc: nv)

            }
            .disposed(by: disposeBag)
        
        output.noChangedData
            .drive(with: self) { owner, _ in
                owner.dismiss(animated: true)
            }
            .disposed(by: disposeBag)
        
        output.yesChangedData
            .drive(with: self) { owner, _ in
                owner.closeButtonAlert()
            }
            .disposed(by: disposeBag)
        
        output.canSave
            .drive(with: self) { owner, value in
                
                switch value {
                case true:
                    print("저장완료")
                    owner.customToast(type: .카드저장_성공)
                case false:
                    print("저장실패")
                    owner.customToast(type: .카드저장_실패)
                }
            }
            .disposed(by: disposeBag)
        
        // MARK: UI
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
        
        photoBtnBgView.backgroundColor = .ggDarkWhite
        writingBtnView.backgroundColor = .ggDarkWhite
        photoBtnBgView.cornerRadius15()
        writingBtnView.cornerRadius15()
        
        switchStackView.axis = .horizontal
        switchStackView.spacing = 12
        switchStackView.alignment = .fill
    }
    
    override func configureHierarchy() {
        view.addSubviews(photoBtnBgView, writingBtnView, switchStackView, photoUploadView, writingView)
        switchStackView.addArrangedSubviews(photoButton, writingButton)
    }
    
    override func configureLayout() {
        
        switchStackView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide).inset(20)
            $0.centerX.equalTo(view.safeAreaLayoutGuide)
        }
        
        photoUploadView.snp.makeConstraints {
            $0.top.equalTo(switchStackView.snp.bottom).offset(20)
            $0.horizontalEdges.equalTo(view.safeAreaLayoutGuide)
            $0.bottom.equalTo(view.safeAreaLayoutGuide)
        }
        
        writingView.snp.makeConstraints {
            $0.top.equalTo(switchStackView.snp.bottom).offset(20)
            $0.horizontalEdges.bottom.equalTo(view.safeAreaLayoutGuide)
        }
        
        photoBtnBgView.snp.makeConstraints {
            $0.center.equalTo(photoButton)
            $0.size.equalTo(30)
            $0.bottom.lessThanOrEqualTo(view.keyboardLayoutGuide.snp.top).offset(-20)
        }
        
        writingBtnView.snp.makeConstraints {
            $0.center.equalTo(writingButton)
            $0.size.equalTo(30)
            $0.bottom.lessThanOrEqualTo(view.keyboardLayoutGuide.snp.top).offset(-20)
        }
    }
}

extension CreateCardViewController: PHPickerViewControllerDelegate {
    
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        
        guard let result = results.first else {
            print("선택한 이미지가 없습니다.")
            dismiss(animated: true)
            return
        }
        
        Task {
            do {
                let imageData = try await loadImageData(from: result.itemProvider)
                print("imageData: \(imageData)")
                
                zoomStatus.accept(true)
                // TODO: Data 결과값 반환 필요 ( 필터기능 업데이트 시 Data로 지지고볶아야 함 )
                pickedImageData.accept(imageData)
                
            } catch {
                print("이미지 데이터 로드 실패: \(error.localizedDescription)")
            }
            
            dismiss(animated: true)
        }
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
