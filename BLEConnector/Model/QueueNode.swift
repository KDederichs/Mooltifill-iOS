//
//  QueueNode.swift
//  Mooltifill
//
//  Created by Kai Dederichs on 01.04.23.
//

import Foundation

class QueueNode<T>: CustomStringConvertible
{
    var value: T
    var next: QueueNode?
    
    var description: String {
        guard let next = next else {return "\(value)"}
        return "\(value) -> " + String(describing: next)
    }
    
    init(value: T, next: QueueNode? = nil) {
        self.value = value
        self.next = next
    }
}
