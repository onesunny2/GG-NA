//
//  DeleteType.swift
//  GGNA
//
//  Created by Lee Wonsun on 4/18/25.
//

import Foundation

enum DeleteType {
    case folder
    case photo
    
    var message: String {
        switch self {
        case .folder: return "해당 폴더에 있는 사진도 함께 삭제됩니다. 삭제하시겠습니까?"
        case .photo: return "삭제된 사진은 복구되지 않습니다. 삭제하시겠습니까?"
        }
    }
}
