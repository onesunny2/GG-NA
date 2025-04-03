//
//  SelectedAnswerButton.swift
//  GGNA
//
//  Created by Lee Wonsun on 3/31/25.
//

import UIKit
import RealmSwift
import RxCocoa
import RxSwift

final class SelectedFolderButton: UIButton {
    
    private let realm = try! Realm()
    private let disposeBag = DisposeBag()
    
    private let theme = CurrentTheme.currentTheme.theme
    private let color = CurrentTheme.currentTheme.color
    private lazy var colors = color.setColor(for: theme)
    
    // 선택한 폴더
    private let selectedFolder = PublishRelay<String>()
    var tappedSelectedFolder: Observable<String> {
        return selectedFolder.asObservable()
    }
    
    // 폴더 추가
    private let addFolder = PublishRelay<Void>()
    var tappedAddFolder: Observable<Void> {
        return addFolder.asObservable()
    }
    
    init(title: String = "선택", bgColor: UIColor) {
        super.init(frame: .zero)
 
        configuration = configure(title: title, bgColor: bgColor)
        menu = setupMenu()
        showsMenuAsPrimaryAction = true
    }
    
    private func configure(title: String, bgColor: UIColor) -> Configuration {
        
        let container = AttributeContainer().font(FontLiterals.basicBadge15)
        
        var config = UIButton.Configuration.filled()
        config.attributedTitle = AttributedString(title, attributes: container)
        config.baseBackgroundColor = bgColor
        config.baseForegroundColor = colors.text
        config.contentInsets = NSDirectionalEdgeInsets(top: 12, leading: 20, bottom: 12, trailing: 20)
        config.cornerStyle = .small
        
        return config
    }
    
    private func setupMenu(selectedFolderName: String? = nil) -> UIMenu {

        let folders = realm.objects(Folder.self).sorted(byKeyPath: "folderName", ascending: true)
        
        var menuActions: [UIMenuElement] = []
        
        for folder in folders {
            
            let state: UIMenuElement.State = (folder.folderName == selectedFolderName) ? .on : .off
            
            let action = UIAction(title: folder.folderName, state: state) { [weak self] _ in
                guard let self else { return }
                
                self.selectedFolder.accept(folder.folderName)
                
                // 버튼 타이틀 추가
                var updatedConfig = self.configuration
                let container = AttributeContainer().font(FontLiterals.basicBadge15)
                updatedConfig?.attributedTitle = AttributedString(folder.folderName, attributes: container)
                updatedConfig?.baseBackgroundColor = colors.main80
                self.configuration = updatedConfig
            }
            
            menuActions.append(action)
        }
        
       // TODO: 구분선 추가
        
        let addFolderAction = UIAction(title: "+ 새로운 폴더 생성", image: UIImage(systemName: "folder.badge.plus")) { [weak self] _ in
            guard let self else { return }
            
            self.addFolder.accept(())  // TODO: alert 창에서 입력한 데이터 받도록 수정 필요
        }
        menuActions.append(addFolderAction)
        
        return UIMenu(title: "", options: [.displayInline, .singleSelection], children: menuActions)
    }
    
    func addNewFolder(name: String) {
        // Realm에 새 폴더 추가
        let newFolder = Folder(folderName: name, createFolderDate: Date(), photoCards: List<PhotoCardRecord>())
        try? realm.write {
            realm.add(newFolder)
        }
        
        // 버튼 타이틀 업데이트
        var updatedConfig = configuration
        let container = AttributeContainer().font(FontLiterals.basicBadge15)
        updatedConfig?.attributedTitle = AttributedString(name, attributes: container)
        updatedConfig?.baseBackgroundColor = colors.main80
        configuration = updatedConfig
        
        // 메뉴 업데이트
        menu = setupMenu(selectedFolderName: newFolder.folderName)
        selectedFolder.accept(newFolder.folderName)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
