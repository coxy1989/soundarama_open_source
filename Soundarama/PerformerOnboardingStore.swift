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
    
    private static func instructionsFromUserDefaults() -> [PerformerInstruction] {
        
        var i: [PerformerInstruction] = []
        let defs = NSUserDefaults.standardUserDefaults()
        
        if !defs.boolForKey(PerformerOnboardingStore.key(.CompassInstruction)) {
            
            i.append(.CompassInstruction)
        }
        
        if !defs.boolForKey(PerformerOnboardingStore.key(.ChargingInstruction)) {
            
            i.append(.ChargingInstruction)
        }
        
        return i
    }
    
    private static func flushInstructionsFromUserDefaults() {
        
        let defs = NSUserDefaults.standardUserDefaults()
        defs.setBool(false, forKey: PerformerOnboardingStore.key(.CompassInstruction))
        defs.setBool(false, forKey: PerformerOnboardingStore.key(.ChargingInstruction))
    }
    
    init(showHandler: PerformerInstruction -> (), hideHandler: PerformerInstruction -> ()) {
        
        self.showHandler = showHandler
        self.hideHandler = hideHandler
    }
    
    func start() {
        
        loadInstructionsFromUserDefaults()
        scheduleNextInstruction()
    }
    
    func stop() {
        
        timer?.invalidate()
    }
    
    func restart() {
        
        guard currentInstruction == nil else {
            
            return
        }
        
        PerformerOnboardingStore.flushInstructionsFromUserDefaults()
        loadInstructionsFromUserDefaults()
        executeNextInstruction()
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
    
    private func loadInstructionsFromUserDefaults() {
        
        lock.lock()
        instructions = PerformerOnboardingStore.instructionsFromUserDefaults()
        lock.unlock()
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
