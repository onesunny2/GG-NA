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
    var imageScale: Bool
    var videoData: Data?
    var filterInfo: FilterInfo
    var isSelectedMain: Bool
    var cardContent: CardContentData
    
    struct CardContentData {
        var title: String = ""
        var date: String = DatePickerManager.shared.todayDate()
        var detail: String?
        var location: String?
        var isSecretMode: Bool = false
    }
}

final class CreateCardViewModel: InputOutputModel {
    
    struct Input {
        let pickedImageData: Observable<Data>
        let tappedCloseButton: Observable<Void>
        let inputTitleText: Observable<String>
        let tappedSaveButton: Observable<Void>
        let isSelectedMainImage: Observable<Bool>
        let selectedFolder: Observable<String>
        let inputDetailText: Observable<String>
        let zoomStatus: Observable<Bool>
        let isSecretMode: Observable<Bool>
        let filterInfo: Observable<FilterInfo>
    }
    
    struct Output {
        let downSampledImage: Driver<UIImage>
        let yesChangedData: Driver<Void>
        let noChangedData: Driver<Void>
        let canSave: Driver<Bool>
    }
    
    private let cardData = BehaviorRelay<CardData?>(value: nil)
    private let initialCardData = BehaviorRelay<CardData?>(value: nil)
    private let disposeBag = DisposeBag()
    
    private let pickedDate = DatePickerManager.shared.formattedDateString
    
