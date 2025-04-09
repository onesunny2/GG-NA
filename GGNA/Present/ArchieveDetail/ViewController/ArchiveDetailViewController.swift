//
//  ArchiveDetailViewController.swift
//  GGNA
//
//  Created by Lee Wonsun on 4/1/25.
//

import UIKit
import LocalAuthentication
import SnapKit
import RxCocoa
import RxSwift

private enum ArchiveDetailSection {
    case main
}

final class ArchiveDetailViewController: BaseViewController {
    
    private let viewModel: ArchiveDetailViewModel
    private let disposeBag = DisposeBag()
    
    private let deletePhotoButton = CustomBarButton(ImageLiterals.trashFill)
    
    private var isSelectionModeActive = false
    private var selectedPhotos = Set<FolderPhotosEntity>()
    private let deletePhotos = PublishRelay<[FolderPhotosEntity]>()
    private let viewWillAppear = PublishRelay<Void>()
    
    private lazy var collectionView = UICollectionView(frame: .zero, collectionViewLayout: createCompositionalLayout())
    private let emptyTitle: BaseUILabel
    
    private var dataSource: UICollectionViewDiffableDataSource<ArchiveDetailSection, FolderPhotosEntity>!
    
    init(viewModel: ArchiveDetailViewModel) {
        
        let theme = CurrentTheme.currentTheme.theme
        let color = CurrentTheme.currentTheme.color
        let colors = color.setColor(for: theme)
        
        emptyTitle = BaseUILabel(
            text: StringLiteral.noPhoto.text,
            color: colors.text,
            alignment: .center,
            font: FontLiterals.folderTitle,
            line: 0
        )
        
        self.viewModel = viewModel
        super.init()
        configureDataSource()
        emptyTitle.isHidden = true
    }

    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.prefersLargeTitles = false
        viewWillAppear.accept(())
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.navigationBar.prefersLargeTitles = true
    }
    
    override func configureBind() {
        
        let input = ArchiveDetailViewModel.Input(
            viewWillAppear: viewWillAppear.asObservable(),
            deletePhotos: deletePhotos.asObservable()
        )
        let output = viewModel.transform(from: input)
        
        output.photosData
            .drive(with: self, onNext: { owner, entity in
                owner.applySnapshot(with: entity)
                
                guard entity.isEmpty else {
                    owner.emptyTitle.isHidden = true
                    return
                }
                owner.emptyTitle.isHidden = false
            })
            .disposed(by: disposeBag)
        
        collectionView.rx.itemSelected
            .bind(with: self) { owner, indexPath in
                
                guard let entity = owner.dataSource.itemIdentifier(for: indexPath) else { return }
   
                switch owner.isSelectionModeActive {
                case true:
                    
                    if owner.selectedPhotos.contains(entity) {
                        owner.selectedPhotos.remove(entity)
                    } else {
                        owner.selectedPhotos.insert(entity)
                    }
                    
                    guard let cell = owner.collectionView.cellForItem(at: indexPath) as? ArchiveDetailCollectionViewCell else { return }
                    cell.selectedToDelete(isSelected: owner.selectedPhotos.contains(entity))
                    
                case false:
                    
                    switch entity.secretMode {
                    case true:
                        
                        guard let cell = owner.collectionView.cellForItem(at: indexPath) as? ArchiveDetailCollectionViewCell else { return }
                        
                        guard cell.isFaceIDUnlocked() else {
                            return
                        }
                        
                        Task {
                            let success = await owner.authenticateWithFaceID()
                            
                            if success {
                                
                                try? await Task.sleep(nanoseconds: 1_000_000_000)
                                
                                guard let cell = owner.collectionView.cellForItem(at: indexPath) as? ArchiveDetailCollectionViewCell else { return }
                                cell.openSecretMode()
                            }
                        }
                        
                    case false: break
                    }
                }
            }
            .disposed(by: disposeBag)
        
        deletePhotoButton.rx.tap
            .bind(with: self) { owner, _ in
                
                switch owner.isSelectionModeActive {
                case true:
                    if !owner.selectedPhotos.isEmpty {
                        // 한번 더 경고 문구로 삭제 할 것인지 물어보기
                        owner.deleteFoldersAlert {
                            owner.deletePhotos.accept(Array(owner.selectedPhotos))
                            owner.toggleSelectionMode()
                        }
                    } else {
                        owner.toggleSelectionMode()
                    }
                    
                case false:
                    owner.toggleSelectionMode()
                }
            }
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
    
    private func authenticateWithFaceID() async -> Bool {
        
        let context = LAContext()
        var error: NSError?
        
        context.localizedFallbackTitle = "비밀번호로 열람"
        context.localizedReason = StringLiteral.faceID.text
        context.interactionNotAllowed = false
        
        if context.canEvaluatePolicy(.deviceOwnerAuthentication, error: &error) {
            
            let reason = StringLiteral.faceID.text
            
            do {
                return try await context.evaluatePolicy(.deviceOwnerAuthentication, localizedReason: reason)
            } catch {
                
                return false
            }
            
        } else {
            return false
        }
    }
    
    private func toggleSelectionMode() {  // 데이터 삭제 모드에 진입하기 위함
        isSelectionModeActive = !isSelectionModeActive
        
        // 네비게이션 바 아이템 상태 변경
        if isSelectionModeActive {
            deletePhotoButton.setImage(ImageLiterals.minusFill, for: .normal)
            navigationItem.title = NavigationTitle.폴더삭제.title
        } else {
            deletePhotoButton.setImage(ImageLiterals.trashFill, for: .normal)
            navigationItem.title = viewModel.folder
            
            selectedPhotos.removeAll()
            
            for indexPath in collectionView.indexPathsForVisibleItems {
                if let cell = collectionView.cellForItem(at: indexPath) as? ArchiveDetailCollectionViewCell {
                    cell.selectedToDelete(isSelected: false)
                }
            }
        }
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
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: deletePhotoButton)
    }
    
    override func configureView() {
        collectionView.backgroundColor = .clear
        collectionView.showsVerticalScrollIndicator = false
        collectionView.register(ArchiveDetailCollectionViewCell.self, forCellWithReuseIdentifier: ArchiveDetailCollectionViewCell.identifier)
    }
    
    override func configureHierarchy() {
        view.addSubviews(collectionView, emptyTitle)
    }
    
    override func configureLayout() {
        collectionView.snp.makeConstraints {
            $0.edges.equalTo(view.safeAreaLayoutGuide)
        }
        
        emptyTitle.snp.makeConstraints {
            $0.center.equalTo(view.safeAreaLayoutGuide)
        }
    }
}

extension ArchiveDetailViewController {
    
    enum StringLiteral {
        case noPhoto
        case faceID
        
        var text: String {
            switch self {
            case .noPhoto: return "현재 등록한 추억이 아직 없습니다."
            case .faceID: return "잠긴 추억을 보기 위해 인증이 필요합니다."
            }
        }
    }
}
