//
//  UIImageView.swift
//  GGNA
//
//  Created by Lee Wonsun on 3/29/25.
//

import UIKit

final class BaseUIImageView: UIImageView {
    
    init(
        isCornered: Bool = true,
        image: UIImage?
    ) {
        super.init(frame: .zero)
        
        self.image = image
        contentMode = .scaleAspectFill
        
        guard isCornered else { return }
        layer.cornerRadius = 5
        clipsToBounds = true
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
