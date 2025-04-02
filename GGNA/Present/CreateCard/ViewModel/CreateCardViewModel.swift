//
//  CreateCardViewModel.swift
//  GGNA
//
//  Created by Lee Wonsun on 4/2/25.
//

import UIKit
import RealmSwift
import RxCocoa
import RxSwift

struct CardData {
    var folderName: String
    var imageData: UIImage
    var videoData: Data?
    var filter: String = "none"
    var isSelectedMain: Bool
    var cardContent: CardContentData
    
    struct CardContentData {
        var title: String?
        var date: Date?
        var detail: String?
        var location: String?
        var isSecretMode: Bool = false
    }
}

final class CreateCardViewModel: InputOutputModel {
    
    struct Input {
        let pickedImageData: Observable<Data>
    }
    
    struct Output {
        
    }
    
    private let cardData = BehaviorRelay<CardData?>(value: nil)
    private let disposeBag = DisposeBag()
    
    init() {
        
    }
    
    func transform(from input: Input) -> Output {
        
        
        
        input.pickedImageData
            .bind(with: self) { owner, data in
                
                guard let image = UIImage(data: data) else { return }
                let downImage = image.downSample(scale: 0.6)
                
            }
            .disposed(by: disposeBag)
        
        return Output()
    }
}
