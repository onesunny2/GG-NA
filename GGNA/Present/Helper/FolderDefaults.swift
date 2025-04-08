//
//  FolderDefaults.swift
//  GGNA
//
//  Created by Lee Wonsun on 4/8/25.
//

import Foundation
import RxCocoa
import RxSwift

@propertyWrapper
struct FolderDefaults<T> {
    
    let key: SavingFolder
    let empty: T
    
    init(key: SavingFolder, empty: T) {
        self.key = key
        self.empty = empty
    }
    
    var wrappedValue: T {
        get {
            return UserDefaults.standard.object(forKey: key.rawValue) as? T ?? empty
        }
        set {
            UserDefaults.standard.set(newValue as T, forKey: key.rawValue)
        }
    }
    
    var projectedValue: Observable<T?> {
        return UserDefaults.standard.rx.observe(
            T.self,
            key.rawValue,
            options: [.initial, .new]
        )
        .map { $0 ?? empty }
    }
}

enum SavingFolder: String {
    case 폴더저장
    
    @FolderDefaults(key: .폴더저장, empty: "기본") static var folder
}
