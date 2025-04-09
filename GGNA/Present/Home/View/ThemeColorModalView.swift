//
//  ThemeColorModalView.swift
//  GGNA
//
//  Created by Lee Wonsun on 3/31/25.
//

import UIKit
import SnapKit
import RxCocoa
import RxSwift

final class ThemeColorModalView: BaseViewController {
    
    private let disposeBag = DisposeBag()
    
    private var isThemeChanging = false
    
    private let modalTitle: BaseUILabel
    private let closeButton = UIButton()
    private lazy var collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewLayout())
    private let colorItems = BehaviorRelay<[ThemeColorList]>(value: [.darkPink, .darkPurple, .lightPink])
    
    override init() {
        
        let theme = CurrentTheme.currentTheme.theme
        let color = CurrentTheme.currentTheme.color
        let colors = color.setColor(for: theme)
        
        modalTitle = BaseUILabel(
            text: NavigationTitle.테마색상.title,
            color: colors.text,
            font: FontLiterals.modalVCTitle
        )
        
        super.init()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    override func configureBind() {
        
        colorItems
            .bind(to: collectionView.rx.items(cellIdentifier: ThemeColorCollectionViewCell.identifier, cellType: ThemeColorCollectionViewCell.self)) { _, colorItem, cell in
               
                cell.configureCell(list: colorItem)
            }
            .disposed(by: disposeBag)
        
        collectionView.rx.modelSelected(ThemeColorList.self)
            .bind(with: self) { owner, item in
                
                owner.isThemeChanging = true
                
                var theme: Theme = .dark
                var color: ThemeColor = .primary
                
                switch item.theme {
                case "Dark": theme = .dark
                case "Light": theme = .light
                default: break
                }

                switch item.color {
                case .ggDarkPink: color = .primary
                case .ggLightPink: color = .primary
                case .ggDarkPurple: color = .secondary
                case .ggLightMint: color = .secondary
                default: break
                }
                
                CurrentTheme.currentTheme = (theme, color)
                CurrentTheme.applyCurrentTheme()
                
                Task {
                    try? await Task.sleep(nanoseconds: 1)
                    owner.isThemeChanging = false
                }
            }
            .disposed(by: disposeBag)
        
        closeButton.rx.tap
            .bind(with: self) { owner, _ in
                owner.dismiss(animated: true)
            }
            .disposed(by: disposeBag)
        
        CurrentTheme.$currentTheme
            .bind(with: self) { owner, value in
                
                let theme = value.theme
                let color = value.color
                let colors = color.setColor(for: theme)
                
                owner.view.backgroundColor = colors.background
                owner.modalTitle.textColor = colors.text
            }
            .disposed(by: disposeBag)
    }
    
override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        // 컬렉션뷰 높이에 맞게 레이아웃 업데이트
        updateCollectionViewLayout()
    }
    
    private func updateCollectionViewLayout() {
        
        guard !isThemeChanging else { return }
        
        // 현재 컬렉션뷰의 높이 가져오기
        let currentHeight = collectionView.frame.height
        
        // 새로운 레이아웃으로 교체
        collectionView.setCollectionViewLayout(createCompositionalLayout(collectionViewHeight: currentHeight), animated: false)
    }
    
    private func createCompositionalLayout(collectionViewHeight: CGFloat) -> UICollectionViewCompositionalLayout {
        let layout = UICollectionViewCompositionalLayout { _, _ in
            // 아이템 높이를 현재 컬렉션뷰 높이에 맞춤
            let itemHeight = collectionViewHeight
            
            // 너비도 높이와 동일하게 설정 (정사각형)
            let itemSize = NSCollectionLayoutSize(widthDimension: .absolute(itemHeight), heightDimension: .absolute(itemHeight))
            let item = NSCollectionLayoutItem(layoutSize: itemSize)
            
            let groupSize = NSCollectionLayoutSize(widthDimension: .absolute(itemHeight), heightDimension: .absolute(itemHeight))
            let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
            
            let section = NSCollectionLayoutSection(group: group)
            section.orthogonalScrollingBehavior = .continuous
            section.interGroupSpacing = 16
            section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 20)
            
            return section
        }
        
        return layout
    }
    
    override func configureView() {
        
        let imageConfig = UIImage.SymbolConfiguration(pointSize: 20, weight: .semibold)
        
        var config = UIButton.Configuration.filled()
        config.image = ImageLiterals.xmark?.withConfiguration(imageConfig)
        config.baseForegroundColor = .ggGray
        config.baseBackgroundColor = .clear
        config.contentInsets = NSDirectionalEdgeInsets(top: .zero, leading: .zero, bottom: .zero, trailing: .zero)
        
        closeButton.configuration = config
        
        collectionView.backgroundColor = .clear
        collectionView.showsHorizontalScrollIndicator = false
        
        collectionView.register(ThemeColorCollectionViewCell.self, forCellWithReuseIdentifier: ThemeColorCollectionViewCell.identifier)
    }
    
    override func configureHierarchy() {
        view.addSubviews(modalTitle, closeButton, collectionView)
    }
    
    override func configureLayout() {
        modalTitle.snp.makeConstraints {
            $0.top.leading.equalTo(view.safeAreaLayoutGuide).inset(20)
        }
        
        closeButton.snp.makeConstraints {
            $0.trailing.equalTo(view.safeAreaLayoutGuide).inset(20)
            $0.centerY.equalTo(modalTitle)
        }
        
        collectionView.snp.makeConstraints {
            $0.leading.trailing.equalTo(view.safeAreaLayoutGuide)
            $0.top.equalTo(modalTitle.snp.bottom).offset(32)
            $0.bottom.equalTo(view.safeAreaLayoutGuide).inset(20) // 하단 여백 20으로 설정
        }
    }
}
