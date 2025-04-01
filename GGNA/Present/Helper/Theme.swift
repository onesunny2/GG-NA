//
//  Theme.swift
//  GGNA
//
//  Created by Lee Wonsun on 3/28/25.
//

import UIKit

enum Theme: String {
    case light = "Light"
    case dark = "Dark"
    
    var userInterfaceStyle: UIUserInterfaceStyle {
        switch self {
        case .light: return .light
        case .dark:  return .dark
        }
    }
}

typealias ColorSet = (
    background: UIColor,
    tabBar: UIColor,
    unselectedTabBar: UIColor,
    plusBtn: UIColor,
    main: UIColor,
    main80: UIColor,
    text: UIColor,
    gray: UIColor
)

enum ThemeColor {
    case primary
    case secondary

    func setColor(for theme: Theme) -> ColorSet {
        
        switch (theme, self) {
        case (.light, .primary): return (
            .ggLightPinkBG,
            .ggLightPinkTabbarBG,
            .ggLightUnselectedTabBar,
            .ggTabBarPlusBG,
            .ggLightPink,
            .ggLightPink80,
            .ggLightBlack,
            .ggGray
        )
            
        case (.light, .secondary): return (
            .ggLightMintBG,
            .ggLightMintTabbarBG,
            .ggLightUnselectedTabBar,
            .ggTabBarPlusBG,
            .ggLightMint,
            .ggLightMint80,
            .ggLightBlack,
            .ggGray
        )
            
        case (.dark, .primary): return (
            .ggDarkBlack,
            .ggDarkTabbarBG,
            .ggDarkUnselectedTabBar,
            .ggTabBarPlusBG,
            .ggDarkPink,
            .ggDarkPink80,
            .ggDarkWhite,
            .ggGray
        )
            
        case (.dark, .secondary): return (
            .ggDarkBlack,
            .ggDarkTabbarBG,
            .ggDarkUnselectedTabBar,
            .ggTabBarPlusBG,
            .ggDarkPurple,
            .ggDarkPurple80,
            .ggDarkWhite,
            .ggGray
        )
        }
    }
    
    func setLaunchImage(for theme: Theme) -> UIImage? {
        switch (theme, self) {
        case (.light, .primary): return UIImage(named: "lightPinkLaunch")
        case (.light, .secondary): return UIImage(named: "lightMintLaunch")
        case (.dark, .primary): return UIImage(named: "darkPinkLaunch")
        case (.dark, .secondary): return UIImage(named: "darkPurpleLaunch")
        }
    }
}
