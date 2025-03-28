//
//  Theme.swift
//  GGNA
//
//  Created by Lee Wonsun on 3/28/25.
//

import UIKit

enum Theme {
    case light
    case dark
    
    var userInterfaceStyle: UIUserInterfaceStyle {
        switch self {
        case .light: return .light
        case .dark:  return .dark
        }
    }
}

enum ThemeColor {
    case primary
    case secondary
    
    typealias ColorSet = (
        background: UIColor,
        tabBar: UIColor,
        main: UIColor,
        main80: UIColor,
        text: UIColor,
        gray: UIColor
    )
    
    func setColor(for theme: Theme) -> ColorSet {
        
        switch (theme, self) {
        case (.light, .primary): return (
            .ggLightPinkBG,
            .ggTabbarBG,
            .ggLightPink,
            .ggLightPink80,
            .ggLightBlack,
            .ggGray
        )
            
        case (.light, .secondary): return (
            .ggLightMintBG,
            .ggTabbarBG,
            .ggLightMint,
            .ggLightMint80,
            .ggLightBlack,
            .ggGray
        )
            
        case (.dark, .primary): return (
            .ggDarkBlack,
            .ggTabbarBG,
            .ggDarkPink,
            .ggDarkPink80,
            .ggDarkBlack,
            .ggGray
        )
            
        case (.dark, .secondary): return (
            .ggDarkBlack,
            .ggTabbarBG,
            .ggDarkPurple,
            .ggDarkPurple80,
            .ggDarkBlack,
            .ggGray
        )
        }
    }
}
