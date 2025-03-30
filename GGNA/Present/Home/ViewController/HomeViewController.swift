//
//  HomeViewController.swift
//  GGNA
//
//  Created by Lee Wonsun on 3/30/25.
//

import UIKit
import SnapKit
import RxCocoa
import RxSwift

final class HomeViewController: BaseViewController {
    
    private let viewModel: HomeViewModel
    private let disposeBag = DisposeBag()
    
    private let suffleButton = CustomBarButton(ImageLiterals.shuffle)
    private let palleteButton = CustomBarButton(ImageLiterals.paintpalette)
    private let rightStackView = UIStackView()
    
    private let backCardView = UIView()
    private lazy var collectionView = UICollectionView(frame: .zero, collectionViewLayout: createLayout())
    
    private var dataSource: UICollectionViewDiffableDataSource<Int, PhotoCardRecord>!
    
    init(viewModel: HomeViewModel) {
        self.viewModel = viewModel
        super.init()
        configureCollectionView()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func configureBind() {
        
        let input = HomeViewModel.Input(
            viewDidLoad: Observable.just(())
        )
        let output = viewModel.transform(from: input)
        
        output.currentPhotos
            .drive(with: self) { owner, photos in
                print("photos count: \(photos.count)")
                owner.applySnapshot(with: photos)
            }
            .disposed(by: disposeBag)
        
        CurrentTheme.$currentTheme
            .bind(with: self) { owner, value in
                
                let theme = value.theme
                let color = value.color
                let colors = color.setColor(for: theme)
                
                let attribute: [NSAttributedString.Key: Any] = [.foregroundColor: colors.text]
                
                owner.view.backgroundColor = colors.background
                
                owner.navigationController?.navigationBar.largeTitleTextAttributes = attribute
                owner.navigationController?.navigationBar.tintColor = colors.text
                
                owner.backCardView.backgroundColor = colors.main
            }
            .disposed(by: disposeBag)
    }
    
    private func createLayout() -> UICollectionViewLayout {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .fractionalHeight(1.0)
        )
        
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .fractionalHeight(1.0)
        )
        
        let group = NSCollectionLayoutGroup.horizontal(
            layoutSize: groupSize,
            subitems: [item]
        )
        
        let section = NSCollectionLayoutSection(group: group)
        section.orthogonalScrollingBehavior = .none
        section.contentInsets = .zero
        section.interGroupSpacing = 0
        
        return UICollectionViewCompositionalLayout(section: section)
    }
    
    // 컬렉션 뷰 데이터 소스 설정
    private func configureCollectionView() {
        dataSource = UICollectionViewDiffableDataSource<Int, PhotoCardRecord>(collectionView: collectionView) { collectionView, indexPath, identifier in
            
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: HomeCollectionViewCell.identifier, for: indexPath) as? HomeCollectionViewCell else {
                return UICollectionViewCell()
            }
            
            return cell
        }
    }
    
    private func applySnapshot(with photos: [PhotoCardRecord], animatingDifferences: Bool = true) {
        var snapshot = NSDiffableDataSourceSnapshot<Int, PhotoCardRecord>()
        snapshot.appendSections([0])
        snapshot.appendItems(photos, toSection: 0)
        dataSource.apply(snapshot, animatingDifferences: animatingDifferences)
    }
    
    override func configureNavigation() {
        
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.title = NavigationTitle.홈.title
        
        let rightStackBarButtonItem = UIBarButtonItem(customView: rightStackView)
        navigationItem.rightBarButtonItem = rightStackBarButtonItem
    }

    override func configureView() {
        rightStackView.distribution = .equalSpacing
        rightStackView.axis = .horizontal
        rightStackView.alignment = .center
        rightStackView.spacing = 15
        
        backCardView.cornerRadius()
        backCardView.transform = CGAffineTransform(rotationAngle: CGFloat.pi / 60)
        
        collectionView.backgroundColor = .clear
        collectionView.isScrollEnabled = false
        collectionView.transform = CGAffineTransform(rotationAngle: -CGFloat.pi / 60)
        
        collectionView.register(HomeCollectionViewCell.self, forCellWithReuseIdentifier: HomeCollectionViewCell.identifier)
    }
    
    override func configureHierarchy() {
        
        view.addSubviews(backCardView, collectionView)
        rightStackView.addArrangedSubviews(suffleButton, palleteButton)
    }
    
    override func configureLayout() {
        
        backCardView.snp.makeConstraints {
            $0.centerX.equalTo(view.safeAreaLayoutGuide)
            $0.centerY.equalTo(view.safeAreaLayoutGuide).offset(17)
            $0.width.equalTo(view.snp.width).multipliedBy(0.8)
            $0.height.equalTo(view.snp.height).multipliedBy(0.6)
        }
        
        collectionView.snp.makeConstraints {
            $0.centerX.equalTo(view.safeAreaLayoutGuide)
            $0.centerY.equalTo(view.safeAreaLayoutGuide).offset(17)
            $0.width.equalTo(view.snp.width).multipliedBy(0.8)
            $0.height.equalTo(view.snp.height).multipliedBy(0.6)
        }
    }
}
