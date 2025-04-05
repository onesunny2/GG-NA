//
//  ArchiveDetailViewModel.swift
//  GGNA
//
//  Created by Lee Wonsun on 4/2/25.
//

import Foundation
import RealmSwift
import RxCocoa
import RxSwift

final class ArchiveDetailViewModel: InputOutputModel {
    
    struct Input {
        let viewDidLoad: Observable<Void>
        let deletePhotos: Observable<[FolderPhotosEntity]>
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
        
        input.deletePhotos
            .bind(with: self) { owner, entities in
                owner.deletePhotoFromRealm(entities: entities)
                photosData.accept(owner.repository.getPhotosFromFolder(folderName: owner.folder))
            }
            .disposed(by: disposeBag)
        
        return Output(
            photosData: photosData.asDriver()
        )
    }
}

extension ArchiveDetailViewModel {
    
    private func deletePhotoFromRealm(entities: [FolderPhotosEntity]) {
        
        let realm = try! Realm()
        
        let photos = realm.objects(PhotoCardRecord.self)
        
        do {
            
            try realm.write {
                
                for entity in entities {
                    
                    if let photoToDelete = photos.filter("imageName == %@", entity.imageName).first {
                        realm.delete(photoToDelete)
                    }
                }
            }
            
        } catch {
            print("error: \(error)")
        }
    }
}
