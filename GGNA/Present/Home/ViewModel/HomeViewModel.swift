//
//  HomeViewModel.swift
//  GGNA
//
//  Created by Lee Wonsun on 3/30/25.
//

import Foundation
import RxCocoa
import RxSwift

final class HomeViewModel: InputOutputModel {
    
    struct Input {
        let viewWillAppear: Observable<Void>
        let changeFolder: Observable<String>
    }
    
    struct Output {
        let currentPhotos: Driver<[HomePhotoCardEntity]>
        let currentFolders: Driver<[HomeFolderEntity]>
    }
    
    private let repository: HomePhotoRepository
    private let disposeBag = DisposeBag()
    
    init(repository: HomePhotoRepository) {
        self.repository = repository
    }
    
    deinit {
        print("HomeVM Deinit")
    }
    
    func transform(from input: Input) -> Output {
        
        let currentPhotos = BehaviorRelay<[HomePhotoCardEntity]>(value: repository.getPhotosFromFolder(folderName: SavingFolder.folder))
        let currentFolders = BehaviorRelay(value: repository.getFolders())
        
        input.viewWillAppear
            .bind(with: self) { owner, _ in
                currentPhotos.accept(owner.repository.getPhotosFromFolder(folderName: SavingFolder.folder))
                currentFolders.accept(owner.repository.getFolders())
            }
            .disposed(by: disposeBag)
        
        input.changeFolder
            .bind(with: self) { owner, name in
                SavingFolder.folder = name
                currentPhotos.accept(owner.repository.getPhotosFromFolder(folderName: name))
                currentFolders.accept(owner.repository.getFolders())
            }
            .disposed(by: disposeBag)
        
        return Output(
            currentPhotos: currentPhotos.asDriver(),
            currentFolders: currentFolders.asDriver()
        )
    }
}
