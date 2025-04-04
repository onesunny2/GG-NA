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
        let deleteFolders: Observable<[ArchiveFolderEntity]>
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
        
        input.deleteFolders
            .bind(with: self) { owner, folders in
                owner.deleteFolders(entites: folders)
                folderData.accept(owner.repository.getFolderInfo())
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
    
    private func deleteFolders(entites: [ArchiveFolderEntity]) {
        
        let realm = try! Realm()
        let folders = realm.objects(Folder.self)
        
        do {
            
            try realm.write {
                entites.forEach {
                    
                    guard let folder = folders.filter("folderName == %@", $0.folderName).first else { return }
                    
                    realm.delete(folder)
                    deleteFolderContents(folderName: $0.folderName)
                }
            }
            
        } catch {
            print("폴더 삭제 실패")
        }
    }
    
    // 삭제하려는 폴더 의 사진들 전부 삭제
    func deleteFolderContents(folderName: String) {
        guard let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return
        }
        
        let folderURL = documentDirectory.appendingPathComponent(folderName)
        
        if !FileManager.default.fileExists(atPath: folderURL.path) {
            return
        }
        
        do {
            // 폴더와 내용물 모두 삭제
            try FileManager.default.removeItem(at: folderURL)
            return
        } catch {
            print("폴더 삭제 중 오류 발생: \(error.localizedDescription)")
            return
        }
    }
}
