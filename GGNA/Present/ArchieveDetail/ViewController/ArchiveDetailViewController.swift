//
//  ArchiveDetailViewController.swift
//  GGNA
//
//  Created by Lee Wonsun on 4/1/25.
//

import UIKit
import SnapKit
import RxCocoa
import RxSwift

private enum ArchiveDetailSection {
    case main
}

final class ArchiveDetailViewController: BaseViewController {
    
    private let viewModel: ArchiveDetailViewModel
    private let disposeBag = DisposeBag()
    
    private lazy var collectionView = UICollectionView(frame: .zero, collectionViewLayout: createCompositionalLayout())
    private var dataSource: UICollectionViewDiffableDataSource<ArchiveDetailSection, FolderPhotosEntity>!
    
    init(viewModel: ArchiveDetailViewModel) {
        self.viewModel = viewModel
        super.init()
        configureDataSource()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.prefersLargeTitles = false
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.navigationBar.prefersLargeTitles = true
    }
    
    override func configureBind() {
        
        let input = ArchiveDetailViewModel.Input(
            viewDidLoad: Observable.just(())
        )
        let output = viewModel.transform(from: input)
        
        output.photosData
            .drive(with: self, onNext: { owner, entity in
                owner.applySnapshot(with: entity)
            })
            .disposed(by: disposeBag)
        
        CurrentTheme.$currentTheme
            .bind(with: self) { owner, value in
                
                let theme = value.theme
                let color = value.color
                let colors = color.setColor(for: theme)
                
                let attribute: [NSAttributedString.Key: Any] = [.foregroundColor: colors.text]
                
                owner.navigationController?.navigationBar.titleTextAttributes = attribute
                owner.navigationController?.navigationBar.tintColor = colors.text
                owner.view.backgroundColor = colors.background
            }
            .disposed(by: disposeBag)
    }
    
    private func configureDataSource() {
        dataSource = UICollectionViewDiffableDataSource<ArchiveDetailSection, FolderPhotosEntity>(
            collectionView: collectionView
        ) { collectionView, indexPath, item  in
            
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: ArchiveDetailCollectionViewCell.identifier,
                for: indexPath
            ) as? ArchiveDetailCollectionViewCell else {
                return UICollectionViewCell()
            }
            
            cell.configureCell(item)
            
            return cell
        }
    }

    private func applySnapshot(with items: [FolderPhotosEntity]) {
        var snapshot = NSDiffableDataSourceSnapshot<ArchiveDetailSection, FolderPhotosEntity>()
        snapshot.appendSections([.main])
        snapshot.appendItems(items, toSection: .main)
        
        dataSource.apply(snapshot, animatingDifferences: true)
    }
    
    private func createCompositionalLayout() -> UICollectionViewLayout {
       
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(0.5),
            heightDimension: .absolute(240)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .absolute(240)
        )
 
        let group = NSCollectionLayoutGroup.horizontal(
            layoutSize: groupSize,
            subitem: item,
            count: 2
        )
        group.interItemSpacing = .fixed(20)
        
        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = 10
        section.contentInsets = NSDirectionalEdgeInsets(
            top: 20,
            leading: 20,
            bottom: .zero,
            trailing: 20
        )
        
        return UICollectionViewCompositionalLayout(section: section)
    }
 
    override func configureNavigation() {
        navigationItem.title = viewModel.folder
    }
    
    override func configureView() {
        collectionView.backgroundColor = .clear
        collectionView.showsVerticalScrollIndicator = false
        collectionView.register(ArchiveDetailCollectionViewCell.self, forCellWithReuseIdentifier: ArchiveDetailCollectionViewCell.identifier)
    }
    
    override func configureHierarchy() {
        view.addSubview(collectionView)
    }
    
    override func configureLayout() {
        collectionView.snp.makeConstraints {
            $0.edges.equalTo(view.safeAreaLayoutGuide)
        }
    }
}
