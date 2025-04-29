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
    
    private let viewWillAppear = PublishRelay<Void>()
    private let changeFolder = PublishRelay<String>()
    
    private let changeButton = CustomBarButton(ImageLiterals.change)
    private let palleteButton = CustomBarButton(ImageLiterals.paintpalette)
    private let rightStackView = UIStackView()
    
    private let themeView = FirstThemeView()
    
    init(viewModel: HomeViewModel) {
        self.viewModel = viewModel
        super.init()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // 위젯에 처음에 기본폴더도 없으면 filemanager 복사하도록
        ShareDefaultsManager.shared.setupInitialSharedImages()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewWillAppear.accept(())
    }
    
    private func presentColorThemeSheet() {
        
        let modalVC = ThemeColorModalView()
        
        if let sheet = modalVC.sheetPresentationController {
            
            if #available(iOS 16.0, *) {
                let customDetent = UISheetPresentationController.Detent.custom { context in
                    // 화면 높이의 1/3 반환
                    return context.maximumDetentValue / 3
                }
                sheet.detents = [customDetent]
            } else {
                sheet.detents = [.medium()]
            }
            
            sheet.prefersGrabberVisible = true
            sheet.preferredCornerRadius = 20
        }
        
        present(modalVC, animated: true)
    }
    
    override func configureBind() {
        
        let input = HomeViewModel.Input(
            viewWillAppear: viewWillAppear.asObservable(),
            changeFolder: changeFolder.asObservable()
        )
        let output = viewModel.transform(from: input)
        
        output.currentPhotos
            .drive(with: self) { owner, photos in
                owner.themeView.setupCardViews(with: photos)
            }
            .disposed(by: disposeBag)
        
        output.currentFolders
            .drive(with: self) { owner, entities in
                
                owner.configureFolderMenu(entities) { folderName in
                    owner.changeFolder.accept(folderName)
                }
            }
            .disposed(by: disposeBag)
        
        palleteButton.rx.tap
            .bind(with: self) { owner, _ in
                owner.presentColorThemeSheet()
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
                owner.themeView.updateThemeColors(with: colors)
                owner.view.backgroundColor = colors.background
            }
            .disposed(by: disposeBag)
    }
    
    private func configureFolderMenu(_ entities: [HomeFolderEntity], completion: @escaping (String) -> ()) {
        
        var folderActions: [UIMenuElement] = []
        
        let savedFolder = SavingFolder.folder
        
        for entity in entities {
            let action = UIAction(title: entity.folderName, state: (entity.folderName == savedFolder) ? .on : .off) { _ in
                completion(entity.folderName)
            }
            
            folderActions.append(action)
        }
        
        let menu = UIMenu(title: StringLiteral.폴더변경.text, children: folderActions)
        changeButton.menu = menu
        changeButton.showsMenuAsPrimaryAction = true
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
        rightStackView.spacing = 12
    }
    
    override func configureHierarchy() {
        rightStackView.addArrangedSubviews(palleteButton, changeButton)
        view.addSubview(themeView)
    }
    
    override func configureLayout() {
        themeView.snp.makeConstraints {
            $0.edges.equalTo(view.safeAreaLayoutGuide)
        }
    }
}

extension HomeViewController {
    
    enum StringLiteral {
        case 폴더변경
        case 카드테마변경
        
        var text: String {
            switch self {
            case .폴더변경: return "사진폴더 변경"
            case .카드테마변경: return "카드테마 변경"  
            }
        }
    }
}
