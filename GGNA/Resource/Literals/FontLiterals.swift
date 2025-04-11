//
//  FontLiterals.swift
//  GGNA
//
//  Created by Lee Wonsun on 3/28/25.
//

import UIKit

enum FontLiterals {
    
    // MARK: Common
    static let themeBadge: UIFont = .systemFont(ofSize: 10, weight: .medium)
    static let basicBadge13: UIFont = .systemFont(ofSize: 13 , weight: .bold)
    static let basicBadge15: UIFont = .systemFont(ofSize: 15 , weight: .bold)
    static let subContent: UIFont = .systemFont(ofSize: 12, weight: .regular)
    static let subTitleMedium: UIFont = .systemFont(ofSize: 16, weight: .medium)
    static let subTitleBold: UIFont = .systemFont(ofSize: 16, weight: .bold)
    static let folderTitle: UIFont = .systemFont(ofSize: 16, weight: .bold)
    static let placeholder: UIFont = .systemFont(ofSize: 13, weight: .regular)
    static let navigationText17: UIFont = .systemFont(ofSize: 17, weight: .regular)
    
    // MARK: Launch Screen
    static let smallLaunch: UIFont = .systemFont(ofSize: 18, weight: .regular)
    static let bigLaunch: UIFont = .systemFont(ofSize: 35, weight: .semibold)
    
    // MARK: Home View
    static let normalCardTitle: UIFont = UIFont(name: "MungyeongGamhongApple", size: 30) ?? .systemFont(ofSize: 15, weight: .heavy)
    static let underlineCardTitle: UIFont = .systemFont(ofSize: 40, weight: .heavy)
    static let modalVCTitle: UIFont = .systemFont(ofSize: 20, weight: .bold)
    
    // MARK: CustomFont
    static let folderCount: UIFont = UIFont(name: "MungyeongGamhongApple", size: 15) ?? .systemFont(ofSize: 15, weight: .heavy)
    static let cameraTitle: UIFont = UIFont(name: "SangSangRockOTF", size: 24) ?? .systemFont(ofSize: 32, weight: .semibold)
    static let writngTitle: UIFont = UIFont(name: "SangSangRockOTF", size: 32) ?? .systemFont(ofSize: 32, weight: .semibold)
    static let archivePhotoTitle: UIFont = UIFont(name: "Unreal_science_medicine", size: 20) ?? .systemFont(ofSize: 20, weight: .light)
    static let archivePhotoDate: UIFont = UIFont(name: "Unreal_science_medicine", size: 12) ?? .systemFont(ofSize: 14, weight: .light)
}
