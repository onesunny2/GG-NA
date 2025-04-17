//
//  FilterCollectionViewCell.swift
//  GGNA
//
//  Created by Lee Wonsun on 4/8/25.
//

import UIKit
import SnapKit

final class FilterCollectionViewCell: UICollectionViewCell, ReusableIdentifier {
    
    private let defaultImageView = BaseUIImageView(isCornered: false, image: nil)
    private let checkBgView = UIView()
    private let checkImage = BaseUIImageView(isCornered: false, image: nil)
    private let filterNameBgView = UIView()
    private let filterName = BaseUILabel(
        text: "",
        color: .ggDarkWhite,
        alignment: .center,
        font: FontLiterals.placeholder
    )
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        configureView()
        configureHierarchy()
        configureLayout()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        filterName.text = ""
    }
    
    private func configureView() {
        backgroundColor = .clear
        checkBgView.isHidden = true
        checkImage.isHidden = true
        defaultImageView.clipsToBounds = true
        filterNameBgView.backgroundColor = .ggDarkBlack.withAlphaComponent(0.7)
        
        let theme = CurrentTheme.currentTheme.theme
        let color = CurrentTheme.currentTheme.color
        let colors = color.setColor(for: theme)
        
        checkBgView.layer.borderWidth = 3
        checkBgView.layer.borderColor = colors.main.cgColor
        checkBgView.backgroundColor = .ggDarkBlack.withAlphaComponent(0.7)
        checkImage.image = ImageLiterals.check?.withTintColor(colors.main, renderingMode: .alwaysOriginal)
    }
    
    private func configureHierarchy() {
        contentView.addSubviews(defaultImageView, filterNameBgView, checkBgView, checkImage, filterName)
    }
    
    private func configureLayout() {
        defaultImageView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        checkBgView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        checkImage.snp.makeConstraints {
            $0.center.equalToSuperview()
        }
        
        filterNameBgView.snp.makeConstraints {
            $0.horizontalEdges.bottom.equalToSuperview()
            $0.height.equalTo(30)
        }
        
        filterName.snp.makeConstraints {
            $0.center.equalTo(filterNameBgView)
        }
    }
    
    func configureCell(type: Filter, selected image: UIImage) {
        
        let filteredImage = ImageFilterManager.applyFilterFromUIImage(type, to: image)
        
        defaultImageView.image = filteredImage
        filterName.text = type.koreanName
    }
    
    func configureSelectedFilter(status: Bool) {
        checkBgView.isHidden = status ? false : true
        checkImage.isHidden = status ? false : true
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
