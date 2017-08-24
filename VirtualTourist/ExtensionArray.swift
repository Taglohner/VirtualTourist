//
//  ExtensionArray.swift
//  VirtualTourist
//
//  Created by Steven Taglohner on 24/08/2017.
//  Copyright © 2017 Steven Taglohner. All rights reserved.
//

import Foundation

extension Array {
    
    // Returns an array containing this sequence shuffled
    var shuffled: Array {
        var elements = self
        return elements.shuffle()
    }
    // Shuffles this sequence in place
    @discardableResult
    mutating func shuffle() -> Array {
        indices.dropLast().forEach {
            guard case let index = Int(arc4random_uniform(UInt32(count - $0))) + $0, index != $0 else { return }
            swap(&self[$0], &self[index])
        }
        return self
    }
    var chooseOne: Element { return self[Int(arc4random_uniform(UInt32(count)))] }
    func choose(_ n: Int) -> Array { return Array(shuffled.prefix(n)) }
}
