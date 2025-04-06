//
//  GNSwipeAnimation.swift
//  GNSwipeAnimation
//
//  Created by Lee Wonsun on 4/6/25.
//

import UIKit

public class GNSwipeGestureHandler {
    
    public enum SwipeDirection {
        case left
        case right
    }
    
    // 스와이프 진행 상태
    public enum SwipeState {
        case swiping(progress: CGFloat, direction: SwipeDirection)
        case completed(direction: SwipeDirection)
        case cancelled
    }
    
    public var swipeStateChanged: ((SwipeState) -> Void)?
    
    public var threshold: CGFloat = 0.3  // 스와이프 임계값
    
    public var allowedDirections: Set<SwipeDirection> = [.left, .right]
    
    private weak var targetView: UIView?
    private var panGestureRecognizer: UIPanGestureRecognizer?
    private var initialPoint: CGPoint = .zero
    
    public init(targetView: UIView) {
        self.targetView = targetView
        configGestureRecognizer(at: targetView)
    }
    
    private func configGestureRecognizer(at view: UIView) {
        
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(panGestureHandler(_:)))
        view.addGestureRecognizer(panGesture)
        view.isUserInteractionEnabled = true
        panGestureRecognizer = panGesture
    }
    
    @objc private func panGestureHandler(_ gesture: UIPanGestureRecognizer) {
        
        guard let view = targetView, let superView = view.superview else { return }
        
        let translation = gesture.translation(in: superView)
        let xFromCenter = translation.x
        let yFromCenter = translation.y
        
        switch gesture.state {
        case .began:
            initialPoint = view.center
            
        case .changed:  // 손으로 잡고 있는 동안의 변화 감지
            // 현재 카드의 위치
            view.center = CGPoint(x: initialPoint.x + xFromCenter, y: initialPoint.y + yFromCenter)
            
            // 어느 방향인지
            let direction: SwipeDirection = xFromCenter > 0 ? .right : .left
            let maxDistance = superView.bounds.width * threshold
            let progress = min(1.0, abs(xFromCenter) / maxDistance)
            
            guard allowedDirections.contains(direction) else { return }
            swipeStateChanged?(.swiping(progress: progress, direction: direction))
            
        case .ended:  // 손을 떼어냈을 때
            let screenWidth = superView.bounds.width
            let overThreshold = abs(xFromCenter) > screenWidth * threshold
            
            let direction: SwipeDirection = xFromCenter > 0 ? .right : .left
            
            guard overThreshold && allowedDirections.contains(direction) else {
                
                // 기준치만큼 이동하지 않았다면 제자리로
                view.center = initialPoint
                swipeStateChanged?(.cancelled)
                
                return
            }
            
            swipeStateChanged?(.completed(direction: direction))
            
        case .cancelled:
            view.center = initialPoint
            swipeStateChanged?(.cancelled)
            
        default: break
        }
    }

    public func cleanup() {
        if let panGesture = panGestureRecognizer, let view = targetView {
            view.removeGestureRecognizer(panGesture)
        }
        panGestureRecognizer = nil
        swipeStateChanged = nil
    }
}

