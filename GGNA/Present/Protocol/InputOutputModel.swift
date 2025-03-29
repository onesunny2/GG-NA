//
//  InputOutputModel.swift
//  GGNA
//
//  Created by Lee Wonsun on 3/29/25.
//

import Foundation

protocol InputOutputModel {
    associatedtype Input
    associatedtype Output
    
    func transform(from input: Input) -> Output
}
