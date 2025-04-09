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
        guard data.isEmpty else { return }
        
        do {
            try realm.write {
               
                let folder = Folder(
                    folderName: "기본",
                    createFolderDate: Date(),
                    photoCards: List<PhotoCardRecord>()
                )
                
                realm.add(folder)
                
                guard let defaultFolder = realm.objects(Folder.self).filter({ $0.folderName == "기본" }).first else { return }
                
                // default 사진 추가
                let cardContent = CardContent()
                cardContent.title = "뭘보냥"
                cardContent.createDate = Date()
                cardContent.date = "2024.05.07 화요일"
                cardContent.secretMode = false
                cardContent.detail = "우리들의 소중한 추억"
                
                let defaultPhoto = PhotoCardRecord(
                    imageScale: true,
                    videoData: Data(),
                    filter: Filter.original.type,
                    isSelectedMain: true,
                    cardContent: cardContent
                )
                
                defaultFolder.photoCards.append(defaultPhoto)
                
                // 이미지 Document 저장
                UIImage(resource: .ggnaDefault).saveImageToDocument(foldername: "기본", filename: defaultPhoto.imageName)
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
