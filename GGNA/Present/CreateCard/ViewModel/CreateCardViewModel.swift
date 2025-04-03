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
        var date: String?
        var detail: String?
        var location: String?
        var isSecretMode: Bool = false
    }
}

final class CreateCardViewModel: InputOutputModel {
    
    struct Input {
        let pickedImageData: Observable<Data>
        let tappedCloseButton: Observable<Void>
        let inputText: Observable<String>
        let tappedSaveButton: Observable<Void>
        let isSelectedMainImage: Observable<Bool>
    }
    
    struct Output {
        let downSampledImage: Driver<UIImage>
        let yesChangedData: Driver<Void>
        let noChangedData: Driver<Void>
    }
    
    private let cardData = BehaviorRelay<CardData?>(value: nil)
    private let initialCardData = BehaviorRelay<CardData?>(value: nil)
    private let disposeBag = DisposeBag()
    
    init() {
        // 초기 데이터 설정
         let defaultCardData = CardData(
             folderName: "",
             imageData: UIImage(),
             videoData: nil,
             filter: "original",
             isSelectedMain: false,
             cardContent: CardData.CardContentData()
         )
         
         initialCardData.accept(defaultCardData)
         cardData.accept(defaultCardData)
    }
    
    func transform(from input: Input) -> Output {
        
        let downSampledImage = PublishRelay<UIImage>()
        let yesChangedData = PublishRelay<Void>()
        let noChangedData = PublishRelay<Void>()
        
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
                downSampledImage.accept(downImage)  // UI로 다운샘플링 이미지 내보내기
                
                return newData
            }
            .bind(to: cardData)
            .disposed(by: disposeBag)
        
        // title
        input.inputText
            .withLatestFrom(cardData) { title, currentData -> CardData in
                var newData = currentData ?? defaultCardData
                newData.cardContent.title = title
                return newData
            }
            .bind(to: cardData)
            .disposed(by: disposeBag)
        
        // 메인이미지 설정 유무
        input.isSelectedMainImage
            .withLatestFrom(cardData) { status, currentData -> CardData in
                var newData = currentData ?? defaultCardData
                newData.isSelectedMain = status
                return newData
            }
            .bind(to: cardData)
            .disposed(by: disposeBag)
        
        // saveButton
        input.tappedSaveButton
            .bind(with: self) { owner, _ in
                dump(owner.cardData.value)
            }
            .disposed(by: disposeBag)
        
        // closeButton
        input.tappedCloseButton
            .bind(with: self) { owner, _ in
                
                guard let currentData = owner.cardData.value,
                      let initialData = owner.initialCardData.value else {
                    // 데이터가 없는 경우 그냥 닫기
                    yesChangedData.accept(())
                    return
                }
                
                // 데이터 변경 여부 확인
                owner.checkChangedData(currentData: currentData, initialData: initialData, noChangedData: noChangedData, yesChangedData: yesChangedData)
            }
            .disposed(by: disposeBag)
        
        return Output(
            downSampledImage: downSampledImage.asDriver(onErrorDriveWith: .empty()),
            yesChangedData: yesChangedData.asDriver(onErrorDriveWith: .empty()),
            noChangedData: noChangedData.asDriver(onErrorDriveWith: .empty())
        )
    }
}

extension CreateCardViewModel {
    
    
    // 창 닫기 전에 변경사항 유무 체크
    private func checkChangedData(currentData: CardData, initialData: CardData, noChangedData: PublishRelay<Void>, yesChangedData: PublishRelay<Void>) {
        
        let isImageChanged = currentData.imageData.isEqual(initialData.imageData)
        let isFolderNameChanged = (currentData.folderName != initialData.folderName)
        let isTitleChanged = (currentData.cardContent.title != initialData.cardContent.title)
        let isDateChanged = (currentData.cardContent.date != initialData.cardContent.date)
        
        if isImageChanged || isFolderNameChanged || isTitleChanged || isDateChanged {
            // 데이터가 변경된 경우 알럿 띄우기
            noChangedData.accept(())
        } else {
            // 데이터가 변경되지 않은 경우 그냥 닫기
            yesChangedData.accept(())
        }
    }
}
