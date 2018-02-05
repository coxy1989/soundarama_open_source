//
//  CompassValueStore.swift
//  Soundarama
//
//  Created by Jamie Cox on 04/05/2016.
//  Copyright © 2016 Touchpress Ltd. All rights reserved.
//

import Foundation

class SamplingValueStore {
    
    private var values: [(NSTimeInterval, Double)] = []
    
    private var timer: NSTimer?
    
    private let interval: NSTimeInterval
    
    private let handler: Double -> ()
    
    private let lock = NSRecursiveLock()
    
    init(interval: NSTimeInterval, handler: Double -> ()) {
        
        self.interval = interval
        self.handler = handler
    }
    
    func addValue(value: Double) {
        
        lock.lock()
        values.append((NSDate().timeIntervalSince1970, value))
        lock.unlock()
    }
    
    func start() {
        
        timer = NSTimer.scheduledTimerWithTimeInterval(interval, target: self, selector: #selector(sample), userInfo: nil, repeats: true)
    }
    
    func stop() {
        
        timer?.invalidate()
    }
    
    @objc func sample() {
        
        let buf = buffer(NSDate().timeIntervalSince1970 - interval)
        let norm = buf.map() { abs($0 - 180) }
        let max = norm.maxElement() ?? 0
        let min = norm.minElement() ?? 0
        handler(max - min)
        flush()
    }
    
    private func buffer(since: NSTimeInterval) -> [Double] {
        
        return values.filter() { $0.0 > since }.map() { $0.1 }
    }
    
    private func flush() {
        
        lock.lock()
        values.removeAll()
        lock.unlock()
    }
}
