//
//  HomeCollectionViewCell.swift
//  GGNA
//
//  Created by Lee Wonsun on 3/30/25.
//

import UIKit

final class HomeCollectionViewCell: UICollectionViewCell, ReusableIdentifier {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .systemIndigo
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
