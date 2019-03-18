//
//  GCD.swift
//  Soundarama
//
//  Created by Jamie Cox on 19/04/2016.
//  Copyright © 2016 Touchpress Ltd. All rights reserved.
//

import Foundation

func delay(seconds: NSTimeInterval, queue: dispatch_queue_t, block: () -> ()) {
    
    let time = dispatch_time(DISPATCH_TIME_NOW, Int64((seconds) * Double(NSEC_PER_SEC)))
    dispatch_after(time, queue, block)
}