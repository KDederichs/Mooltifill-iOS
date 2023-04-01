//
//  Queue.swift
//  Mooltifill
//
//  Created by Kai Dederichs on 01.04.23.
//

import Foundation

struct Queue<T>: CustomStringConvertible
{
    var front: QueueNode<T>?
    var rear: QueueNode<T>?
    
    init() {}
    
    var isEmpty: Bool {
        return front == nil
    }
    
    var description: String {
        guard let front = front else {return "Empty Queue"}
        return String(describing: front)
    }
    
    var peek: T? {
        return front?.value
    }
}


extension Queue {
    mutating private func push(_ value:T) {
        front = QueueNode(value: value, next: front)
        if rear == nil {
            rear = front
        }
    }
    
    mutating func enqueue(_ value:T) {
        if isEmpty {
            self.push(value)
            return
        }
        rear?.next = QueueNode(value: value)
        rear = rear?.next
    }
    
    mutating func dequeue() -> T? {
        defer {
            front = front?.next
            if isEmpty {
                rear = nil
            }
        }
        return front?.value
    }
}
