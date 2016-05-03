//
//  PerformerOnboardingStore.swift
//  Soundarama
//
//  Created by Jamie Cox on 03/05/2016.
//  Copyright © 2016 Touchpress Ltd. All rights reserved.
//

//TODO: This is Grim! Re-implement with Signals.

class PerformerOnboardingStore {
    
    private let lock = NSRecursiveLock()
    
    private var timer: NSTimer?
    
    private var instructions: [PerformerInstruction] = []
    
    private let handler: PerformerInstruction -> ()
    
    private static func key(instruction: PerformerInstruction) -> String {
        
        switch instruction {
            
            case .ChargingInstruction: return "ChargingInstructionKey"
            
            case.CompassInstruction: return "CompassInstructionKey"
        }
    }
    
    init(handler: PerformerInstruction -> ()) {
        
        if !NSUserDefaults.standardUserDefaults().boolForKey(PerformerOnboardingStore.key(.CompassInstruction)) {
            
            instructions.append(.CompassInstruction)
        }
        
        if !NSUserDefaults.standardUserDefaults().boolForKey(PerformerOnboardingStore.key(.ChargingInstruction)) {
            
            instructions.append(.ChargingInstruction)
        }
        
        self.handler = handler
    }
    
    func scheduleNextInstruction() {
        
        guard instructions.count > 0 else {
            
            return
        }
    
        timer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: #selector(executeNextInstruction), userInfo: nil, repeats: false)
    }
    
    @objc func executeNextInstruction() {
        
        guard instructions.count > 0 else {
            
            return
        }
        
        lock.lock()
        let next = instructions.head
        let rest = instructions.tail
        instructions = rest
        lock.unlock()
        
        handler(next)
    }
    
    func descheduleInstruction(instruction: PerformerInstruction) {
        
        lock.lock()
        instructions = instructions.filter() { $0 != instruction }
        lock.unlock()
        
        NSUserDefaults.standardUserDefaults().setBool(true, forKey: PerformerOnboardingStore.key(instruction))
    }
    
    func stop() {
        
        timer?.invalidate()
    }
}
