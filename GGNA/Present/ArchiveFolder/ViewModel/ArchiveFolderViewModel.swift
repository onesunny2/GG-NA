//
//  ArchiveFolderViewModel.swift
//  GGNA
//
//  Created by Lee Wonsun on 4/1/25.
//

import Foundation
import RealmSwift
import RxCocoa
import RxSwift

final class ArchiveFolderViewModel: InputOutputModel {
    
    struct Input {
        let viewWillAppear: Observable<Void>
        let newFolderName: Observable<String>
    }
    
    struct Output {
        let folderData: Driver<[ArchiveFolderEntity]>
        let completeSaveNewFolder: Driver<[ArchiveFolderEntity]>
    }
    
    private let repository: ArchiveFolderRepository
    private let disposeBag = DisposeBag()
    
    init(repository: ArchiveFolderRepository) {
        self.repository = repository
    }
    
    func transform(from input: Input) -> Output {
        
        let folderData = BehaviorRelay<[ArchiveFolderEntity]>(value: repository.getFolderInfo())
        let completeSaveNewFolder = BehaviorRelay<[ArchiveFolderEntity]>(value: repository.getFolderInfo())
        
        input.viewWillAppear
            .bind(with: self) { owner, _ in
                folderData.accept(owner.repository.getFolderInfo())
            }
            .disposed(by: disposeBag)
        
        input.newFolderName
            .bind(with: self) { owner, name in
                owner.addNewFolder(name: name)
                completeSaveNewFolder.accept(owner.repository.getFolderInfo())
            }
            .disposed(by: disposeBag)
        
        return Output(
            folderData: folderData.asDriver(),
            completeSaveNewFolder: completeSaveNewFolder.asDriver()
        )
    }
}

extension ArchiveFolderViewModel {
    
    private func addNewFolder(name: String) {
        
        let realm = try! Realm()
        let newFolder = Folder(folderName: name, createFolderDate: Date(), photoCards: List<PhotoCardRecord>())
        
        try? realm.write {
            realm.add(newFolder)
        }
    }
}
