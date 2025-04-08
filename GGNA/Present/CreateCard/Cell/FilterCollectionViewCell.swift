//
//  FilterCollectionViewCell.swift
//  GGNA
//
//  Created by Lee Wonsun on 4/8/25.
//

import UIKit
import SnapKit

final class FilterCollectionViewCell: UICollectionViewCell, ReusableIdentifier {
    
    private let defaultImageView = BaseUIImageView(isCornered: false, image: UIImage(resource: .ggnaDefault))
    private let selectedCoverView = UIView()
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
        selectedCoverView.isHidden = true
    }
    
    private func configureView() {
        backgroundColor = .clear
        selectedCoverView.isHidden = true
        defaultImageView.clipsToBounds = true
        filterNameBgView.backgroundColor = .ggDarkBlack.withAlphaComponent(0.7)
        
        let theme = CurrentTheme.currentTheme.theme
        let color = CurrentTheme.currentTheme.color
        let colors = color.setColor(for: theme)
        
        selectedCoverView.backgroundColor = colors.main.withAlphaComponent(0.4)
    }
    
    private func configureHierarchy() {
        contentView.addSubviews(defaultImageView, selectedCoverView, filterNameBgView,  filterName)
    }
    
    private func configureLayout() {
        defaultImageView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        selectedCoverView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        filterNameBgView.snp.makeConstraints {
            $0.horizontalEdges.bottom.equalToSuperview()
            $0.height.equalTo(30)
        }
        
        filterName.snp.makeConstraints {
            $0.center.equalTo(filterNameBgView)
        }
    }
    
    func configureCell(type: Filter) {
        filterName.text = type.koreanName
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
