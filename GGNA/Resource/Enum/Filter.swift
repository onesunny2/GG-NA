//
//  Filter.swift
//  GGNA
//
//  Created by Lee Wonsun on 3/30/25.
//

import Foundation

enum Filter {
    case original
    
    var name: String {
        switch self {
        case .original: return "original"
        }
    }
}
