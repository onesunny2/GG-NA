//
//  CardContent.swift
//  GGNA
//
//  Created by Lee Wonsun on 3/30/25.
//

import Foundation
import RealmSwift

final class CardContent: EmbeddedObject {
    @Persisted var title: String?
    @Persisted var date: Date?
    @Persisted var detail: String?
    @Persisted var location: String?
    @Persisted var secretMode: Bool
}
