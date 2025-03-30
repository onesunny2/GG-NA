//
//  HomeCardView.swift
//  GGNA
//
//  Created by Lee Wonsun on 3/31/25.
//

import UIKit
import SnapKit

final class HomeCardView: BaseView {
    
    private let backgroundCardView = UIView()
    private let backCardView = BaseUIImageView(image: nil, cornerRadius: 30)
    private let backCardCoverView = UIView()
    private let frontCardView = BaseUIImageView(image: nil, cornerRadius: 30)
    private let frontCardCoverView = UIView()
    private let frontTitle = BaseUILabel(
        text: "",
        color: .ggDarkWhite,
        font: FontLiterals.normalCardTitle
    )
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    override func configureView() {
        
        backgroundCardView.cornerRadius()
        backgroundCardView.transform = CGAffineTransform(rotationAngle: CGFloat.pi / 60)
        
        backCardView.transform = CGAffineTransform(rotationAngle: -CGFloat.pi / 60)
        backCardView.backgroundColor = .white // TODO: 카드넘김 적용하면 삭제
        
        backCardCoverView.cornerRadius()
        backCardCoverView.transform = CGAffineTransform(rotationAngle: -CGFloat.pi / 60)
        backCardCoverView.backgroundColor = .ggImgCover
        
        frontCardView.transform = CGAffineTransform(rotationAngle: -CGFloat.pi / 60)
        
        frontCardCoverView.cornerRadius()
        frontCardCoverView.transform = CGAffineTransform(rotationAngle: -CGFloat.pi / 60)
        frontCardCoverView.backgroundColor = .ggImgCover
        
        frontTitle.transform = CGAffineTransform(rotationAngle: -CGFloat.pi / 60)
    }
    
    override func configureHierarchy() {
        addSubviews(backgroundCardView, backCardView, backCardCoverView, frontCardView, frontCardCoverView, frontTitle)
    }
    
    override func configureLayout() {

        [backgroundCardView, backCardView, backCardCoverView, frontCardView, frontCardCoverView].forEach {
            $0.snp.makeConstraints {
                $0.centerX.equalTo(safeAreaLayoutGuide)
                $0.centerY.equalTo(safeAreaLayoutGuide).offset(17)
                $0.width.equalTo(snp.width).multipliedBy(0.8)
                $0.height.equalTo(snp.height).multipliedBy(0.6)
            }
        }
        
        frontTitle.snp.makeConstraints {
            $0.leading.equalTo(frontCardView.snp.leading).inset(35)
            $0.trailing.equalTo(frontCardView.snp.trailing).inset(5)
            $0.bottom.equalTo(frontCardView.snp.bottom).offset(-15)
        }
    }
    
    func setColor(_ colorSet: ColorSet) {
        backgroundColor = colorSet.background
        backgroundCardView.backgroundColor = colorSet.main
        
    }
    
    func setImage(_ data: [HomePhotoCardEntity]) {
        
        guard !data.isEmpty else {
            frontCardView.backgroundColor = .ggGray
            return
        }
        
        frontCardView.image = data[0].imageData
        frontTitle.text = data[0].cardTitle
        backCardView.image = data[1].imageData
    }
}
