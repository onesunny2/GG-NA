//
//  ThemeColorCollectionViewCell.swift
//  GGNA
//
//  Created by Lee Wonsun on 4/1/25.
//

import UIKit
import SnapKit
import RxCocoa
import RxSwift

final class ThemeColorCollectionViewCell: UICollectionViewCell, ReusableIdentifier {
    
    private let disposeBag = DisposeBag()
    
    private let themeColorView = UIView()
    private let shadowView = UIView()
    private let checkImageView = BaseUIImageView(image: ImageLiterals.check, cornerRadius: 18)
    private let themeBadgeView = UIButton()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        configureView()
        configureHierarchy()
        configureLayout()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        themeColorView.backgroundColor = .clear
        checkImageView.isHidden = true
    }
    
    private func configureView() {
        
        checkImageView.isHidden = true
        
        themeColorView.cornerRadius18()
        
        shadowView.cornerRadius18()
        shadowView.backgroundColor = .ggSelected
        
        let horizontalInset: CGFloat = 8
        let verticalInset: CGFloat = 6
        
        var config = UIButton.Configuration.filled()
        config.baseForegroundColor = .ggDarkWhite
        config.baseBackgroundColor = .ggSelected
        config.cornerStyle = .medium
        config.contentInsets = NSDirectionalEdgeInsets(top: verticalInset, leading: horizontalInset, bottom: verticalInset, trailing: horizontalInset)
        
        themeBadgeView.configuration = config
        themeBadgeView.isUserInteractionEnabled = false
    }
    
    private func configureHierarchy() {
        contentView.addSubviews(themeColorView, shadowView, checkImageView, themeBadgeView)
    }
    
    private func configureLayout() {
        themeColorView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        shadowView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        checkImageView.snp.makeConstraints {
            $0.size.equalTo(45)
            $0.center.equalToSuperview()
        }
        
        themeBadgeView.snp.makeConstraints {
            $0.top.trailing.equalToSuperview().inset(10)
        }
    }
    
    func configureCell(list: ThemeColorList) {
        
        let container = AttributeContainer().font(FontLiterals.themeBadge)
        
        themeColorView.backgroundColor = list.color
        themeBadgeView.configuration?.attributedTitle = AttributedString(list.theme, attributes: container)
        
        CurrentTheme.$currentTheme
            .bind(with: self) { owner, value in
                
                let theme = value.theme
                let color = value.color
                let colors = color.setColor(for: theme)
                
                guard (theme.rawValue == list.theme) && (colors.main == list.color) else {
                    owner.shadowView.isHidden = false
                    owner.checkImageView.isHidden = true
                    return
                }
                
                owner.shadowView.isHidden = true
                owner.checkImageView.isHidden = false
            }
            .disposed(by: disposeBag)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
