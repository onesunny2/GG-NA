//
//  BaseUIButton.swift
//  GGNA
//
//  Created by Lee Wonsun on 4/11/25.
//

import UIKit

final class BaseUIButton: UIButton {
    
    init(image: UIImage?, foreground: UIColor, background: UIColor = .clear) {
        super.init(frame: .zero)
        
        var config = UIButton.Configuration.filled()
        config.baseForegroundColor = foreground
        config.baseBackgroundColor = background
        config.image = image
        config.contentInsets = NSDirectionalEdgeInsets(top: .zero, leading: .zero, bottom: .zero, trailing: .zero)
        configuration = config
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
