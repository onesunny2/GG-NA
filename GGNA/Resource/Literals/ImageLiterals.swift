//
//  ImageLiterals.swift
//  Epica
//
//  Created by 강민수 on 3/21/25.
//

import UIKit

enum ImageLiterals {
    
    /// 앱 내 ViewController 화면에서 사용하는 Image Assets
    static let photoCircleFill: UIImage? = UIImage(systemName: "photo.circle.fill")
    static let pencilCircleFill: UIImage? = UIImage(systemName: "square.and.pencil.circle.fill")
    static let upload: UIImage? = UIImage(systemName: "square.and.arrow.up.fill")?.withTintColor(.ggGray, renderingMode: .alwaysOriginal)
    static let check: UIImage? = UIImage(systemName: "checkmark.circle.fill")?.withTintColor(.ggDarkWhite, renderingMode: .alwaysOriginal)
    static let bookmark: UIImage? = UIImage(systemName: "bookmark.fill")
    static let chevronForwardCircle: UIImage? = UIImage(systemName: "chevron.forward.circle.fill")
    static let lockFill: UIImage? = UIImage(systemName: "lock.fill")
    static let square: UIImage? = UIImage(systemName: "square")
    static let checkMark: UIImage? = UIImage(systemName: "checkmark.square.fill")
    
    /// Navigation TabBar에서 사용하는 Image Assets
    static let home: UIImage? = UIImage(systemName: "house.fill")
    static let folder: UIImage? = UIImage(systemName: "folder.fill")
    static let plus: UIImage? = UIImage(systemName: "plus")
    static let xmark: UIImage? = UIImage(systemName: "xmark.circle.fill")
    static let zoomIn: UIImage? = UIImage(systemName: "arrow.up.backward.and.arrow.down.forward.circle.fill")
    static let zoomOut: UIImage? = UIImage(systemName: "arrow.down.right.and.arrow.up.left.circle.fill")
    
    /// Navigation BarButtonItem에서 사용하는 Image Assets
    static let shuffle: UIImage? = UIImage(systemName: "shuffle")?.withConfiguration(UIImage.SymbolConfiguration(pointSize: 20))
    static let paintpalette: UIImage? = UIImage(systemName: "paintpalette.fill")?.withConfiguration(UIImage.SymbolConfiguration(pointSize: 20))
    static let folderPlus: UIImage? = UIImage(systemName: "folder.fill.badge.plus")?.withConfiguration(UIImage.SymbolConfiguration(pointSize: 20))
    static let trashFill: UIImage? = UIImage(systemName: "trash.fill")?.withConfiguration(UIImage.SymbolConfiguration(pointSize: 20))
    static let minusFill: UIImage? = UIImage(systemName: "minus.circle.fill")?.withConfiguration(UIImage.SymbolConfiguration(pointSize: 20))
}
