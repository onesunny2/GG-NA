//
//  CustomBarButton.swift
//  GGNA
//
//  Created by Lee Wonsun on 3/30/25.
//

import UIKit

final class CustomBarButton: UIButton {
    
    init(_ image: UIImage?) {
        super.init(frame: .zero)
        
        let buttonImage = image
        setImage(buttonImage, for: .normal)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
