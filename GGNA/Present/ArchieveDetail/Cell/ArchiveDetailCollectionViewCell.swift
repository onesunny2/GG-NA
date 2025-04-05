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
    
    private let checkBgView = UIView()
    private let checkImage = BaseUIImageView(isCornered: false, image: nil)
    
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
        checkImage.isHidden = true
        checkBgView.isHidden = true
    }
    
    private func configureView() {
        
        CurrentTheme.$currentTheme
            .bind(with: self) { owner, value in
                
                let theme = value.theme
                let color = value.color
                let colors = color.setColor(for: theme)
                
                owner.secretTitle.textColor = colors.text
                owner.secretSymbolImage.image = ImageLiterals.lockFill?.withTintColor(colors.main80, renderingMode: .alwaysOriginal)
                owner.checkBgView.layer.borderColor = colors.main.cgColor
                owner.checkImage.image = ImageLiterals.check?.withTintColor(colors.main, renderingMode: .alwaysOriginal)
            }
            .disposed(by: disposeBag)
        
        photoBgView.backgroundColor = .ggDarkWhite
        photoBgView.cornerRadius5()
        photoBgView.layer.shadowColor = UIColor.ggImgCover.cgColor
        photoBgView.layer.shadowOpacity = 0.6
        photoBgView.layer.shadowOffset = CGSize(width: 3, height: 3)
        photoBgView.layer.shadowRadius = 5
        photoBgView.layer.shouldRasterize = true
        photoBgView.layer.rasterizationScale = UIScreen.main.scale
        photoBgView.clipsToBounds = false
        
        secretBgView.backgroundColor = .ggSelected
        secretBgView.cornerRadius5()
        
        secretBgView.isHidden = true
        secretSymbolImage.isHidden = true
        
        blurEffectView.frame = secretBgView.bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        checkBgView.isHidden = true
        checkBgView.backgroundColor = .ggDarkBlack.withAlphaComponent(0.7)
        checkBgView.layer.borderWidth = 3
        checkBgView.cornerRadius5()
        checkImage.isHidden = true
    }
    
    private func configureHierarchy() {
        contentView.addSubviews(photoBgView, photoView, photoTitle, photoDate, secretBgView, secretSymbolImage, secretTitle, checkBgView, checkImage)
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
        
        checkBgView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        checkImage.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.size.equalTo(40)
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
    
    func selectedToDelete(isSelected: Bool) {
        checkBgView.isHidden = !isSelected
        checkImage.isHidden = !isSelected
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
