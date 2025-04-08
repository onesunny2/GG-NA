//
//  FirstThemeCardView.swift
//  GGNA
//
//  Created by Lee Wonsun on 3/31/25.
//

import UIKit
import SnapKit

final class FirstThemeCardView: BaseView {
    
    private let cardView = BaseUIImageView(image: nil, cornerRadius: 30)
    private let cardCoverView = UIView()
    private let cardTitle = BaseUILabel(
        text: "",
        color: .ggDarkWhite,
        font: FontLiterals.normalCardTitle
    )
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    override func configureView() {
        
        cardView.transform = CGAffineTransform(rotationAngle: -CGFloat.pi / 60)

        layer.cornerRadius = 30
        layer.shadowColor = UIColor.ggSelected.cgColor
        layer.shadowOffset = CGSize(width: 2, height: 2)
        layer.shadowRadius = 5
        layer.shadowOpacity = 0.6
        layer.masksToBounds = false
        
        cardCoverView.cornerRadius30()
        cardCoverView.transform = CGAffineTransform(rotationAngle: -CGFloat.pi / 60)
        cardCoverView.backgroundColor = .ggImgCover.withAlphaComponent(0.3)
        
        cardTitle.transform = CGAffineTransform(rotationAngle: -CGFloat.pi / 60)
    }
    
    override func configureHierarchy() {
        addSubviews(cardView, cardCoverView, cardTitle)
    }
    
    override func configureLayout() {

        [cardView, cardCoverView].forEach {
            $0.snp.makeConstraints {
                $0.edges.equalToSuperview()
            }
        }
        
        cardTitle.snp.makeConstraints {
            $0.leading.equalTo(cardView.snp.leading).inset(35)
            $0.trailing.equalTo(cardView.snp.trailing).inset(5)
            $0.bottom.equalTo(cardView.snp.bottom).offset(-15)
        }
    }
    
    func setImage(_ data: HomePhotoCardEntity) {
        
        guard let image = data.imageData else {
            cardView.backgroundColor = .ggGray
            return
        }
        
        cardView.image = image
        cardTitle.text = data.cardTitle
    }
}
