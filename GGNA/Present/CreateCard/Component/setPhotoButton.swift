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
    private let titleLabel = UILabel()
    private let arrowImageView = UIImageView(image: UIImage(systemName: "chevron.right"))
    
    init(icon: UIImage, title: String, backgroundColor: UIColor) {
        super.init(frame: .zero)
        
        self.backgroundColor = backgroundColor
        layer.cornerRadius = 25
        
        // 아이콘 설정
        iconImageView.image = icon
        iconImageView.contentMode = .scaleAspectFit
        iconImageView.tintColor = .white
        
        // 타이틀 설정
        titleLabel.text = title
        titleLabel.textColor = .white
        titleLabel.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
        
        // 화살표 설정
        arrowImageView.contentMode = .scaleAspectFit
        arrowImageView.tintColor = .white
        
        // 뷰 계층 설정
        addSubviews(iconImageView, titleLabel, arrowImageView)
        
        // 레이아웃 설정
        iconImageView.snp.makeConstraints {
            $0.leading.equalToSuperview().inset(16)
            $0.centerY.equalToSuperview()
            $0.size.equalTo(24)
        }
        
        titleLabel.snp.makeConstraints {
            $0.leading.equalTo(iconImageView.snp.trailing).offset(10)
            $0.centerY.equalToSuperview()
        }
        
        arrowImageView.snp.makeConstraints {
            $0.trailing.equalToSuperview().inset(16)
            $0.centerY.equalToSuperview()
            $0.size.equalTo(20)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
