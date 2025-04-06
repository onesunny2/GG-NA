//
//  FirstThemeView.swift
//  GGNA
//
//  Created by Lee Wonsun on 4/7/25.
//

import UIKit
import SnapKit

final class FirstThemeView: BaseView {
    
    let bgCardView = UIView()
    let firstCardView = FirstThemeCardView()
    let secondCardView = FirstThemeCardView()
    
    // 카드 스와이프를 위한 변수들
    private var cardViews: [FirstThemeCardView] = []
    private var currentCardIndex = 0
    private var currentPhotos: [HomePhotoCardEntity] = []
    
    // 스와이프 방향 열거형 정의
    private enum SwipeDirection {
        case left
        case right
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupSwipeGestures()
    }
    
    
    private func setupSwipeGestures() {
        cardViews = [firstCardView, secondCardView]
        
        // 각 카드에 스와이프 제스처 추가
        for cardView in cardViews {
            let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture))
            cardView.addGestureRecognizer(panGesture)
            cardView.isUserInteractionEnabled = true
        }
    }
    
    // 카드뷰 초기화
    func setupCardViews(with photos: [HomePhotoCardEntity]) {
        currentPhotos = photos
        currentCardIndex = 0
        
        // 모든 카드를 초기 상태로 리셋
        firstCardView.transform = CGAffineTransform.identity
        secondCardView.transform = CGAffineTransform.identity
        
        // 뒤에 있는 카드는 약간 작게 보이도록 설정
        secondCardView.transform = CGAffineTransform(rotationAngle: -CGFloat.pi / 60)
        secondCardView.alpha = 1.0
        
        // 첫 번째 카드 설정
        if photos.count > 0 {
            firstCardView.setImage(photos[0])
            firstCardView.transform = CGAffineTransform(rotationAngle: -CGFloat.pi / 60)
            firstCardView.alpha = 1.0
        }
        
        // 두 번째 카드 설정
        if photos.count > 1 {
            secondCardView.setImage(photos[1])
            secondCardView.isHidden = false
        } else {
            secondCardView.isHidden = true
        }
        
        // 첫 번째 카드가 앞에 오도록 설정
        bringCardToFront(cardView: firstCardView)
    }
    
    // 특정 카드를 앞으로 가져오기
    private func bringCardToFront(cardView: UIView) {
        bringSubviewToFront(cardView)
    }
    
    // 스와이프 제스처 처리
    @objc private func handlePanGesture(_ gesture: UIPanGestureRecognizer) {
        guard let card = gesture.view as? FirstThemeCardView else { return }
        
        // 맨 앞의 카드만 스와이프 가능하도록
        if card != cardViews[0] { return }
        
        let translation = gesture.translation(in: self)
        let xFromCenter = translation.x
        
        switch gesture.state {
        case .began:
            break
            
        case .changed:
            // 카드 이동 및 회전 처리
            let rotationAngle = xFromCenter / bounds.width * 0.4
            card.transform = CGAffineTransform(translationX: xFromCenter, y: translation.y)
                .rotated(by: rotationAngle)
            
            // 스와이프 방향에 따라 배경색 변경 효과 추가 가능
            
        case .ended:
            // 일정 거리 이상 스와이프 되었는지 확인
            if abs(xFromCenter) > 100 {
                // 스와이프 완료 애니메이션
                let screenWidth = bounds.width
                let directionMultiplier: CGFloat = xFromCenter > 0 ? 1 : -1
                let swipeDirection: SwipeDirection = xFromCenter > 0 ? .right : .left
                
                UIView.animate(withDuration: 0.3, animations: {
                    card.transform = CGAffineTransform(translationX: directionMultiplier * screenWidth * 1.5, y: 0)
                }) { _ in
                    // 스와이프 후 카드 완전 초기화
                    card.transform = CGAffineTransform.identity
                    self.showNextCard(direction: swipeDirection)
                }
            } else {
                // 제자리로 돌아가는 애니메이션 - 기본 회전값 유지
                UIView.animate(withDuration: 0.2) {
                    // 원래 회전값으로 복귀 (-CGFloat.pi / 60)
                    card.transform = CGAffineTransform(rotationAngle: -CGFloat.pi / 60)
                }
            }
            
        default:
            break
        }
    }
    
    // 다음 카드 표시
    private func showNextCard(direction: SwipeDirection = .right) {
        // 방향에 상관없이 항상 다음 사진으로 이동
        currentCardIndex += 1
        
        // 인덱스가 배열 범위를 벗어나면 처음으로 돌아가기
        if currentCardIndex >= currentPhotos.count {
            currentCardIndex = 0
        }
        
        // 모든 카드를 재설정
        for (index, cardView) in cardViews.enumerated() {
            // 먼저, 모든 변형을 초기화
            cardView.transform = CGAffineTransform.identity
            
            // 이미지 설정
            let photoIndex = (currentCardIndex + index) % max(currentPhotos.count, 1)
            
            if photoIndex < currentPhotos.count {
                cardView.isHidden = false
                cardView.setImage(currentPhotos[photoIndex])
                
                // 카드 위치별 스타일 설정
                if index == 0 {
                    // 첫 번째 카드 - 기본 회전만 적용
                    cardView.transform = CGAffineTransform(rotationAngle: -CGFloat.pi / 60)
                    cardView.alpha = 1.0
                } else {
                    // 두 번째 카드 - 회전 및 축소 적용
                    cardView.transform = CGAffineTransform(rotationAngle: -CGFloat.pi / 60)
                    cardView.alpha = 1.0
                }
                
                // 첫 번째 카드가 앞에 오도록 설정
                if index == 0 {
                    bringCardToFront(cardView: cardView)
                }
            } else {
                cardView.isHidden = true
            }
        }
    }
    
    func updateThemeColors(with colors: ColorSet) {
        bgCardView.backgroundColor = colors.main
    }
    
    override func configureView() {
        bgCardView.cornerRadius30()
        bgCardView.transform = CGAffineTransform(rotationAngle: CGFloat.pi / 60)
    }
    
    override func configureHierarchy() {
        addSubviews(bgCardView, secondCardView, firstCardView)
    }
    
    override func configureLayout() {
        bgCardView.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.centerY.equalToSuperview().offset(17)
            $0.horizontalEdges.equalToSuperview().inset(30)
            $0.height.equalTo(UIScreen.main.bounds.height * 0.55)
        }
        
        // 나머지 카드도 동일하게 설정
        secondCardView.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.centerY.equalToSuperview().offset(17)
            $0.horizontalEdges.equalToSuperview().inset(30)
            $0.height.equalTo(UIScreen.main.bounds.height * 0.55)
        }
        
        firstCardView.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.centerY.equalToSuperview().offset(17)
            $0.horizontalEdges.equalToSuperview().inset(30)
            $0.height.equalTo(UIScreen.main.bounds.height * 0.55)
        }
    }
}
