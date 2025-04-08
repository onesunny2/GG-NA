//
//  UploadPhotoView.swift
//  GGNA
//
//  Created by Lee Wonsun on 3/31/25.
//

import UIKit
import SnapKit
import RxCocoa
import RxSwift

final class UploadPhotoView: BaseView {
    
    private let disposeBag = DisposeBag()

    private let theme = CurrentTheme.currentTheme.theme
    private let color = CurrentTheme.currentTheme.color
    private lazy var colors = color.setColor(for: theme)
    
    private let cardView = UIView()
    private let cardImageView = BaseUIImageView(image: nil, cornerRadius: 15)
    private let uploadIcon = BaseUIImageView(isCornered: false, image: ImageLiterals.upload)
    private let uploadButton = TextFilledButton(title: uploadViewLiterals.사진올리기.text)
    private let zoomInIcon: CircularSymbolView // true 활성화
    private let zoomOutIcon: CircularSymbolView // false 활성화
    private let filterTitle: BaseUILabel
    private lazy var filterCollectionView = UICollectionView(frame: .zero, collectionViewLayout: createCollectionViewLayout())
    
    private var previousSelectedIndexPath: IndexPath = IndexPath(item: 0, section: 0)
    
    var tappedUploadButton = PublishRelay<Void>()
    var zoomStatus = PublishRelay<Bool>()
    var selectedFilter = BehaviorRelay(value: Filter.original)
    
    override init(frame: CGRect) {
        
        let theme = CurrentTheme.currentTheme.theme
        let color = CurrentTheme.currentTheme.color
        let colors = color.setColor(for: theme)
        
        zoomInIcon = CircularSymbolView(
            symbol: ImageLiterals.zoomIn,
            symbolColor: colors.main
        )
        zoomOutIcon = CircularSymbolView(
            symbol: ImageLiterals.zoomOut,
            symbolColor: colors.main
        )
        filterTitle = BaseUILabel(
            text: uploadViewLiterals.필터.text,
            color: colors.text,
            font: FontLiterals.subTitle
        )
        
        super.init(frame: frame)
        bind()
        switchCollectionViewHidden(isSelectedImg: false)
    }
    
    func getCurrentImage() -> UIImage? {
        return cardImageView.image
    }
    
    func switchCollectionViewHidden(isSelectedImg: Bool) {
        filterCollectionView.isHidden = isSelectedImg ? false : true
        filterTitle.isHidden = isSelectedImg ? false : true
    }
    
    func setImage(_ image: UIImage?) {
        cardImageView.contentMode = .scaleAspectFill
        cardImageView.image = image
        uploadIcon.isHidden = true
        uploadButton.isHidden = true
        zoomOutIcon.isHidden = false
    }
    
    func setZoomIcon(_ status: Bool) {
       
        UIView.transition(with: self.cardImageView,
                          duration: 0.15,
                          options: .transitionCrossDissolve,
                          animations: {
           
            self.cardImageView.contentMode = status ? .scaleAspectFill : .scaleAspectFit
        }, completion: nil)
        
       
        UIView.transition(with: self.zoomInIcon,
                          duration: 0.2,
                          options: .transitionCrossDissolve,
                          animations: {
            self.zoomInIcon.isHidden = status ? true : false
        }, completion: nil)
        
        UIView.transition(with: self.zoomOutIcon,
                          duration: 0.2,
                          options: .transitionCrossDissolve,
                          animations: {
            self.zoomOutIcon.isHidden = status ? false : true
        }, completion: nil)
    }
    
