//
//  UIStackView+.swift
//  GGNA
//
//  Created by Lee Wonsun on 3/28/25.
//

import UIKit

extension UIStackView {
    
    func addArrangedSubviews(_ views: UIView...) {
        for view in views {
            self.addArrangedSubview(view)
        }
    }
}
