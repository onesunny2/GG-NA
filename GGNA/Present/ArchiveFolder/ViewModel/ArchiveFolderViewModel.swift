//
//  ArchiveFolderViewModel.swift
//  GGNA
//
//  Created by Lee Wonsun on 4/1/25.
//

import Foundation
import RxCocoa
import RxSwift

final class ArchiveFolderViewModel: InputOutputModel {
    
    struct Input {
        let viewDidLoad: Observable<Void>
    }
    
    struct Output {
        let folderData: Driver<[ArchiveFolderEntity]>
    }
    
    private let repository: ArchiveFolderRepository
    private let disposeBag = DisposeBag()
    
    init(repository: ArchiveFolderRepository) {
        self.repository = repository
    }
    
    func transform(from input: Input) -> Output {
        
        let folderData = BehaviorRelay<[ArchiveFolderEntity]>(value: repository.getFolderInfo())
        
        input.viewDidLoad
            .bind(with: self) { owner, _ in
                folderData.accept(owner.repository.getFolderInfo())
            }
            .disposed(by: disposeBag)
        
        return Output(
            folderData: folderData.asDriver()
        )
    }
}
