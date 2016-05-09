//
//  PerformerOnboardingStore.swift
//  Soundarama
//
//  Created by Jamie Cox on 03/05/2016.
//  Copyright © 2016 Touchpress Ltd. All rights reserved.
//

class PerformerOnboardingStore {
    
    private let lock = NSRecursiveLock()
    
    private var timer: NSTimer?
    
    private var currentInstruction: PerformerInstruction?
    
    private var instructions: [PerformerInstruction] = []
    
    private let showHandler: PerformerInstruction -> ()
    
    private let hideHandler: PerformerInstruction -> ()
    
    private static func key(instruction: PerformerInstruction) -> String {
        
        switch instruction {
            
            case .ChargingInstruction: return "ChargingInstructionKey"
            
            case.CompassInstruction: return "CompassInstructionKey"
        }
    }
    
    init(showHandler: PerformerInstruction -> (), hideHandler: PerformerInstruction -> ()) {
        
        
        if !NSUserDefaults.standardUserDefaults().boolForKey(PerformerOnboardingStore.key(.CompassInstruction)) {
            instructions.append(.CompassInstruction)
        }
        
        if !NSUserDefaults.standardUserDefaults().boolForKey(PerformerOnboardingStore.key(.ChargingInstruction)) {
            
            instructions.append(.ChargingInstruction)
        }
        
        self.showHandler = showHandler
        self.hideHandler = hideHandler
    }
    
    func start() {
        
        scheduleNextInstruction()
    }
    
    func stop() {
        
        timer?.invalidate()
    }
    
    
    func requestHideInstruction(instruction: PerformerInstruction) {
        
        guard currentInstruction == instruction else {
            
            debugPrint("PerformerOnboardingStore: wierd state")
            return
        }
        
        lock.lock()
        currentInstruction = nil
        lock.unlock()
        
        hideHandler(instruction)
        scheduleNextInstruction()
    }
    
    func requestShowInstruction(instruction: PerformerInstruction) {
        
        guard currentInstruction == nil else {
        
            debugPrint("PerformerOnboardingStore invalid request")
            return
        }
        
        var ins = instructions.filter() { $0 != instruction }
        ins.insert(instruction, atIndex: 0)
        
        lock.lock()
        instructions = ins
        lock.unlock()
        
        executeNextInstruction()
    }
    
    private func scheduleNextInstruction() {
        
        guard instructions.count > 0 else {
            
            return
        }
    
        timer?.invalidate()
        timer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: #selector(executeNextInstruction), userInfo: nil, repeats: false)
    }
    
    @objc private func executeNextInstruction() {
        
        guard instructions.count > 0 else {
            
            return
        }
        
        let head = instructions.head
        let tail = instructions.tail
        
        lock.lock()
        currentInstruction = head
        instructions = tail
        lock.unlock()
        
        NSUserDefaults.standardUserDefaults().setBool(true, forKey: PerformerOnboardingStore.key(head))
        
        showHandler(head)
    }
}
