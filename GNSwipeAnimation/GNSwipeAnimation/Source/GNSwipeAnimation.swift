//
//  GNSwipeAnimation.swift
//  GNSwipeAnimation
//
//  Created by Lee Wonsun on 4/6/25.
//

import UIKit

public enum SwipeDirection {
    case left
    case right
}

public class GNCardSwipeManager<T: UIView> {
    
    private var cardContainerView: UIView
    private var cardViews: [T] = []
    private var currentCardIndex = 0
    private var dataSource: [Any] = []
    
    private var allowSwipeWithSingleItem: Bool = false
    
    public var onSwipe: ((Int, SwipeDirection) -> Void)?
    public var onCardChanged: ((Int) -> Void)?
    public var configureCard: ((T, Any, Int) -> Void)?
    
    // 내가 하려는 기본 카드의 속성으로 기본값 둠 (값의 수정은 직접 프로퍼티에 접근하지 않고 매서드로 변경시킴)
    private var maxRotationAngle: CGFloat = .pi / 10
    private var swipeThreshold: CGFloat = 150
    private var animationDuration: TimeInterval = 0.3
    private var stackedCardScale: CGFloat = 1.0
    private var stackedCardAlpha: CGFloat = 1.0
    private var initialCardRotation: CGFloat = -CGFloat.pi / 90
    
    public init(containerView: UIView, cardViews: [T]) {
        self.cardContainerView = containerView
        self.cardViews = cardViews
        
        setupCards()
    }
    
    // MARK: 개별 속성 조절
    public func setMaxRotationAngle(_ value: CGFloat) {
        maxRotationAngle = value
    }
    
    public func setswipeThreshold(_ value: CGFloat) {
        swipeThreshold = value
    }
    
    public func setanimationDuration(_ value: TimeInterval) {
        animationDuration = value
    }
    
    public func setstackedCardScale(_ value: CGFloat) {
        stackedCardScale = value
    }
    
    public func setstackedCardAlpha(_ value: CGFloat) {
        stackedCardAlpha = value
    }
    
    public func setinitialCardRotation(_ value: CGFloat) {
        initialCardRotation = value
    }
    
    // MARK: cardView 설정
    private func setupCards() {
        
        for cardView in cardViews {
            let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture))
            cardView.addGestureRecognizer(panGesture)
            cardView.isUserInteractionEnabled = true
        }
    }
    
    public func setupWithData(_ data: [Any]) {
        self.dataSource = data
        currentCardIndex = 0
        
        resetCards()
        
        for (index, cardView) in cardViews.enumerated() {
            if index < data.count {
                configureCard?(cardView, data[index], index)
                cardView.isHidden = false
                
                transformCard(cardView, at: index)
            } else {
                cardView.isHidden = true
            }
        }
        
        if data.count == 1 {
            for i in 1..<cardViews.count {
                cardViews[i].isHidden = true
            }
        }
        
        if let frontCard = cardViews.first {
            cardContainerView.bringSubviewToFront(frontCard)
        }
    }
    
    public func swipeCurrentCard(direction: SwipeDirection) {
        
        // 데이터 1개이면 스와이프 금지
        guard dataSource.count != 1 && !allowSwipeWithSingleItem else { return }
        
        guard let currentCard = cardViews.first else { return }
        
        let screenWidth = cardContainerView.bounds.width
        let directionMultiplier: CGFloat = (direction == .right) ? 1 : -1
        
        UIView.animate(withDuration: animationDuration, animations: {
            currentCard.transform = CGAffineTransform(translationX: directionMultiplier * screenWidth * 1.5, y: 0)
        }) { _ in
            
            currentCard.transform = CGAffineTransform.identity
            self.showNextCard(direction: direction)
        }
    }
    
    private func resetCards() {
        for cardView in cardViews {
            cardView.transform = CGAffineTransform.identity
            cardView.alpha = 1.0
        }
    }
    
    private func transformCard(_ cardView: T, at index: Int) {
       
        cardView.transform = CGAffineTransform.identity
        
        if index == 0 {
            
            cardView.transform = CGAffineTransform(rotationAngle: initialCardRotation)
            cardView.alpha = 1.0
        } else {
            
            cardView.transform = CGAffineTransform(rotationAngle: initialCardRotation)
                .scaledBy(x: stackedCardScale, y: stackedCardScale)
            cardView.alpha = stackedCardAlpha
        }
    }
    
    private func showNextCard(direction: SwipeDirection = .right) {

        // 1개의 데이터면 추가 카드 없음
        guard dataSource.count != 1 && !allowSwipeWithSingleItem else { return }
        
        currentCardIndex += 1
        
        if currentCardIndex >= dataSource.count {
            currentCardIndex = 0
        }
        
        onCardChanged?(currentCardIndex)
//        onSwipe?(currentCardIndex - 1, direction)
        
        for (index, cardView) in cardViews.enumerated() {
            
            let dataIndex = (currentCardIndex + index) % max(dataSource.count, 1)
            
            if dataIndex < dataSource.count {
                cardView.isHidden = false
                configureCard?(cardView, dataSource[dataIndex], dataIndex)
                
                transformCard(cardView, at: index)
            } else {
                cardView.isHidden = true
            }
            
            if index == 0 {
                cardContainerView.bringSubviewToFront(cardView)
            }
        }
    }
    
    @objc private func handlePanGesture(_ gesture: UIPanGestureRecognizer) {
        guard let card = gesture.view as? T,
              card == cardViews.first,
              !dataSource.isEmpty else { return }
        
        // 데이터 1개면 제스쳐 허용하지 않음
        guard dataSource.count != 1 && !allowSwipeWithSingleItem else { return }
        
        let translation = gesture.translation(in: cardContainerView)
        let xFromCenter = translation.x
        
        switch gesture.state {
        case .began:
            break
            
        case .changed:
            
            let rotationAngle = (xFromCenter / cardContainerView.bounds.width) * maxRotationAngle
             
             card.transform = CGAffineTransform(translationX: xFromCenter, y: translation.y)
                 .rotated(by: rotationAngle)
            
        case .ended, .cancelled:
            
            // 손가락을 뗀 후에만 임계값을 체크하여 카드 스와이프 여부 결정
             if abs(xFromCenter) > swipeThreshold {
                 
                 let screenWidth = cardContainerView.bounds.width
                 let direction: SwipeDirection = xFromCenter > 0 ? .right : .left
                 let directionMultiplier: CGFloat = xFromCenter > 0 ? 1 : -1
                 
                 UIView.animate(withDuration: animationDuration, animations: {
                     card.transform = CGAffineTransform(translationX: directionMultiplier * screenWidth * 1.5, y: 0)
                 }) { _ in
                     card.transform = CGAffineTransform.identity
                     self.showNextCard(direction: direction)
                 }
             } else {
                 // 임계값을 넘지 않았을 경우, 원래 위치로 되돌림
                 UIView.animate(withDuration: animationDuration) {
                     card.transform = CGAffineTransform(rotationAngle: self.initialCardRotation)
                 }
             }
            
        default:
            break
        }
    }
}
