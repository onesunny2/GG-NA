//
//  SelectedAnswerButton.swift
//  GGNA
//
//  Created by Lee Wonsun on 3/31/25.
//

import UIKit

final class SelectedAnswerButton: UIButton {
    
    init(title: String = "선택", bgColor: UIColor) {
        super.init(frame: .zero)
 
        configuration = configure(title: title, bgColor: bgColor)
    }
    
    private func configure(title: String, bgColor: UIColor) -> Configuration {
        
        let container = AttributeContainer().font(FontLiterals.basicBadge)
        
        var config = UIButton.Configuration.filled()
        config.attributedTitle = AttributedString(title, attributes: container)
        config.baseBackgroundColor = bgColor
        config.baseForegroundColor = .ggDarkWhite
        config.contentInsets = NSDirectionalEdgeInsets(top: 12, leading: 20, bottom: 12, trailing: 20)
        config.cornerStyle = .small
        
        return config
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
