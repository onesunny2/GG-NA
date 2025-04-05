//
//  ArchiveFolderCollectionViewCell.swift
//  GGNA
//
//  Created by Lee Wonsun on 4/1/25.
//

import UIKit
import SnapKit
import RxCocoa
import RxSwift

final class ArchiveFolderCollectionViewCell: UICollectionViewCell, ReusableIdentifier {
    
    private let disposeBag = DisposeBag()
    
    private let folderBgView = UIView()
    private let mainImageView = BaseUIImageView(image: nil)
    private let mainImageCoverView = UIView()
    private let folderMarkImage = BaseUIImageView(isCornered: false, image: nil)
    private let imageCountLabel = BaseUILabel(
        text: "",
        color: .ggDarkWhite,
        alignment: .right,
        font: FontLiterals.folderCount
    )
    private let folderTitle = BaseUILabel(
        text: "",
        color: .ggDarkWhite,
        font: FontLiterals.folderTitle
    )
    private let chevronImage = BaseUIImageView(isCornered: false, image: nil)
    
    private let secretBgView = UIView()
    private let blurEffectView: UIVisualEffectView
    private let secretSymbolImage: BaseUIImageView
    
    private let checkBgView = UIView()
    private let checkImage = BaseUIImageView(isCornered: false, image: nil)
    
    override init(frame: CGRect) {
        
        secretSymbolImage = BaseUIImageView(
            isCornered: false,
            image: ImageLiterals.lockFill?.withTintColor(.clear, renderingMode: .alwaysOriginal)
        )
        
        let blurEffect = UIBlurEffect(style: .regular)
        blurEffectView = UIVisualEffectView(effect: blurEffect)
        
        super.init(frame: frame)
        
        configureView()
        configureHierarchy()
        configureLayout()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        mainImageView.image = UIImage()
        imageCountLabel.text = ""
        folderTitle.text = ""
        secretBgView.isHidden = true
        secretSymbolImage.isHidden = true
        checkImage.isHidden = true
        checkBgView.isHidden = true
    }
    
    private func configureView() {
        
        folderBgView.cornerRadius5()
        
        mainImageView.cornerRadius5()
        mainImageCoverView.backgroundColor = .ggImgCover
        mainImageCoverView.cornerRadius5()
        
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
        
        CurrentTheme.$currentTheme
            .bind(with: self) { owner, value in
                
                let theme = value.theme
                let color = value.color
                let colors = color.setColor(for: theme)
                
                owner.folderBgView.backgroundColor = colors.text
                owner.folderMarkImage.image = ImageLiterals.bookmark?.withTintColor(colors.main, renderingMode: .alwaysOriginal)
                owner.chevronImage.image = ImageLiterals.chevronForwardCircle?.withTintColor(colors.main, renderingMode: .alwaysOriginal)
                owner.secretSymbolImage.image = ImageLiterals.lockFill?.withTintColor(colors.main80, renderingMode: .alwaysOriginal)
                owner.checkBgView.layer.borderColor = colors.main.cgColor
                owner.checkImage.image = ImageLiterals.check?.withTintColor(colors.main, renderingMode: .alwaysOriginal)
            }
            .disposed(by: disposeBag)
    }
    
    private func configureHierarchy() {
        contentView.addSubviews(folderBgView, mainImageView, mainImageCoverView, chevronImage, secretBgView, folderMarkImage, imageCountLabel, folderTitle, secretSymbolImage, checkBgView, checkImage)
        secretBgView.addSubview(blurEffectView)
    }
    
    private func configureLayout() {
        
        folderBgView.snp.makeConstraints {
            $0.top.equalToSuperview().inset(10)
            $0.horizontalEdges.bottom.equalToSuperview()
        }
        
        mainImageView.snp.makeConstraints {
            $0.leading.bottom.equalToSuperview().inset(5)
            $0.top.equalTo(folderBgView.snp.top).inset(5)
            $0.trailing.equalToSuperview().inset(30)
        }
        
        mainImageCoverView.snp.makeConstraints {
            $0.edges.equalTo(mainImageView)
        }
        
        secretBgView.snp.makeConstraints {
            $0.edges.equalTo(mainImageView)
        }
        
        secretSymbolImage.snp.makeConstraints {
            $0.centerX.equalTo(mainImageView)
            $0.centerY.equalTo(mainImageView)
            $0.width.equalTo(25)
            $0.height.equalTo(30)
        }
        
        folderMarkImage.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.leading.equalToSuperview().inset(12)
            $0.width.equalTo(10)
            $0.height.equalTo(35)
        }
        
        imageCountLabel.snp.makeConstraints {
            $0.top.equalTo(mainImageView.snp.top).inset(8)
            $0.trailing.equalTo(mainImageView.snp.trailing).inset(10)
            $0.leading.equalTo(folderMarkImage.snp.trailing).offset(12)
        }
        
        folderTitle.snp.makeConstraints {
            $0.horizontalEdges.bottom.equalTo(mainImageView).inset(8)
        }
        
        chevronImage.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.trailing.equalToSuperview().inset(5)
            $0.size.equalTo(20)
        }
        
        checkBgView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        checkImage.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.size.equalTo(40)
        }
    }
    
    func configureCell(_ data: ArchiveFolderEntity) {
        mainImageView.image = data.mainImage
        folderTitle.text = data.folderName
        imageCountLabel.text = data.photoCount
        
        guard data.secretMode else { return }
        secretBgView.isHidden = false
        secretSymbolImage.isHidden = false
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
