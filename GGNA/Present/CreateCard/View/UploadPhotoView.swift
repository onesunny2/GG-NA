//
//  UploadPhotoView.swift
//  GGNA
//
//  Created by Lee Wonsun on 3/31/25.
//

import UIKit
import SnapKit
import RxCocoa
import RxSwift

final class UploadPhotoView: BaseView {
    
    private let disposeBag = DisposeBag()
    
    private let cardView = UIView()
    private let cardImageView = BaseUIImageView(image: nil, cornerRadius: 15)
    private let uploadIcon = BaseUIImageView(isCornered: false, image: ImageLiterals.upload)
    private let uploadButton = TextFilledButton(title: uploadViewLiterals.사진올리기.text)
    
    var tappedUploadButton = PublishRelay<Void>()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        bind()
    }
    
    func setImage(_ image: UIImage) {
        cardImageView.image = image
        uploadIcon.isHidden = true
        uploadButton.isHidden = true
    }
    
    private func bind() {
        uploadButton.rx.tap
            .bind(with: self) { owner, _ in
                owner.tappedUploadButton.accept(())
            }
            .disposed(by: disposeBag)
        
        cardImageView.rx.tapgesture
            .withUnretained(self)
            .map { owner, _ in
                return owner.cardImageView.image != nil
            }
            .bind(with: self) { owner, value in
                guard value else { return }
                owner.tappedUploadButton.accept(())
            }
            .disposed(by: disposeBag)
    }
    
    override func configureView() {
        
        let theme = CurrentTheme.currentTheme.theme
        let color = CurrentTheme.currentTheme.color
        let colors = color.setColor(for: theme)
        
        cardView.backgroundColor = colors.text
        cardView.cornerRadius15()
        cardImageView.backgroundColor = .clear
    }
    
    override func configureHierarchy() {
        addSubviews(cardView, cardImageView, uploadIcon, uploadButton)
    }
    
    override func configureLayout() {
        
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first  else { return }
        
        cardView.snp.makeConstraints {
            $0.top.equalTo(safeAreaLayoutGuide)
            $0.horizontalEdges.equalTo(safeAreaLayoutGuide).inset(30)
            $0.height.equalTo(window.bounds.height / 2)
        }
        
        cardImageView.snp.makeConstraints {
            $0.edges.equalTo(cardView)
        }
        
        uploadIcon.snp.makeConstraints {
            $0.centerX.equalTo(safeAreaLayoutGuide)
            $0.centerY.equalTo(safeAreaLayoutGuide).offset(-18)
            $0.size.equalTo(30)
        }
        
        uploadButton.snp.makeConstraints {
            $0.centerX.equalTo(safeAreaLayoutGuide)
            $0.centerY.equalTo(safeAreaLayoutGuide).offset(18)
        }
    }
}

extension UploadPhotoView {
    
    enum uploadViewLiterals {
        case 사진올리기
        case 필터
        
        var text: String {
            switch self {
            case .사진올리기: return "사진 올리기"
            case .필터: return "필터􀆈"
            }
        }
    }
}