    private func bind() {
        
        Observable.just(Filter.allCases)
            .bind(
                to: filterCollectionView.rx.items(
                    cellIdentifier: FilterCollectionViewCell.identifier,
                    cellType: FilterCollectionViewCell.self
                )
            ) { [weak self] index, item, cell in
                
                guard let self else { return }
                
                cell.configureCell(type: item)
                
                let isSelected = (self.selectedFilter.value == item)
                cell.configureSelectedFilter(status: isSelected)
            }
            .disposed(by: disposeBag)
        
        filterCollectionView.rx.modelSelected(Filter.self)
            .bind(with: self) { owner, filter in
                
                owner.selectedFilter.accept(filter)
                
                for cell in owner.filterCollectionView.visibleCells {
                    if let filterCell = cell as? FilterCollectionViewCell,
                       let indexPath = owner.filterCollectionView.indexPath(for: cell),
                       let item = try? owner.filterCollectionView.rx.model(at: indexPath) as Filter {
                        
                        let isSelected = (filter == item)
                        filterCell.configureSelectedFilter(status: isSelected)
                    }
                }
            }
            .disposed(by: disposeBag)
        
        zoomOutIcon.rx.tapgesture
            .bind(with: self) { owner, _ in
                owner.zoomStatus.accept(false)
            }
            .disposed(by: disposeBag)
        
        zoomInIcon.rx.tapgesture
            .bind(with: self) { owner, _ in
                owner.zoomStatus.accept(true)
            }
            .disposed(by: disposeBag)
        
        uploadButton.rx.tap
            .bind(with: self) { owner, _ in
                owner.tappedUploadButton.accept(())
            }
            .disposed(by: disposeBag)
        
        cardImageView.rx.tapgesture
            .withUnretained(self)
            .map { owner, _ in
                return owner.cardImageView.image != nil
            }
            .bind(with: self) { owner, value in
                guard value else { return }
                owner.tappedUploadButton.accept(())
            }
            .disposed(by: disposeBag)
    }
    
    private func createCollectionViewLayout() -> UICollectionViewLayout {
       
        let width = UIScreen.main.bounds.width
        
        let itemWidth = width / 3.5
        let itemHeight = itemWidth * 1.3

        let itemSize = NSCollectionLayoutSize(
            widthDimension: .absolute(itemWidth),
            heightDimension: .absolute(itemHeight)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)

        let groupSize = NSCollectionLayoutSize(
            widthDimension: .absolute(itemWidth),
            heightDimension: .absolute(itemHeight)
        )
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])

        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = 10
        section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 30, bottom: 0, trailing: 30)
        section.orthogonalScrollingBehavior = .continuous
        
        return UICollectionViewCompositionalLayout(section: section)
    }
    
    override func configureView() {
        
        backgroundColor = .clear
        
        cardView.backgroundColor = colors.text
        cardView.cornerRadius15()
        cardImageView.backgroundColor = .clear
        
        zoomInIcon.isHidden = true
        zoomOutIcon.isHidden = true
        
        filterCollectionView.backgroundColor = .clear
        filterCollectionView.showsHorizontalScrollIndicator = false
        filterCollectionView.register(FilterCollectionViewCell.self, forCellWithReuseIdentifier: FilterCollectionViewCell.identifier)
    }
    
    override func configureHierarchy() {
        addSubviews(cardView, cardImageView, uploadIcon, uploadButton, zoomInIcon, zoomOutIcon, filterTitle, filterCollectionView)
    }
    
    override func configureLayout() {
        
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first  else { return }
        
        cardView.snp.makeConstraints {
            $0.top.equalTo(safeAreaLayoutGuide)
            $0.horizontalEdges.equalTo(safeAreaLayoutGuide).inset(30)
            $0.height.equalTo(window.bounds.height / 2)
        }
        
        cardImageView.snp.makeConstraints {
            $0.edges.equalTo(cardView)
        }
        
        uploadIcon.snp.makeConstraints {
            $0.centerX.equalTo(safeAreaLayoutGuide)
            $0.centerY.equalTo(cardView).offset(-18)
            $0.size.equalTo(30)
        }
        
        uploadButton.snp.makeConstraints {
            $0.centerX.equalTo(safeAreaLayoutGuide)
            $0.centerY.equalTo(cardView).offset(18)
        }
        
        zoomInIcon.snp.makeConstraints {
            $0.trailing.bottom.equalTo(cardView).inset(10)
            $0.size.equalTo(40)
        }
        
        zoomOutIcon.snp.makeConstraints {
            $0.trailing.bottom.equalTo(cardView).inset(10)
            $0.size.equalTo(40)
        }
        
        filterTitle.snp.makeConstraints {
            $0.top.equalTo(cardView.snp.bottom).offset(24)
            $0.horizontalEdges.equalTo(safeAreaLayoutGuide).inset(30)
        }
        
        filterCollectionView.snp.makeConstraints {
            $0.top.equalTo(filterTitle.snp.bottom).offset(10)
            $0.horizontalEdges.equalTo(safeAreaLayoutGuide)
            $0.height.equalTo(UIScreen.main.bounds.width / 3.5 * 1.3)
        }
    }
}

extension UploadPhotoView {
    
    enum uploadViewLiterals {
        case 사진올리기
        case 필터
        
        var text: String {
            switch self {
            case .사진올리기: return "사진 올리기"
            case .필터: return "필터"
            }
        }
    }
}
