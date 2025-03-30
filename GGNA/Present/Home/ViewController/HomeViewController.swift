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
    
    private var dataSource: UICollectionViewDiffableDataSource<Int, HomePhotoCardEntity>!
    
    // Card swiping properties
    private var currentIndex = 0
    private var originalCardCenter: CGPoint = .zero
    private let throwingThreshold: CGFloat = 100.0
    private let rotationStrength: CGFloat = 320.0
    private var animator: UIDynamicAnimator?
    private var attachmentBehavior: UIAttachmentBehavior?
    private var snapBehavior: UISnapBehavior?
    
    init(viewModel: HomeViewModel) {
        self.viewModel = viewModel
        super.init()
        configureCollectionView()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupPanGesture()
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
        section.orthogonalScrollingBehavior = .groupPaging
        section.contentInsets = .zero
        section.interGroupSpacing = 200
        
        return UICollectionViewCompositionalLayout(section: section)
    }
    
    private func configureCollectionView() {
        dataSource = UICollectionViewDiffableDataSource<Int, HomePhotoCardEntity>(collectionView: collectionView) { collectionView, indexPath, entity in
            
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: HomeCollectionViewCell.identifier, for: indexPath) as? HomeCollectionViewCell else {
                return UICollectionViewCell()
            }
            
            cell.configureCell(entity)
            
            return cell
        }
    }

    
    private func applySnapshot(with photos: [HomePhotoCardEntity], animatingDifferences: Bool = true) {
        var snapshot = NSDiffableDataSourceSnapshot<Int, HomePhotoCardEntity>()
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
    
    // MARK: - Card Swiping Implementation
    
    private func setupPanGesture() {
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
        collectionView.addGestureRecognizer(panGesture)
        
        // Initialize dynamic animator
        animator = UIDynamicAnimator(referenceView: view)
    }
    
    @objc private func handlePan(_ gesture: UIPanGestureRecognizer) {
        guard let cell = collectionView.visibleCells.first else { return }
        let translation = gesture.translation(in: view)
        let velocity = gesture.velocity(in: view)
        
        switch gesture.state {
        case .began:
            originalCardCenter = cell.center
            
            // Remove existing behaviors
            if let attachmentBehavior = attachmentBehavior {
                animator?.removeBehavior(attachmentBehavior)
            }
            if let snapBehavior = snapBehavior {
                animator?.removeBehavior(snapBehavior)
            }
            
        case .changed:
            // Move card with pan
            cell.center = CGPoint(
                x: originalCardCenter.x + translation.x,
                y: originalCardCenter.y + translation.y
            )
            
            // Add rotation effect based on x-axis movement
            let rotationAngle = min(translation.x / rotationStrength, 1) * 0.25
            cell.transform = CGAffineTransform(rotationAngle: rotationAngle)
            
        case .ended, .cancelled:
            let throwDistance = translation.x
            
            // If swiped past threshold, throw the card away
            if abs(throwDistance) > throwingThreshold {
                throwCard(cell, with: velocity, to: throwDistance > 0 ? .right : .left)
            } else {
                // Otherwise, snap back to original position
                snapCardBack(cell)
            }
            
        default:
            break
        }
    }
    
    private enum ThrowDirection {
        case left, right
    }
    
    private func throwCard(_ card: UICollectionViewCell, with velocity: CGPoint, to direction: ThrowDirection) {
        // Calculate throw vector based on swipe direction and velocity
        let pushBehavior = UIPushBehavior(items: [card], mode: .instantaneous)
        
        let pushDirection: CGFloat = direction == .right ? 1.0 : -1.0
        pushBehavior.pushDirection = CGVector(dx: pushDirection, dy: 0)
        
        // Scale magnitude based on actual swipe velocity
        let velocityMagnitude = min(abs(velocity.x) / 500, 10)
        pushBehavior.magnitude = 20.0 * velocityMagnitude
        
        animator?.addBehavior(pushBehavior)
        
        // Add some rotation during the throw
        let rotationDirection = direction == .right ? 1.0 : -1.0
        UIView.animate(withDuration: 0.2) {
            card.transform = CGAffineTransform(rotationAngle: rotationDirection * 0.5)
        }
        
        // Show next card after animation
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] in
            guard let self = self else { return }
            
            self.moveToNextCard()
            self.animator?.removeAllBehaviors()
            card.transform = CGAffineTransform(rotationAngle: -CGFloat.pi / 60) // Reset to original rotation
        }
    }
    
    private func snapCardBack(_ card: UICollectionViewCell) {
        // Create snap behavior to return card to original position
        let snapBehavior = UISnapBehavior(item: card, snapTo: originalCardCenter)
        snapBehavior.damping = 0.7 // Add some bounce
        animator?.addBehavior(snapBehavior)
        self.snapBehavior = snapBehavior
        
        // Reset rotation with animation
        UIView.animate(withDuration: 0.3) {
            card.transform = CGAffineTransform(rotationAngle: -CGFloat.pi / 60) // Original collection view rotation
        }
    }
    
    private func moveToNextCard() {
        // Get current items from data source
        let photos = dataSource.snapshot().itemIdentifiers
        guard !photos.isEmpty else { return }
        
        // Increment index and handle wraparound
        currentIndex = (currentIndex + 1) % photos.count
        
        // Create new snapshot with reordered items
        var newSnapshot = NSDiffableDataSourceSnapshot<Int, HomePhotoCardEntity>()
        newSnapshot.appendSections([0])
        
        // Rotate the array so current index is at position 0
        var rotatedPhotos = photos
        if currentIndex > 0 {
            rotatedPhotos = Array(photos[currentIndex...] + photos[..<currentIndex])
        }
        
        newSnapshot.appendItems(rotatedPhotos, toSection: 0)
        
        // Apply the new snapshot
        dataSource.apply(newSnapshot, animatingDifferences: true)
    }
}
