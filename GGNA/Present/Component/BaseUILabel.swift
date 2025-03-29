//
//  BaseUILabel.swift
//  GGNA
//
//  Created by Lee Wonsun on 3/29/25.
//

import UIKit

final class BaseUILabel: UILabel {
    
    init(
        text: String,
        color: UIColor,
        alignment: NSTextAlignment = .left,
        font: UIFont,
        line: Int = 1
    ) {
        super.init(frame: .zero)
        
        self.text = text
        self.textColor = color
        self.textAlignment = alignment
        self.numberOfLines = line
        self.font = font
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
