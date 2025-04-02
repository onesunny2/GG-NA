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
        let downSampledImage: Driver<UIImage>
    }
    
    private let cardData = BehaviorRelay<CardData?>(value: nil)
    private let disposeBag = DisposeBag()
    
    init() {
        
    }
    
    func transform(from input: Input) -> Output {
        
        let downSampledImage = PublishRelay<UIImage>()
        
        // MARK: 옵셔널 처리를 위한 default 더미 데이터
        let defaultCardData = CardData(
            folderName: "",
            imageData: UIImage(),
            videoData: nil,
            filter: "original",
            isSelectedMain: false,
            cardContent: CardData.CardContentData()
        )
        
        // 이미지
        input.pickedImageData
            .withLatestFrom(cardData) { imgData, currentData -> CardData in
                var newData = currentData ?? defaultCardData
                
                guard let image = UIImage(data: imgData) else { return newData }
                let downImage = image.downSample(scale: 0.8)
                newData.imageData = downImage
                downSampledImage.accept(downImage)
                
                return newData
            }
            .bind(to: cardData)
            .disposed(by: disposeBag)
        
        return Output(
            downSampledImage: downSampledImage.asDriver(onErrorDriveWith: .empty())
        )
    }
}
