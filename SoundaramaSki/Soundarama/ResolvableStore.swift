//
//  ResolvableStore.swift
//  Soundarama
//
//  Created by Jamie Cox on 05/04/2016.
//  Copyright © 2016 Touchpress Ltd. All rights reserved.
//

class ResolvableStore {
    
    private let lock = NSRecursiveLock()
    
    private var envelopes: [ResolvableEnvelope] = []
    
    func getEnvelopes() -> [ResolvableEnvelope] {
        
        return envelopes
    }
    
    func addEnvelope(envelope: ResolvableEnvelope) {
        
        lock.lock()
        envelopes.append(envelope)
        lock.unlock()
    }
    
    func removeEnvelope(id: Int) {
        
        lock.lock()
        envelopes = envelopes.filter() { $0.id != id }
        lock.unlock()
    }
    
    func removeAllEnvelopes() {
        
        lock.lock()
        envelopes.removeAll()
        lock.unlock()
    }
    
    func getEnvelope(id: Int) -> ResolvableEnvelope? {
        
        return envelopes.filter() { $0.id == id }.first
    }
}