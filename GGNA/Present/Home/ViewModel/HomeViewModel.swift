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
    }
    
    struct Output {
        let currentPhotos: Driver<[HomePhotoCardEntity]>
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
        
        // TODO: 나중에 폴더 선택 가능하게 하려면 UserDefault로 현재 선택한 폴더정보 저장 필요
        let currentPhotos = BehaviorRelay<[HomePhotoCardEntity]>(value: repository.getPhotosFromFolder(folderName: "기본"))
        
        input.viewWillAppear
            .bind(with: self) { owner, _ in
                currentPhotos.accept(owner.repository.getPhotosFromFolder(folderName: "기본"))
            }
            .disposed(by: disposeBag)
        
        return Output(
            currentPhotos: currentPhotos.asDriver()
        )
    }
}
