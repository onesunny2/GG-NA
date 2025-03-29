//
//  BaseViewController.swift
//  GGNA
//
//  Created by Lee Wonsun on 3/28/25.
//

import UIKit

class BaseViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureBind()
        configureNavigation()
        configureView()
        configureHierarchy()
        configureLayout()
    }
    
    init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    deinit {
        print("\(String(describing: type(of: self))) - deinit")
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configureBind() { }
    
    func configureNavigation() { }
    
    func configureView() { }
    
    func configureHierarchy() { }
    
    func configureLayout() { }
}

