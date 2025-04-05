//
//  SelectedMainImageButton.swift
//  GGNA
//
//  Created by Lee Wonsun on 4/3/25.
//

import UIKit

final class SelectedMainImageButton: UIButton {
    
    override var isSelected: Bool {
        didSet {
            
            let theme = CurrentTheme.currentTheme.theme
            let color = CurrentTheme.currentTheme.color
            let colors = color.setColor(for: theme)
            
            configuration = isSelected ? configureButton(colors.main, isSelected: isSelected) : configureButton(colors.text, isSelected: isSelected)
        }
    }
    
    init() {
        super.init(frame: .zero)
        isSelected = false
    }
    
    private func configureButton(_ color: UIColor, isSelected: Bool) -> UIButton.Configuration {
        
        let buttonContainer = AttributeContainer().font(FontLiterals.basicBadge13)
        let buttonConfig = UIImage.SymbolConfiguration(pointSize: 10, weight: .bold)
        
        var config = UIButton.Configuration.filled()
        config.attributedTitle = AttributedString(Literal.메인카드설정.text, attributes: buttonContainer)
        config.image = isSelected ? ImageLiterals.checkMark?.withConfiguration(buttonConfig) :  ImageLiterals.square?.withConfiguration(buttonConfig)
        config.baseBackgroundColor = .clear
        config.baseForegroundColor = color
        config.imagePlacement = .leading
        config.imagePadding = 2
        config.contentInsets = NSDirectionalEdgeInsets(top: .zero, leading: .zero, bottom: .zero, trailing: .zero)
        
        return config
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        isSelected.toggle()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension SelectedMainImageButton {
    
    enum Literal {
        case 메인카드설정
        
        var text: String {
            switch self {
            case .메인카드설정: "폴더의 메인카드로 설정"
            }
        }
    }
}
