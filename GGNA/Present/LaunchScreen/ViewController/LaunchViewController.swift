//
//  LaunchViewController.swift
//  GGNA
//
//  Created by Lee Wonsun on 3/28/25.
//

import UIKit
import SnapKit
import RealmSwift
import RxCocoa
import RxSwift

final class LaunchViewController: BaseViewController {
    
    private let viewModel: LaunchScreenViewModel
    private let disposeBag = DisposeBag()
    
    private let launchImage = BaseUIImageView(image: nil)

    init(viewModel: LaunchScreenViewModel) {
        self.viewModel = viewModel
        super.init()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        getFolderFromRealm()
    }
    
    private func getFolderFromRealm() {
        let realm = try! Realm()
        
        print(realm.configuration.fileURL!)
        
        let data = realm.objects(Folder.self)
        guard data.isEmpty else {
            
            // 기본 폴더 찾기
            guard let defaultFolder = data.filter({ $0.folderName == "기본" }).first else { return }
            // 기본 폴더의 기본 사진 찾기
            guard let defaultImageIndex = defaultFolder.photoCards.firstIndex(where: {
                ($0.cardContent?.detail == "우리들의 소중한 추억") && ($0.cardContent?.date == "2024.05.07 화요일")
            }) else { return }
            
            do {
                try realm.write {
                    let deletePhoto = defaultFolder.photoCards[defaultImageIndex]
                    let imageName = deletePhoto.imageName
                    
                    // 1. 이미지 document에서 삭제
                    deletePhotoFromFolder(folderName: "기본", imageName: imageName)
                    
                    // 2. Realm에서 포토카드 삭제
                    defaultFolder.photoCards.remove(at: defaultImageIndex)
                    print("기본 제공 사진 삭제 완료")
                }
            } catch {
                print("기본 제공 사진 삭제에 실패: \(error)")
            }
            
            return
        }
        
        // 기본 폴더 없을 때 생성해주는 기능
        do {
            try realm.write {
               
                let folder = Folder(
                    folderName: "기본",
                    createFolderDate: Date(),
                    photoCards: List<PhotoCardRecord>()
                )
                
                realm.add(folder)
            }
            
        } catch {
            print("기본 폴더 추가 실패")
        }
    }
    
    override func configureBind() {
        
        let input = LaunchScreenViewModel.Input(
            viewDidLoad: Observable.just(())
        )
        
        let output = viewModel.transform(from: input)
        
        output.endTimer
            .drive(with: self) { owner, _ in
                let vc = CustomTabBarController.create()
                owner.viewTransition(type: .changeRootVC, vc: vc)
            }
            .disposed(by: disposeBag)
    }
    
    override func configureNavigation() {
        navigationController?.navigationBar.isHidden = true
    }

    override func configureView() {
        
        CurrentTheme.$currentTheme
            .bind(with: self) { owner, value in
                
                let colors = value.color.setColor(for: value.theme)
                let image = value.color.setLaunchImage(for: value.theme)
                
                owner.view.backgroundColor = colors.background
                owner.launchImage.image = image
            }
            .disposed(by: disposeBag)
    }
    
    override func configureHierarchy() {
        view.addSubview(launchImage)
        
    }
    
    override func configureLayout() {
        launchImage.snp.makeConstraints {
            $0.center.equalTo(view.safeAreaLayoutGuide)
        }
    }
}
