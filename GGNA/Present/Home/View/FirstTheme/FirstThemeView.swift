//
//  FirstThemeView.swift
//  GGNA
//
//  Created by Lee Wonsun on 4/7/25.
//

import UIKit
import GNSwipeAnimation
import SnapKit

final class FirstThemeView: BaseView {
    
    private let bgCardView = UIView()
    private let firstCardView = FirstThemeCardView()
    private let secondCardView = FirstThemeCardView()
    
    private var cardSwipeManager: GNCardSwipeManager<FirstThemeCardView>!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupCardSwipeManager()
    }
    
    // 카드 스와이프 매니저 설정
    private func setupCardSwipeManager() {
        // 카드 배열 생성
        let cards = [firstCardView, secondCardView]
        
        cardSwipeManager = GNCardSwipeManager(containerView: self, cardViews: cards)
        
        cardSwipeManager.configureCard = { (cardView, data, index) in
            guard let photo = data as? HomePhotoCardEntity else { return }
            cardView.setImage(photo)
        }
    }
    
    // viewController에서 데이터 전달받을 메서드
    func setupCardViews(with photos: [HomePhotoCardEntity]) {
        cardSwipeManager.setupWithData(photos)
    }
    
    func updateThemeColors(with colors: ColorSet) {
        bgCardView.backgroundColor = colors.main
    }
    
    override func configureView() {
        bgCardView.cornerRadius30()
        bgCardView.transform = CGAffineTransform(rotationAngle: CGFloat.pi / 90)
    }
    
    override func configureHierarchy() {
        addSubviews(bgCardView, secondCardView, firstCardView)
    }
    
    override func configureLayout() {
        bgCardView.snp.makeConstraints {
            $0.centerY.equalToSuperview().offset(17)
            $0.horizontalEdges.equalToSuperview().inset(40)
            $0.height.equalTo(UIScreen.main.bounds.height * 0.6)
        }
        
        // 나머지 카드도 동일하게 설정
        secondCardView.snp.makeConstraints {
            $0.centerY.equalToSuperview().offset(17)
            $0.horizontalEdges.equalToSuperview().inset(40)
            $0.height.equalTo(UIScreen.main.bounds.height * 0.6)
        }
        
        firstCardView.snp.makeConstraints {
            $0.centerY.equalToSuperview().offset(17)
            $0.horizontalEdges.equalToSuperview().inset(40)
            $0.height.equalTo(UIScreen.main.bounds.height * 0.6)
        }
    }
}
