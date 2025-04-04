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

    private let theme = CurrentTheme.currentTheme.theme
    private let color = CurrentTheme.currentTheme.color
    private lazy var colors = color.setColor(for: theme)
    
    private let cardView = UIView()
    private let cardImageView = BaseUIImageView(image: nil, cornerRadius: 15)
    private let uploadIcon = BaseUIImageView(isCornered: false, image: ImageLiterals.upload)
    private let uploadButton = TextFilledButton(title: uploadViewLiterals.사진올리기.text)
    private let zoomInIcon: CircularSymbolView // true 활성화
    private let zoomOutIcon: CircularSymbolView // false 활성화
    
    var tappedUploadButton = PublishRelay<Void>()
    var zoomStatus = PublishRelay<Bool>()
    
    override init(frame: CGRect) {
        
        let theme = CurrentTheme.currentTheme.theme
        let color = CurrentTheme.currentTheme.color
        let colors = color.setColor(for: theme)
        
        zoomInIcon = CircularSymbolView(
            symbol: ImageLiterals.zoomIn,
            symbolColor: colors.main
        )
        zoomOutIcon = CircularSymbolView(
            symbol: ImageLiterals.zoomOut,
            symbolColor: colors.main
        )
        
        super.init(frame: frame)
        bind()
    }
    
    func setImage(_ image: UIImage) {
        cardImageView.contentMode = .scaleAspectFill
        cardImageView.image = image
        uploadIcon.isHidden = true
        uploadButton.isHidden = true
        zoomOutIcon.isHidden = false
    }
    
    func setZoomIcon(_ status: Bool) {
       
        UIView.transition(with: self.cardImageView,
                          duration: 0.15,
                          options: .transitionCrossDissolve,
                          animations: {
           
            self.cardImageView.contentMode = status ? .scaleAspectFill : .scaleAspectFit
        }, completion: nil)
        
       
        UIView.transition(with: self.zoomInIcon,
                          duration: 0.2,
                          options: .transitionCrossDissolve,
                          animations: {
            self.zoomInIcon.isHidden = status ? true : false
        }, completion: nil)
        
        UIView.transition(with: self.zoomOutIcon,
                          duration: 0.2,
                          options: .transitionCrossDissolve,
                          animations: {
            self.zoomOutIcon.isHidden = status ? false : true
        }, completion: nil)
    }
    
    private func bind() {
        
        zoomOutIcon.rx.tapgesture
            .bind(with: self) { owner, _ in
                owner.zoomStatus.accept(false)
            }
            .disposed(by: disposeBag)
        
        zoomInIcon.rx.tapgesture
            .bind(with: self) { owner, _ in
                owner.zoomStatus.accept(true)
            }
            .disposed(by: disposeBag)
        
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
        
        cardView.backgroundColor = colors.text
        cardView.cornerRadius15()
        cardImageView.backgroundColor = .clear
        
        zoomInIcon.isHidden = true
        zoomOutIcon.isHidden = true
    }
    
    override func configureHierarchy() {
        addSubviews(cardView, cardImageView, uploadIcon, uploadButton, zoomInIcon, zoomOutIcon)
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
        
        zoomInIcon.snp.makeConstraints {
            $0.trailing.bottom.equalTo(cardView).inset(10)
            $0.size.equalTo(40)
        }
        
        zoomOutIcon.snp.makeConstraints {
            $0.trailing.bottom.equalTo(cardView).inset(10)
            $0.size.equalTo(40)
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
