//
//  RoundedButton.swift
//  GGNA
//
//  Created by Lee Wonsun on 4/10/25.
//

import UIKit
import SnapKit

final class setPhotoButton: UIButton {
    
    private let iconImageView = UIImageView()
    private let buttonTitle = UILabel()
    private let arrowImageView = BaseUIImageView(isCornered: false, image: ImageLiterals.chevronRight)
    
    init(icon: UIImage?, title: String, backgroundColor: UIColor) {
        super.init(frame: .zero)

        iconImageView.image = icon
        buttonTitle.text = title

        configureView()
        configureHierarchy()
        configureLayout()
    }
    
    private func configureView() {
        
        let theme = CurrentTheme.currentTheme.theme
        let color = CurrentTheme.currentTheme.color
        let colors = color.setColor(for: theme)
        
        backgroundColor = colors.main80
        layer.cornerRadius = 10
        
        iconImageView.contentMode = .scaleAspectFit
        iconImageView.tintColor = .ggDarkWhite
        
        
        buttonTitle.textColor = .ggDarkWhite
        buttonTitle.font = FontLiterals.subTitleBold
        
        arrowImageView.contentMode = .scaleAspectFit
        arrowImageView.tintColor = .ggDarkWhite
    }
    
    private func configureHierarchy() {
        addSubviews(iconImageView, buttonTitle, arrowImageView)
    }
    
    private func configureLayout() {
        iconImageView.snp.makeConstraints {
            $0.leading.equalToSuperview().inset(16)
            $0.centerY.equalToSuperview()
            $0.size.equalTo(30)
        }
        
        buttonTitle.snp.makeConstraints {
            $0.leading.equalTo(iconImageView.snp.trailing).offset(10)
            $0.centerY.equalToSuperview()
        }
        
        arrowImageView.snp.makeConstraints {
            $0.trailing.equalToSuperview().inset(16)
            $0.centerY.equalToSuperview()
            $0.size.equalTo(20)
        }
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