    init() {
        // 초기 데이터 설정
         let defaultCardData = CardData(
             folderName: "기본",
             imageData: UIImage(),
             imageScale: true,
             videoData: nil,
             filterInfo: FilterInfo(filter: .original, filterValue: 0.0),
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
        let canSave = PublishRelay<Bool>()
        
        // MARK: 옵셔널 처리를 위한 default 더미 데이터
        let defaultCardData = CardData(
            folderName: "기본",
            imageData: UIImage(),
            imageScale: true,
            videoData: nil,
            filterInfo: FilterInfo(filter: .original, filterValue: 0.0),
            isSelectedMain: false,
            cardContent: CardData.CardContentData()
        )
        
        // 이미지
        input.pickedImageData
            .withLatestFrom(cardData) { imgData, currentData -> CardData in
                var newData = currentData ?? defaultCardData
                
                guard let image = UIImage(data: imgData) else { return newData }
                let orientationFixed = image.fixImageOrientation()
                let downImage = orientationFixed.downSample(scale: 0.6)
                newData.imageData = downImage
                downSampledImage.accept(downImage)  // UI로 다운샘플링 이미지 내보내기
                
                return newData
            }
            .bind(to: cardData)
            .disposed(by: disposeBag)
        
        // 필터정보
        input.filterInfo
            .withLatestFrom(cardData) { filterInfo, currentData -> CardData in
                var newData = currentData ?? defaultCardData
                newData.filterInfo = filterInfo
                return newData
            }
            .bind(to: cardData)
            .disposed(by: disposeBag)
        
        // zoomScale Info
        input.zoomStatus
            .withLatestFrom(cardData) { status, currentData -> CardData in
                var newData = currentData ?? defaultCardData
                newData.imageScale = status
                
                return newData
            }
            .bind(to: cardData)
            .disposed(by: disposeBag)
        
        // title
        input.inputTitleText
            .withLatestFrom(cardData) { title, currentData -> CardData in
                var newData = currentData ?? defaultCardData
                newData.cardContent.title = title
                return newData
            }
            .bind(to: cardData)
            .disposed(by: disposeBag)
        
        // detail
        input.inputDetailText
            .withLatestFrom(cardData) { detail, currentData -> CardData in
                var newData = currentData ?? defaultCardData
                newData.cardContent.detail = detail
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
        
        // 열람 잠금 설정 유무
        input.isSecretMode
            .withLatestFrom(cardData) { status, currentData -> CardData in
                var newData = currentData ?? defaultCardData
                newData.cardContent.isSecretMode = status
                return newData
            }
            .bind(to: cardData)
            .disposed(by: disposeBag)
        
        // 폴더 (** 폴더는 따로 Realm에 저장하기 XX - 이미 폴더 생성 시 저장시킴)
        input.selectedFolder
            .withLatestFrom(cardData) { folder, currentData -> CardData in
                var newData = currentData ?? defaultCardData
                newData.folderName = folder
                return newData
            }
            .bind(to: cardData)
            .disposed(by: disposeBag)
        
        // 날짜
        pickedDate
            .withLatestFrom(cardData) { date, currentData -> CardData in
                var newData = currentData ?? defaultCardData
                newData.cardContent.date = date
                return newData
            }
            .bind(to: cardData)
            .disposed(by: disposeBag)
        
        // saveButton
        input.tappedSaveButton
            .bind(with: self) { owner, _ in
                
                guard let currentData = owner.cardData.value,
                      let initialData = owner.initialCardData.value else {
                    // 데이터가 없는 경우 그냥 닫기
                    canSave.accept(false)
                    return
                }
                
                switch owner.allChanged(currentData: currentData, initialData: initialData) {
                case true:  // Realm 데이터 저장
                    canSave.accept(true)
                    owner.savePhotoCard()
                case false: // 저장 못하도록 block
                    canSave.accept(false)
                }
                
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
            noChangedData: noChangedData.asDriver(onErrorDriveWith: .empty()),
            canSave: canSave.asDriver(onErrorDriveWith: .empty())
        )
    }
}

extension CreateCardViewModel {
    
    private func hasChanges(currentData: CardData, initialData: CardData) -> Bool {
        let isImageChanged = currentData.imageData != initialData.imageData
        let isFolderNameChanged = (currentData.folderName != initialData.folderName)
        let isTitleChanged = (currentData.cardContent.title != initialData.cardContent.title)
        let isDateChanged = (currentData.cardContent.date != initialData.cardContent.date)
        let isDetailChanged = (currentData.cardContent.detail != initialData.cardContent.detail)
        let isMainSelectionChanged = (currentData.isSelectedMain != initialData.isSelectedMain)
        let isScaleChanged = (currentData.imageScale != initialData.imageScale)
        let isSecretModeChanged = (currentData.cardContent.isSecretMode != initialData.cardContent.isSecretMode)
        
        return isImageChanged || isFolderNameChanged || isTitleChanged ||
        isDateChanged || isDetailChanged || isMainSelectionChanged || isScaleChanged || isSecretModeChanged
    }
    
    private func allChanged(currentData: CardData, initialData: CardData) -> Bool {
        let isImageChanged = currentData.imageData != initialData.imageData
        let isTitleChanged = (currentData.cardContent.title != initialData.cardContent.title)
        
        return isImageChanged && isTitleChanged
    }
    
    // 창 닫기 전에 변경사항 유무 체크
    private func checkChangedData(currentData: CardData, initialData: CardData, noChangedData: PublishRelay<Void>, yesChangedData: PublishRelay<Void>) {
        
        if hasChanges(currentData: currentData, initialData: initialData) {
            // 데이터가 변경된 경우 알럿 띄우기
            yesChangedData.accept(())
            print("변경됨")
        } else {
            // 데이터가 변경되지 않은 경우 그냥 닫기
            noChangedData.accept(())
            print("변경안됨")
        }
    }
    
    // 저장버튼 클릭 시 데이터 저장 로직
    private func savePhotoCard() {
        
        let realm = try! Realm()
        
        do {
            try realm.write {
                
                guard let userData = cardData.value else { return }
                let content = userData.cardContent
                
                // 선택한 폴더에 저장
                let folderName = userData.folderName
                print("선택한 폴더: \(folderName)")
                guard let folder = realm.objects(Folder.self).filter({ $0.folderName == folderName }).first else { return }
                
                let cardContent = CardContent()
                cardContent.title = content.title
                cardContent.date = content.date
                cardContent.createDate = Date()
                cardContent.detail = content.detail ?? ""
                cardContent.location = content.location ?? ""
                cardContent.secretMode = content.isSecretMode

                let cardRecord = PhotoCardRecord(
                    imageScale: userData.imageScale,
                    videoData: userData.videoData ?? Data(),
                    filterInfo: userData.filterInfo,
                    isSelectedMain: userData.isSelectedMain,
                    cardContent: cardContent
                )
                
                // 이미 폴더에 메인 이미지가 존재한다면 -> 기존 메인은 false로 바꾸도록
                if userData.isSelectedMain {
                    let existData = realm.objects(PhotoCardRecord.self).filter("Any parentFolder.folderName == %@", folderName)
                    
                    if existData.count != 0 {
                        
                        let existPhoto = existData.filter { $0.isSelectedMain == true }
                        
                        existPhoto.forEach {
                            $0.isSelectedMain = false
                        }
                    }
                }
                
                // 이미지 Document 저장
                userData.imageData.saveImageToDocument(foldername: folderName, filename: cardRecord.imageName)
                print(folderName, cardRecord.imageName)
                
                folder.photoCards.append(cardRecord)
                print("Save Realm complete")
            }
            
        } catch {
            // 저장 실패 토스트 메시지
            print("Failed To Save")
        }
    }
}
