//
//  BaseView.swift
//  GGNA
//
//  Created by Lee Wonsun on 3/28/25.
//

import UIKit

class BaseView: UIView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        configureView()
        configureHierarchy()
        configureLayout()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configureView() { }
    
    func configureHierarchy() { }
    
    func configureLayout() { }
}
