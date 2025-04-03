//
//  TextFilledButton.swift
//  GGNA
//
//  Created by Lee Wonsun on 3/31/25.
//

import UIKit

final class TextFilledButton: UIButton {
    
    init(title: String) {
        super.init(frame: .zero)
        
        let theme = CurrentTheme.currentTheme.theme
        let color = CurrentTheme.currentTheme.color
        let colors = color.setColor(for: theme)
        
        let container = AttributeContainer().font(FontLiterals.basicBadge13)
        
        var config = UIButton.Configuration.filled()
        config.attributedTitle = AttributedString(title, attributes: container)
        config.baseForegroundColor = .ggDarkWhite
        config.baseBackgroundColor = colors.main80
        config.cornerStyle = .capsule
        
        configuration = config
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
