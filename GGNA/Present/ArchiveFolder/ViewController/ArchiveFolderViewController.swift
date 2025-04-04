//
//  ArchiveViewController.swift
//  GGNA
//
//  Created by Lee Wonsun on 4/1/25.
//

import UIKit
import SnapKit
import RxCocoa
import RxSwift

private enum ArchiveFolderSection {
    case main
}

final class ArchiveFolderViewController: BaseViewController {
    
    private let viewModel: ArchiveFolderViewModel
    private let disposeBag = DisposeBag()
    
    private let folderName = PublishRelay<String>()
    private let viewWillAppear = PublishRelay<Void>()
    
    private let addFolderButton = CustomBarButton(ImageLiterals.folderPlus)
    private lazy var collectionView = UICollectionView(frame: .zero, collectionViewLayout: createCompositionalLayout())
    private var dataSource: UICollectionViewDiffableDataSource<ArchiveFolderSection, ArchiveFolderEntity>!

    init(viewModel: ArchiveFolderViewModel) {
        self.viewModel = viewModel
        super.init()
        configureDataSource()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewWillAppear.accept(())
    }
    
    override func configureBind() {
        
        let input = ArchiveFolderViewModel.Input(
            viewWillAppear: viewWillAppear.asObservable(),
            newFolderName: folderName.asObservable()
        )
        let output = viewModel.transform(from: input)
        
        output.folderData
            .drive(with: self) { owner, entity in
                owner.applySnapshot(with: entity)
            }
            .disposed(by: disposeBag)
        
        output.completeSaveNewFolder
            .drive(with: self) { owner, entity in
                owner.applySnapshot(with: entity)
            }
            .disposed(by: disposeBag)
        
        collectionView.rx.itemSelected
            .bind(with: self) { owner, indexPath in
                
                guard let entity = owner.dataSource.itemIdentifier(for: indexPath) else { return }
                
                let rp = DummyArchiveFolderRepository()
                let vm = ArchiveDetailViewModel(repository: rp, folder: entity.folderName)
                let vc = ArchiveDetailViewController(viewModel: vm)
                owner.viewTransition(type: .navigation, vc: vc)
            }
            .disposed(by: disposeBag)
        
        addFolderButton.rx.tap
            .bind(with: self) { owner, _ in
                owner.textFieldAlert { name in
                    owner.folderName.accept(name)
                }
            }
            .disposed(by: disposeBag)
        
        CurrentTheme.$currentTheme
            .bind(with: self) { owner, value in
                
                let theme = value.theme
                let color = value.color
                let colors = color.setColor(for: theme)
                
                let attribute: [NSAttributedString.Key: Any] = [.foregroundColor: colors.text]
                
                owner.navigationController?.navigationBar.largeTitleTextAttributes = attribute
                owner.navigationController?.navigationBar.tintColor = colors.text
                owner.view.backgroundColor = colors.background
            }
            .disposed(by: disposeBag)
    }
    
    private func configureDataSource() {
        dataSource = UICollectionViewDiffableDataSource<ArchiveFolderSection, ArchiveFolderEntity>(collectionView: collectionView, cellProvider: { collectionView, indexPath, itemIdentifier in
            
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ArchiveFolderCollectionViewCell.identifier, for: indexPath) as? ArchiveFolderCollectionViewCell else { return UICollectionViewCell() }
            
            cell.configureCell(itemIdentifier)
            
            return cell
        })
    }
    
    private func applySnapshot(with items: [ArchiveFolderEntity]) {
        var snapshot = NSDiffableDataSourceSnapshot<ArchiveFolderSection, ArchiveFolderEntity>()
        snapshot.appendSections([.main])
        snapshot.appendItems(items, toSection: .main)
        
        dataSource.apply(snapshot, animatingDifferences: true)
    }
    
    private func createCompositionalLayout() -> UICollectionViewLayout {
       
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(0.5),
            heightDimension: .absolute(180)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .absolute(180)
        )
 
        let group = NSCollectionLayoutGroup.horizontal(
            layoutSize: groupSize,
            subitem: item,
            count: 2
        )
        group.interItemSpacing = .fixed(22)
        
        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = 5
        section.contentInsets = NSDirectionalEdgeInsets(
            top: .zero,
            leading: 20,
            bottom: .zero,
            trailing: 20
        )
        
        return UICollectionViewCompositionalLayout(section: section)
    }
    
    override func configureNavigation() {
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.largeTitleDisplayMode = .always
        navigationItem.title = NavigationTitle.보관함.title
        navigationItem.backButtonTitle = ""
        
        let rightBarButtonItem = UIBarButtonItem(customView: addFolderButton)
        navigationItem.rightBarButtonItem = rightBarButtonItem
    }
    
    override func configureView() {
        collectionView.backgroundColor = .clear
        collectionView.register(ArchiveFolderCollectionViewCell.self, forCellWithReuseIdentifier: ArchiveFolderCollectionViewCell.identifier)
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
