//
//  ArchiveDetailCollectionViewCell.swift
//  GGNA
//
//  Created by Lee Wonsun on 4/2/25.
//

import UIKit
import SnapKit
import RxCocoa
import RxSwift

final class ArchiveDetailCollectionViewCell: UICollectionViewCell, ReusableIdentifier {
    
    private let disposeBag = DisposeBag()
    
    private let photoBgView = UIView()
    private let photoView = BaseUIImageView(image: nil)
    private let photoTitle = BaseUILabel(
        text: "",
        color: .ggLightBlack,
        font: FontLiterals.archivePhotoTitle
    )
    private let photoDate = BaseUILabel(
        text: "",
        color: .ggLightBlack,
        alignment: .right,
        font: FontLiterals.archivePhotoDate
    )
    private let secretBgView = UIView()
    private let blurEffectView: UIVisualEffectView
    private let secretSymbolImage: BaseUIImageView
    private let secretTitle: BaseUILabel
    
    override init(frame: CGRect) {
        
        secretSymbolImage = BaseUIImageView(
            isCornered: false,
            image: ImageLiterals.lockFill?.withTintColor(.clear, renderingMode: .alwaysOriginal)
        )
        
        secretTitle = BaseUILabel(
            text: "",
            color: .clear,
            alignment: .center,
            font: FontLiterals.archivePhotoTitle
        )
        
        let blurEffect = UIBlurEffect(style: .regular)
        blurEffectView = UIVisualEffectView(effect: blurEffect)
        
        super.init(frame: frame)

        configureHierarchy()
        configureLayout()
        configureView()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        photoView.image = UIImage()
        photoTitle.text = ""
        photoDate.text = ""
        secretTitle.text = ""
        secretBgView.isHidden = true
        secretSymbolImage.isHidden = true
    }
    
    private func configureView() {
        
        CurrentTheme.$currentTheme
            .bind(with: self) { owner, value in
                
                let theme = value.theme
                let color = value.color
                let colors = color.setColor(for: theme)
                
                owner.secretTitle.textColor = colors.text
                owner.secretSymbolImage.image = ImageLiterals.lockFill?.withTintColor(colors.main80, renderingMode: .alwaysOriginal)
            }
            .disposed(by: disposeBag)
        
        photoBgView.backgroundColor = .ggDarkWhite
        photoBgView.cornerRadius5()
        
        secretBgView.backgroundColor = .ggSelected
        secretBgView.cornerRadius5()
        
        secretBgView.isHidden = true
        secretSymbolImage.isHidden = true
        
        blurEffectView.frame = secretBgView.bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    }
    
    private func configureHierarchy() {
        contentView.addSubviews(photoBgView, photoView, photoTitle, photoDate, secretBgView, secretSymbolImage, secretTitle)
        secretBgView.addSubview(blurEffectView)
    }
    
    private func configureLayout() {
        photoBgView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        photoView.snp.makeConstraints {
            $0.top.horizontalEdges.equalToSuperview().inset(5)
            $0.height.equalToSuperview().multipliedBy(0.75)
        }
        
        photoTitle.snp.makeConstraints {
            $0.top.equalTo(photoView.snp.bottom).offset(10)
            $0.horizontalEdges.equalToSuperview().inset(5)
        }
        
        photoDate.snp.makeConstraints {
            $0.horizontalEdges.equalToSuperview().inset(5)
            $0.bottom.equalToSuperview().inset(8)
        }
        
        secretBgView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        secretSymbolImage.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.centerY.equalToSuperview().offset(-15)
            $0.width.equalTo(45)
            $0.height.equalTo(50)
        }
        
        secretTitle.snp.makeConstraints {
            $0.top.equalTo(secretSymbolImage.snp.bottom).offset(15)
            $0.horizontalEdges.equalToSuperview().inset(10)
        }
    }
    
    func configureCell(_ data: FolderPhotosEntity) {
        photoView.image = data.image
        photoTitle.text = data.title
        photoDate.text = data.date
        
        guard data.secretMode else { return }
        secretBgView.isHidden = false
        secretSymbolImage.isHidden = false
        secretTitle.text = data.title
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
