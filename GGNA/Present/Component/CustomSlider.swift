//
//  CustomSlider.swift
//  GGNA
//
//  Created by Lee Wonsun on 4/9/25.
//

import UIKit
import SnapKit
import RxCocoa
import RxSwift

final class CustomSlider: UIView {
    
    private let trackBackgroundView = UIView()
    private let trackFilledView = UIView()
    private let thumbView = UIView()
    
    private var minimumValue: CGFloat
    private var maximumValue: CGFloat
    private var currentValue: CGFloat
    
    private let thumbSize: CGFloat = 20
    private let barHeight: CGFloat = 12
    
    var valueChanged = PublishRelay<CGFloat>()
    
    init(minValue: CGFloat = 0.0, maxValue: CGFloat = 1.0, initialValue: CGFloat = 0.5) {
        self.minimumValue = minValue
        self.maximumValue = maxValue
        self.currentValue = initialValue
        
        super.init(frame: .zero)
        
        setupViews()
        setupConstraints()
        setupGestures()
        
        // 초기값으로 설정
        setValue(initialValue, animated: false)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup Methods
    private func setupViews() {
        // 트랙 배경 설정 - 굵기 증가
        trackBackgroundView.backgroundColor = .lightGray.withAlphaComponent(0.4)
        trackBackgroundView.layer.cornerRadius = barHeight / 2
        
        // 채워진 트랙 설정 (메인 컬러 사용)
        trackFilledView.backgroundColor = CurrentTheme.currentTheme.color.setColor(for: CurrentTheme.currentTheme.theme).main
        trackFilledView.layer.cornerRadius = barHeight / 2
        
        thumbView.backgroundColor = .white
        thumbView.layer.cornerRadius = thumbSize / 2
        thumbView.layer.shadowColor = UIColor.black.cgColor
        thumbView.layer.shadowOffset = CGSize(width: 0, height: 2)
        thumbView.layer.shadowRadius = 3
        thumbView.layer.shadowOpacity = 0.2
        
        addSubviews(trackBackgroundView, trackFilledView, thumbView)
    }
    
    private func setupConstraints() {
        trackBackgroundView.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.height.equalTo(barHeight)
            // 트랙의 시작과 끝 위치를 thumbView 크기의 절반만큼 inset
            $0.leading.equalToSuperview().offset(thumbSize / 2)
            $0.trailing.equalToSuperview().offset(-thumbSize / 2)
        }
        
        trackFilledView.snp.makeConstraints {
            $0.leading.height.centerY.equalTo(trackBackgroundView)
            $0.width.equalTo(0) // 초기값
        }
        
        thumbView.snp.makeConstraints {
            $0.width.height.equalTo(thumbSize)
            $0.centerY.equalTo(trackBackgroundView)
            $0.centerX.equalTo(trackFilledView.snp.trailing)
        }
    }
    
    private func setupGestures() {
        // 팬 제스처 추가
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture(_:)))
        thumbView.addGestureRecognizer(panGesture)
        thumbView.isUserInteractionEnabled = true
        
        // 탭 제스처 추가
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTapGesture(_:)))
        self.addGestureRecognizer(tapGesture)
    }
    
    // MARK: - Gesture Handlers
    @objc private func handlePanGesture(_ gesture: UIPanGestureRecognizer) {
        let touchLocation = gesture.location(in: self)
        updateValue(for: touchLocation.x)
    }
    
    @objc private func handleTapGesture(_ gesture: UITapGestureRecognizer) {
        let touchLocation = gesture.location(in: self)
        updateValue(for: touchLocation.x, animated: true)
    }
    
    private func updateValue(for xPosition: CGFloat, animated: Bool = false) {
        // 유효한 트랙 영역 계산 (썸 크기를 고려)
        let trackStart = trackBackgroundView.frame.minX
        let trackEnd = trackBackgroundView.frame.maxX
        
        // 위치 제한
        let clampedX = min(max(xPosition, trackStart), trackEnd)
        
        // 백분율 계산 (0.0 ~ 1.0)
        let percentage = (clampedX - trackStart) / (trackEnd - trackStart)
        let newValue = minimumValue + (maximumValue - minimumValue) * percentage
        
        setValue(newValue, animated: animated)
        valueChanged.accept(newValue)
    }
    
    func setValue(_ value: CGFloat, animated: Bool) {
        // 값 범위 제한
        currentValue = min(max(value, minimumValue), maximumValue)
        
        // 퍼센트 계산
        let percentage = (currentValue - minimumValue) / (maximumValue - minimumValue)
        let width = trackBackgroundView.bounds.width
        let fillWidth = width * percentage
        
        // UI 업데이트
        if animated {
            UIView.animate(withDuration: 0.2) {
                self.updateSliderUI(fillWidth: fillWidth)
            }
        } else {
            updateSliderUI(fillWidth: fillWidth)
        }
    }
    
    func updateRange(minValue: CGFloat, maxValue: CGFloat, initialValue: CGFloat, animated: Bool = true) {
        
        self.minimumValue = minValue
        self.maximumValue = maxValue
        
        setValue(initialValue, animated: animated)
    }
    
    private func updateSliderUI(fillWidth: CGFloat) {
        trackFilledView.snp.updateConstraints { make in
            make.width.equalTo(fillWidth)
        }
        
        self.layoutIfNeeded()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        // 레이아웃이 변경된 후 현재 값에 맞게 UI 업데이트
        let percentage = (currentValue - minimumValue) / (maximumValue - minimumValue)
        let width = trackBackgroundView.bounds.width
        let fillWidth = width * percentage
        
        trackFilledView.snp.updateConstraints { make in
            make.width.equalTo(fillWidth)
        }
    }
}
