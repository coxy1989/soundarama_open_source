//
//  NSTimer.swift
//  TouchpressFoundation
//
//  Created by Jamie Cox on 23/02/2016.
//  Copyright © 2016 Touchpress. All rights reserved.
//

import Foundation


extension NSTimer {
    
    /* Ruthlessly plagiarised from https://gist.github.com/natecook1000/b0285b518576b22c4dc8 */
    
    /**
     Creates and schedules a one-time `NSTimer` instance.
     
     - Parameters:
     - delay: The delay before execution.
     - handler: A closure to execute after `delay`.
     
     - Returns: The newly-created `NSTimer` instance.
    
    Usage:
    
        NSTimer.schedule(delay: 5) { timer in
            print("5 seconds")
        
        }
     */
    
    public class func schedule(delay delay: NSTimeInterval, handler: NSTimer! -> Void) -> NSTimer {
        
        let fireDate = delay + CFAbsoluteTimeGetCurrent()
        let timer = CFRunLoopTimerCreateWithHandler(kCFAllocatorDefault, fireDate, 0, 0, 0, handler)
        CFRunLoopAddTimer(CFRunLoopGetCurrent(), timer, kCFRunLoopCommonModes)
        return timer
    }
    
    /**
     Creates and schedules a repeating `NSTimer` instance.
     
     - Parameters:
     - repeatInterval: The interval (in seconds) between each execution of
     `handler`. Note that individual calls may be delayed; subsequent calls
     to `handler` will be based on the time the timer was created.
     - handler: A closure to execute at each `repeatInterval`.
     
     - Returns: The newly-created `NSTimer` instance.
     
     Usage:
     
        var count = 0
        NSTimer.schedule(repeatInterval: 1) { timer in
            print(++count)
            if count >= 10 {
                timer.invalidate()
            }
        }
     */
    
    public class func schedule(repeatInterval interval: NSTimeInterval, handler: NSTimer! -> Void) -> NSTimer {
        
        let fireDate = interval + CFAbsoluteTimeGetCurrent()
        let timer = CFRunLoopTimerCreateWithHandler(kCFAllocatorDefault, fireDate, interval, 0, 0, handler)
        CFRunLoopAddTimer(CFRunLoopGetCurrent(), timer, kCFRunLoopCommonModes)
        return timer
    }
}

