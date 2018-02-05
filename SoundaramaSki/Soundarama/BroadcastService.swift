//
//  BroadcastService.swift
//  Soundarama
//
//  Created by Jamie Cox on 30/03/2016.
//  Copyright © 2016 Touchpress Ltd. All rights reserved.
//

import ReactiveCocoa

class BroadcastService: NSObject {
    
    private var service: NSNetService?
    
    private var events: ((BroadcastEvent) -> ())?
    
    private var errors: ((BroadcastError) -> ())?
    
    private var stopped: (() -> ())?
    
    func stop() {
        
        service?.stop()
        stopped?()
    }
    
    func broadcast(domain: String, type: String, name: String, port: Int32) -> SignalProducer<BroadcastEvent, BroadcastError> {
        
        return SignalProducer<BroadcastEvent, BroadcastError> { [weak self] o, d in
        
            self?.service = NSNetService(domain: domain, type: type, name: name, port: port)
            self?.service?.delegate = self
            self?.service?.publish()
            
            self?.events = {
                
                o.sendNext($0)
            }
            
            self?.errors = {
                
                o.sendFailed($0)
            }
            
            self?.stopped = {
                
                o.sendCompleted()
            }
        }
    }
}

extension BroadcastService: NSNetServiceDelegate {
    
    @objc func netServiceWillPublish(sender: NSNetService) {
        
        debugPrint("BroadcastService service will publish")
    }
    
    @objc func netServiceDidPublish(sender: NSNetService) {
        
        debugPrint("BroadcastService service published...")
        events?(.Up)
    }
    
    @objc func netService(sender: NSNetService, didNotPublish errorDict: [String : NSNumber]) {
        
        debugPrint("BroadcastService service failed to publish")
        errors?(.BroadcastFailed)
    }
    
    @objc func netServiceDidResolveAddress(sender: NSNetService) {
        
        debugPrint("BroadcastService service did not resolve address")
    }
    
    @objc func netService(sender: NSNetService, didNotResolve errorDict: [String : NSNumber]) {
        
        debugPrint("BroadcastService service did not resolve \(errorDict)")
    }
    
    @objc func netServiceDidStop(sender: NSNetService) {
        
        debugPrint("BroadcastService service did stop")
    }
    
    @objc func netServiceWillResolve(sender: NSNetService) {
        
        debugPrint("BroadcastService service will resolve")
    }
}

/*
 
 static func broadcasting(domain: String, type: String, name: String, port: Int32) -> BroadcastService {
 
 let bs = BroadcastService()
 
 //TODO: move constants to NetworkConfig
 
 bs.service = NSNetService(domain: "local", type: "_soundarama_coxy._tcp.", name: name, port: port)
 bs.service.delegate = bs
 bs.service.publish()
 return bs
 }
 
 */