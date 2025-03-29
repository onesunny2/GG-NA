//
//  ReusableIdentifier.swift
//  GGNA
//
//  Created by Lee Wonsun on 3/28/25.
//

import Foundation

protocol ReusableIdentifier {
    static var identifier: String { get }
}

extension ReusableIdentifier {
    static var identifier: String {
        return "\(Self.self)"
    }
}
