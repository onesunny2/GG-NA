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
    static let basicBadge: UIFont = .systemFont(ofSize: 13 , weight: .medium)
    static let subContent: UIFont = .systemFont(ofSize: 12, weight: .regular)
    static let subTitle: UIFont = .systemFont(ofSize: 16, weight: .medium)
    static let folderTitle: UIFont = .systemFont(ofSize: 16, weight: .bold)
    
    // MARK: Launch Screen
    static let smallLaunch: UIFont = .systemFont(ofSize: 18, weight: .regular)
    static let bigLaunch: UIFont = .systemFont(ofSize: 35, weight: .semibold)
    
    // MARK: Home View
    static let normalCardTitle: UIFont = UIFont(name: "MungyeongGamhongApple", size: 30) ?? .systemFont(ofSize: 15, weight: .heavy)
    static let underlineCardTitle: UIFont = .systemFont(ofSize: 40, weight: .heavy)
    
    // MARK: CustomFont
    static let folderCount: UIFont = UIFont(name: "MungyeongGamhongApple", size: 15) ?? .systemFont(ofSize: 15, weight: .heavy)
}
