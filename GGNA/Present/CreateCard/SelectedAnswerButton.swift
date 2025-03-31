//
//  SelectedAnswerButton.swift
//  GGNA
//
//  Created by Lee Wonsun on 3/31/25.
//

import UIKit

final class SelectedAnswerButton: UIButton {
    
    private var bgColor: UIColor?
    private var title: String?
    
    override var isSelected: Bool {
        didSet {
            let theme = CurrentTheme.currentTheme.theme
            let color = CurrentTheme.currentTheme.color
            let colors = color.setColor(for: theme)
            
            guard title == "날짜 선택하기" else {
                configuration = isSelected ? configure(title: title ?? "", bgColor: colors.main) : configure(title: title ?? "", bgColor: colors.gray)
                return
            }
            
            configuration = configure(title: title ?? "", bgColor: colors.main)
        }
    }
    
    init(title: String, bgColor: UIColor, isSelected: Bool) {
        super.init(frame: .zero)
        
        self.bgColor = bgColor
        self.title = title
        self.isSelected = isSelected
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
