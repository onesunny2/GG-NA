//
//  CircularSymbolView.swift
//  GGNA
//
//  Created by Lee Wonsun on 4/2/25.
//

import UIKit
import SnapKit

final class CircularSymbolView: BaseView {
    
    private let backgroundView = UIView()
    private let symbolImageView = UIImageView()
    
    private let symbol: UIImage?
    private let symbolColor: UIColor
    private let backgroundFillColor: UIColor
    
    init(symbol: UIImage?,
         symbolColor: UIColor,
         backgroundFillColor: UIColor = .white) {
        
        self.symbol = symbol
        self.symbolColor = symbolColor
        self.backgroundFillColor = backgroundFillColor
        
        super.init(frame: .zero)
    }
    
    override func configureView() {
         
        backgroundView.backgroundColor = backgroundFillColor
        
        symbolImageView.contentMode = .scaleAspectFill
        symbolImageView.image = symbol?.withTintColor(symbolColor, renderingMode: .alwaysTemplate)
        symbolImageView.tintColor = symbolColor
     }
    
    override func configureHierarchy() {
        addSubview(symbolImageView)
        insertSubview(backgroundView, belowSubview: symbolImageView)
    }
    
    override func configureLayout() {
        
        symbolImageView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        backgroundView.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.width.height.equalToSuperview().multipliedBy(0.7)
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        // 크기가 변경될 때마다 cornerRadius 업데이트
        backgroundView.layer.cornerRadius = backgroundView.bounds.width / 2
    }
}
