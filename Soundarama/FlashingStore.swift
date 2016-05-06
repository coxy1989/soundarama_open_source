//
//  FlashingStore.swift
//  Soundarama
//
//  Created by Jamie Cox on 04/05/2016.
//  Copyright © 2016 Touchpress Ltd. All rights reserved.
//

import Foundation
import UIKit

/* TODO: Threas safety */

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

        /* TODO: Sync to reference time */
        
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
