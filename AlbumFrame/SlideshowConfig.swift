//
//  Item.swift
//  PhotoFrame
//
//  Created by Nisala on 12/31/25.
//

import Foundation
import SwiftData

enum PhotoOrder: String, Codable, CaseIterable {
    case sequential = "Sequential"
    case random = "Random"
}

@Model
final class SlideshowConfig {
    var albumIdentifier: String
    var timing: Int
    var order: PhotoOrder
    
    init(albumIdentifier: String, timing: Int, order: PhotoOrder = .sequential) {
        self.albumIdentifier = albumIdentifier
        self.timing = timing
        self.order = order
    }
}
