//
//  ArchiveDetailViewModel.swift
//  GGNA
//
//  Created by Lee Wonsun on 4/2/25.
//

import Foundation
import RxCocoa
import RxSwift

final class ArchiveDetailViewModel: InputOutputModel {
    
    struct Input {
        let viewDidLoad: Observable<Void>
    }
    
    struct Output {
        let photosData: Driver<[FolderPhotosEntity]>
    }
    
    private let repository: ArchiveFolderRepository
    let folder: String
    
    private let disposeBag = DisposeBag()
    
    init(repository: ArchiveFolderRepository, folder: String) {
        self.repository = repository
        self.folder = folder
    }
    
    func transform(from input: Input) -> Output {
        
        let photosData = BehaviorRelay<[FolderPhotosEntity]>(value: repository.getPhotosFromFolder(folderName: folder))
        
        input.viewDidLoad
            .bind(with: self) { owner, _ in
                photosData.accept(owner.repository.getPhotosFromFolder(folderName: owner.folder))
            }
            .disposed(by: disposeBag)
        
        return Output(
            photosData: photosData.asDriver()
        )
    }
}
