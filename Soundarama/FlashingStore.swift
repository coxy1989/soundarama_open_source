//
//  FlashingStore.swift
//  Soundarama
//
//  Created by Jamie Cox on 04/05/2016.
//  Copyright © 2016 Touchpress Ltd. All rights reserved.
//

import Foundation
import UIKit

class FlashingStore {
    
    private static let loop_time = 1.9512195122 / 2
    
    private let referenceTime: NSTimeInterval
    
    private let handler: (CGFloat, NSTimeInterval) -> ()
    
    private var timer: NSTimer?
    
    init(referenceTime: NSTimeInterval, handler: (CGFloat, NSTimeInterval) -> ()) {
        
        self.referenceTime = referenceTime
        self.handler = handler
    }
    
    func start() {
        
        //let t = referenceTime % loop_time
        
        // let looptime = dispatch_time(DISPATCH_TIME_NOW, Int64(45.0 * Double(NSEC_PER_SEC)))
        // dispatch_after(looptime, dispatch_get_main_queue()) { [weak self] in
        
        // }
        
        handler(0.25, 0)
        peak()
    }
    
    func stop() {
        
        timer?.invalidate()
    }
    
    @objc private func trough() {
        
        handler(0.25,Double(FlashingStore.loop_time * 0.1))
        timer = NSTimer.scheduledTimerWithTimeInterval(FlashingStore.loop_time * 0.1, target: self, selector: #selector(peak), userInfo: nil, repeats: false)
    }
    
    @objc private func peak() {
        
        handler(CGFloat(0), Double(FlashingStore.loop_time * 0.9))
        timer = NSTimer.scheduledTimerWithTimeInterval(FlashingStore.loop_time * 0.9, target: self, selector: #selector(trough), userInfo: nil, repeats: false)
    }
}
