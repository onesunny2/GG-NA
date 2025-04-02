//
//  ArchiveDetailCollectionViewCell.swift
//  GGNA
//
//  Created by Lee Wonsun on 4/2/25.
//

import UIKit
import SnapKit

final class ArchiveDetailCollectionViewCell: UICollectionViewCell, ReusableIdentifier {
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = .systemIndigo
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
