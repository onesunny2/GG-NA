//
//  ThemeDefaults.swift
//  GGNA
//
//  Created by Lee Wonsun on 3/28/25.
//

import Foundation
import RxCocoa
import RxSwift

typealias ThemeSet = (theme: Theme, color: ThemeColor)

@propertyWrapper
struct ThemeDefaults {

    private let key: CurrentTheme
    private let defaultTheme: ThemeSet
    
    init(key: CurrentTheme, defaultTheme: ThemeSet = (.dark, .primary)) {
        self.key = key
        self.defaultTheme = defaultTheme
    }
    
    var wrappedValue: ThemeSet {
        get {
            return getThemeInfo(for: key.rawValue) ?? defaultTheme
        }
        set {
            setTheme(for: key.rawValue, value: newValue)
        }
    }
    
    var projectedValue: Observable<ThemeSet> {
        
        let theme = UserDefaults.standard.rx.observe(
            String.self,
            key.rawValue + "Theme",
            options: [.initial, .new]
        )
        
        let color = UserDefaults.standard.rx.observe(
            String.self,
            key.rawValue + "Color",
            options: [.initial, .new]
        )
        
        return Observable.combineLatest(theme, color)
            .map { _ in
                getThemeInfo(for: key.rawValue)
            }
    }
    
    private func getThemeInfo(for key: String) -> ThemeSet {
        let themeName = UserDefaults.standard.string(forKey: key + "Theme")
        let colorName = UserDefaults.standard.string(forKey: key + "Color")
        
        if themeName == nil && colorName == nil {
            return defaultTheme
        }
        
        let theme = (themeName == "light") ? Theme.light : Theme.dark
        let color = (colorName == "primary") ? ThemeColor.primary : ThemeColor.secondary
        
        return (theme, color)
    }
    
    private func setTheme(for key: String, value: ThemeSet) {
        
        UserDefaults.standard.set(
            (value.theme == .light) ? "light" : "dark",
            forKey: key + "Theme"
        )
        UserDefaults.standard.set(
            (value.color == .primary) ? "primary" : "secondary",
            forKey: key + "Color"
        )
    }
}

enum CurrentTheme: String {
    case 현재테마
    
    @ThemeDefaults(key: .현재테마) static var currentTheme
}
