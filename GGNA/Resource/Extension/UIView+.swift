//
//  UIView+.swift
//  GGNA
//
//  Created by Lee Wonsun on 3/28/25.
//

import UIKit

extension UIView {
    
    func addSubviews(_ views: UIView...) {
        views.forEach {
            self.addSubview($0)
        }
    }
    
    func cornerRadius() {
        layer.cornerRadius = 30
        clipsToBounds = true
    }
}
