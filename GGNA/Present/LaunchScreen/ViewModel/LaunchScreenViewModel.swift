//
//  LaunchScreenViewModel.swift
//  GGNA
//
//  Created by Lee Wonsun on 3/29/25.
//

import Foundation
import RxCocoa
import RxSwift

final class LaunchScreenViewModel: InputOutputModel {
    
    struct Input {
        let viewDidLoad: Observable<Void>
    }
    
    struct Output {
        let endTimer: Driver<Void>
    }
    
    private let disposeBag = DisposeBag()
    
    init() {
        
    }
    
    func transform(from input: Input) -> Output {
        
        let endTimer = PublishRelay<Void>()
        
        input.viewDidLoad
            .bind(with: self) { owner, _ in
                Observable<Int>
                    .timer(.seconds(3), scheduler: MainScheduler.instance)
                    .bind(with: self) { owner, _ in
                        endTimer.accept(())
                    }
                    .disposed(by: owner.disposeBag)
                
            }
            .disposed(by: disposeBag)
        
        return Output(
            endTimer: endTimer.asDriver(onErrorDriveWith: .empty())
        )
    }
}
