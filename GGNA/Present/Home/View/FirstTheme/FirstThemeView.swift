//
//  FirstThemeView.swift
//  GGNA
//
//  Created by Lee Wonsun on 4/7/25.
//

import UIKit
import GNSwipeAnimation
import SnapKit
import RxCocoa
import RxSwift

final class FirstThemeView: BaseView {
    
    private let bgCardView = UIView()
    private let firstCardView = FirstThemeCardView()
    private let secondCardView = FirstThemeCardView()
    
    private var cardSwipeManager: GNCardSwipeManager<FirstThemeCardView>!
    var addButtonStatus = PublishRelay<Bool>()
    
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
        
        cardSwipeManager.onCardChanged = { total, index in
            self.setCardNumbering(total: total, current: index)
        }
    }
    
    // viewController에서 데이터 전달받을 메서드
    func setupCardViews(with photos: [HomePhotoCardEntity]) {
        guard !photos.isEmpty else { return }
        
        if photos.count == 1,
           let firstPhoto = photos.first,
           firstPhoto.cardDate == "" {
        } else {
            setCardNumbering(total: photos.count, current: 0)
        }
        
        cardSwipeManager.setupWithData(photos)
    }
    
    func updateThemeColors(with colors: ColorSet) {
        bgCardView.backgroundColor = colors.main
    }
    
    private func setCardNumbering(total: Int, current index: Int) {
        let total = total
        let current = index + 1
        
        firstCardView.setCardNumber(total: total, current: current)
        secondCardView.setCardNumber(total: total, current: (current % total) + 1)
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
