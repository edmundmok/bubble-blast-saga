//
//  Queue.swift
//  GameEngine
//
//  Created by Edmund Mok on 9/2/17.
//  Copyright © 2017 nus.cs3217.a0093960x. All rights reserved.
//

/**
 An enum of errors that can be thrown from the `Queue` struct.
 */
enum QueueError: Error {
    /// Thrown when trying to access an element from an empty queue.
    case emptyQueue
}


/**
 A generic `Queue` class whose elements are first-in, first-out.
 
 - Authors: CS3217
 - Date: 2017
 */
public struct Queue<T> {
    private var array = [T]()
    
    public init() {
    }
    
    /// Adds an element to the tail of the queue.
    /// - Parameter item: The element to be added to the queue
    mutating func enqueue(_ item: T) {
        array.append(item)
    }
    
    /// Removes an element from the head of the queue and return it.
    /// - Returns: item at the head of the queue
    /// - Throws: QueueError.EmptyQueue
    mutating func dequeue() throws -> T {
        if isEmpty {
            throw QueueError.emptyQueue
        }
        return array.removeFirst()
    }
    
    /// Returns, but does not remove, the element at the head of the queue.
    /// - Returns: item at the head of the queue
    /// - Throws: QueueError.EmptyQueue
    func peek() throws -> T {
        if isEmpty {
            throw QueueError.emptyQueue
        }
        return array.first!
    }
    
    /// The number of elements currently in the queue.
    var count: Int {
        return array.count
    }
    
    /// Whether the queue is empty.
    var isEmpty: Bool {
        return array.isEmpty
    }
    
    /// Removes all elements in the queue.
    mutating func removeAll() {
        array.removeAll()
    }
    
    /// Returns an array of the elements in their respective dequeue order, i.e.
    /// first element in the array is the first element to be dequeued.
    /// - Returns: array of elements in their respective dequeue order
    func toArray() -> [T] {
        return array
    }
}
