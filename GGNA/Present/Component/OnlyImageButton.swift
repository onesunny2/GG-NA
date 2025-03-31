//
//  OnlyImageButton.swift
//  GGNA
//
//  Created by Lee Wonsun on 3/31/25.
//

import UIKit

final class OnlyImageButton: UIButton {
    
    private var buttonImage: UIImage?
    
    override var isSelected: Bool {
        didSet {
            let theme = CurrentTheme.currentTheme.theme
            let color = CurrentTheme.currentTheme.color
            let colors = color.setColor(for: theme)
            
            configuration = isSelected ? configure(image: buttonImage, selected: colors.main) : configure(image: buttonImage, selected: colors.gray)
        }
    }
    
    init(image: UIImage?, isSelected: Bool) {
        super.init(frame: .zero)
        self.buttonImage = image
        self.isSelected = isSelected
    }
    
    private func configure(image: UIImage?, selected color: UIColor) -> Configuration {
        let imageConfig = UIImage.SymbolConfiguration(pointSize: 30)
        
        var config = UIButton.Configuration.filled()
        config.image = image?.withConfiguration(imageConfig)
        config.contentInsets = NSDirectionalEdgeInsets(top: .zero, leading: .zero, bottom: .zero, trailing: .zero)
        config.baseBackgroundColor = .clear
        config.baseForegroundColor = color
        
        return config
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
