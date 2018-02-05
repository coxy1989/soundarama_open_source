//
//  Queue.swift
//  TouchpressKit
//
//  Created by Karim Sallam on 14/12/2015.
//  Copyright © 2015 Touchpress Ltd. All rights reserved.
//

import Foundation

public class Queue<T> {
    
    public typealias Element = T
    
    private var _front: _QueueItem<Element>
    
    private var _back: _QueueItem<Element>
    
    public init () {
        
        // Insert dummy item. Will disappear when the first item is added.
        _back = _QueueItem(item: nil)
        _front = _back
    }
    
    /// Add a new item to the back of the queue.
    public func enqueue(element: Element) {
        
        _back.next = _QueueItem(item: element)
        _back = _back.next!
    }
    
    /// Return and remove the item at the front of the queue.
    public func dequeue () -> Element? {
        
        if let newhead = _front.next {
            _front = newhead
            return newhead.item
        } else {
            return nil
        }
    }
    
    public func isEmpty() -> Bool {
        
        return _front === _back
    }
}

private class _QueueItem<T> {
    
    let item: T!
    
    var next: _QueueItem?
    
    init(item: T?) {
        
        self.item = item
    }
}
