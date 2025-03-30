//
//  HomeCollectionViewCell.swift
//  GGNA
//
//  Created by Lee Wonsun on 3/30/25.
//

import UIKit
import SnapKit

final class HomeCollectionViewCell: UICollectionViewCell, ReusableIdentifier {
    
    private let imageView = BaseUIImageView(image: nil, cornerRadius: 30)
    private let imageCoverView = UIView()
    private let title = BaseUILabel(
        text: "",
        color: .ggDarkWhite,
        font: FontLiterals.normalCardTitle
    )
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        configureView()
        configureHierarchy()
        configureLayout()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        imageView.image = UIImage()
        title.text = ""
    }
    
    private func configureView() {
        backgroundColor = .clear
        imageCoverView.backgroundColor = .ggImgCover
        imageCoverView.cornerRadius()
    }
    
    private func configureHierarchy() {
        contentView.addSubviews(imageView, imageCoverView, title)
    }
    
    private func configureLayout() {
        imageView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        imageCoverView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        title.snp.makeConstraints {
            $0.horizontalEdges.equalToSuperview().inset(25)
            $0.bottom.equalToSuperview().inset(10)
        }
    }
    
    func configureCell(_ data: HomePhotoCardEntity) {
        
        imageView.image = data.imageData
        title.text = data.cardTitle
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
