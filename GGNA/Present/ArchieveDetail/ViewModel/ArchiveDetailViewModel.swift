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
        let viewWillAppear: Observable<Void>
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
        
        input.viewWillAppear
            .bind(with: self) { owner, _ in
                photosData.accept(owner.repository.getPhotosFromFolder(folderName: owner.folder))
            }
            .disposed(by: disposeBag)
        
        input.deletePhotos
            .bind(with: self) { owner, entities in
                owner.deletePhotoFromRealm(folderName: owner.folder, entities: entities)
                photosData.accept(owner.repository.getPhotosFromFolder(folderName: owner.folder))
            }
            .disposed(by: disposeBag)
        
        return Output(
            photosData: photosData.asDriver()
        )
    }
}

extension ArchiveDetailViewModel {
    
    private func deletePhotoFromRealm(folderName: String, entities: [FolderPhotosEntity]) {
        
        let realm = try! Realm()
        
        let photos = realm.objects(PhotoCardRecord.self)
        
        do {
            
            try realm.write {
                
                for entity in entities {
                    
                    if let photoToDelete = photos.filter("imageName == %@", entity.imageName).first {
                        
                        deletePhotoFromFolder(folderName: folderName, imageName: entity.imageName)
                        realm.delete(photoToDelete)
                    }
                }
            }
            
        } catch {
            print("error: \(error)")
        }
    }
    
    private func deletePhotoFromFolder(folderName: String, imageName: String) {
        
        guard let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return
        }
        
        let folderURL = documentDirectory.appendingPathComponent(folderName)
        
        let imageJpgName = imageName + ".jpg"
        let imageURL = folderURL.appendingPathComponent(imageJpgName)
        
        do {
            
            if FileManager.default.fileExists(atPath: imageURL.path) {
                try FileManager.default.removeItem(at: imageURL)
            } else {
                print("삭제할 이미지를 찾을 수 없음: \(imageName)")
            }
            
        } catch {
            print("이미지 삭제 오류: \(error.localizedDescription)")
        }
    }
}
