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
    private let cameraButton = setPhotoButton(
        icon: ImageLiterals.camera,
        title: uploadViewLiterals.카메라.text,
        backgroundColor: .systemPink
    )
    private let albumButton = setPhotoButton(
        icon: ImageLiterals.album,
        title: uploadViewLiterals.앨범.text,
        backgroundColor: .systemPink
    )
    private let zoomInIcon: CircularSymbolView // true 활성화
    private let zoomOutIcon: CircularSymbolView // false 활성화
    private let filterTitle: BaseUILabel
    private lazy var filterCollectionView = UICollectionView(frame: .zero, collectionViewLayout: createCollectionViewLayout())
    
    // 밝기 조절 관련 UI 요소
    private let filterSlider = CustomSlider(minValue: 0.0, maxValue: 1.0, initialValue: 0.5)
    private let brightnessIcon = BaseUIImageView(isCornered: false, image: ImageLiterals.filter)
    
    private var previousSelectedIndexPath: IndexPath = IndexPath(item: 0, section: 0)
    
    var tappedCameraButton = PublishRelay<Void>()
    var tappedAlbumButton = PublishRelay<Void>()
    var zoomStatus = PublishRelay<Bool>()
    var selectedFilter = BehaviorRelay(value: Filter.original)
    var filterValue = PublishRelay<CGFloat>()
    
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
            font: FontLiterals.subTitleBold
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
        cameraButton.isHidden = true
        albumButton.isHidden = true
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
                
                guard filter.effect != nil else {
                    owner.filterSlider.isHidden = true
                    return
                }
                
                guard let parameter = filter.parameter else { return }
                
                owner.filterSlider.updateRange(
                    minValue: parameter.minValue,
                    maxValue: parameter.maxValue,
                    initialValue: parameter.defaultValue,
                    animated: false
                )
                owner.filterValue.accept(parameter.defaultValue)
                owner.filterSlider.isHidden = false
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
        
        // 카메라 버튼 바인딩
        cameraButton.rx.tap
            .bind(with: self) { owner, _ in
                owner.tappedCameraButton.accept(())
            }
            .disposed(by: disposeBag)
        
        // 앨범 버튼 바인딩
        albumButton.rx.tap
            .bind(with: self) { owner, _ in
                owner.tappedAlbumButton.accept(())
            }
            .disposed(by: disposeBag)
        
        cardImageView.rx.tapgesture
            .withUnretained(self)
            .map { owner, _ in
                return owner.cardImageView.image != nil
            }
            .bind(with: self) { owner, value in
                guard value else { return }
                // 이미지가 있을 때 탭하면 확대/축소 전환
                let currentMode = owner.cardImageView.contentMode == .scaleAspectFill
                owner.zoomStatus.accept(!currentMode)
            }
            .disposed(by: disposeBag)
            
        // 슬라이더 값 변경 바인딩
        filterSlider.valueChanged
            .debounce(.milliseconds(10), scheduler: MainScheduler.instance)
            .bind(with: self) { owner, value in
                owner.filterValue.accept(value)
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
        
        // 밝기 관련 UI 설정
        brightnessIcon.tintColor = colors.main
        brightnessIcon.contentMode = .scaleAspectFit
        brightnessIcon.isHidden = true
        filterSlider.isHidden = true
    }
    
    override func configureHierarchy() {
        addSubviews(cardView, cardImageView, cameraButton, albumButton, zoomInIcon, zoomOutIcon, filterTitle, filterCollectionView, brightnessIcon, filterSlider)
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
        
        cameraButton.snp.makeConstraints {
            $0.centerX.equalTo(cardView)
            $0.centerY.equalTo(cardView).offset(-30)
            $0.width.equalTo(180)
            $0.height.equalTo(50)
        }
        
        albumButton.snp.makeConstraints {
            $0.centerX.equalTo(cardView)
            $0.top.equalTo(cameraButton.snp.bottom).offset(10)
            $0.width.equalTo(180)
            $0.height.equalTo(50)
        }
        
        zoomInIcon.snp.makeConstraints {
            $0.trailing.bottom.equalTo(cardView).inset(10)
            $0.size.equalTo(40)
        }
        
        zoomOutIcon.snp.makeConstraints {
            $0.trailing.bottom.equalTo(cardView).inset(10)
            $0.size.equalTo(40)
        }
        
        filterSlider.snp.makeConstraints {
            $0.centerY.equalTo(zoomOutIcon)
            $0.leading.equalTo(cardView.snp.leading).inset(16)
            $0.trailing.equalTo(zoomInIcon.snp.leading).offset(-15)
            $0.height.equalTo(30)
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
        case 카메라
        case 앨범
        case 필터
        
        var text: String {
            switch self {
            case .카메라: return "카메라"
            case .앨범: return "앨범"
            case .필터: return "필터"
            }
        }
    }
}
