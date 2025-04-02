//
//  Reactive+.swift
//  GGNA
//
//  Created by Lee Wonsun on 4/2/25.
//

import UIKit
import RxSwift

extension Reactive where Base: UIView {
    var tapgesture: Observable<Void> {
        let tapGestureRecognizer = UITapGestureRecognizer()
        
        base.addGestureRecognizer(tapGestureRecognizer)
        base.isUserInteractionEnabled = true

        return tapGestureRecognizer.rx.event
            .map { _ in () }
            .asObservable()
    }
}
