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
        let viewDidLoad: Observable<Void>
    }
    
    struct Output {
        let currentPhotos: Driver<[PhotoCardRecord]>
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
        
        let currentPhotos = BehaviorRelay<[PhotoCardRecord]>(value: repository.getPhotosFromFolder())
        
        input.viewDidLoad
            .bind(with: self) { owner, _ in
                currentPhotos.accept(owner.repository.getPhotosFromFolder())
            }
            .disposed(by: disposeBag)
        
        return Output(
            currentPhotos: currentPhotos.asDriver()
        )
    }
}
