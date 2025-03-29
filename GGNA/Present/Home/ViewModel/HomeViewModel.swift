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
        
    }
    
    struct Output {
        
    }
    
    init() {
        
    }
    
    deinit {
        print("HomeVM Deinit")
    }
    
    func transform(from input: Input) -> Output {
        return Output()
    }
}
