//
//  Resolvable.swift
//  Soundarama
//
//  Created by Jamie Cox on 16/04/2016.
//  Copyright © 2016 Touchpress Ltd. All rights reserved.
//

import Foundation
import Result
import ReactiveCocoa

protocol Resolvable: class {
    
    func resolve() -> SignalProducer<(String, UInt16), HandshakeError>
    
    func cancel()
}

class ResolvableNetService: NSObject {
    
    let netService: NSNetService
    
    private var success: ((String, UInt16) -> ())?
    
    private var failure: ([String : NSNumber] -> ())?
    
    private var cancelled: (() -> ())?
    
    init(netService: NSNetService) {
        
        self.netService = netService
        super.init()
        netService.delegate = self
    }
}

extension ResolvableNetService: Resolvable {
    
    func resolve() -> SignalProducer<(String, UInt16), HandshakeError> {
        
        return SignalProducer<(String, UInt16), HandshakeError> { [weak self] o, d in
            
            self?.success = {
                o.sendNext($0)
                o.sendCompleted()
            }
            
            self?.failure = { _ in o.sendFailed(.ResolveFailed) }
            
            self?.cancelled = { _ in o.sendFailed(.ResolveCancelled) }
            
            self?.netService.resolveWithTimeout(NetworkConfiguration.resolveTimeout)
        }
        .on(next: { debugPrint("resolve signal sent next: \($0)")})
        .on(completed: { debugPrint("resolve signal completed")})
        .on(failed: { debugPrint("resolve signal failed: \($0)")})
        .on(disposed: { debugPrint("resolve signal disposed")})
    }
    
    func cancel() {
        
        netService.stop()
        cancelled?()
    }
}

extension ResolvableNetService: NSNetServiceDelegate {
    
    func netServiceWillPublish(sender: NSNetService) {
        
        debugPrint("Net service will publish")
    }
    
    func netServiceDidPublish(sender: NSNetService) {
        
        debugPrint("Net service published...")
    }
    
    func netService(sender: NSNetService, didNotPublish errorDict: [String : NSNumber]) {
        
        debugPrint("Net service failed to publish")
    }
    
    func netServiceDidResolveAddress(sender: NSNetService) {
        
        guard let host = sender.hostName else {
            
            return
        }
        
        debugPrint("Net Service resolved address")
        
        success?(host, UInt16(sender.port))
        netService.stop()
    }
    
    func netService(sender: NSNetService, didNotResolve errorDict: [String : NSNumber]) {
        
        debugPrint("Net service did not resolve \(errorDict)")
        netService.stop()
        failure?(errorDict)
    }
    
    func netServiceDidStop(sender: NSNetService) {
        
        debugPrint("Net service did stop")
    }
    
    func netServiceWillResolve(sender: NSNetService) {
        
        debugPrint("Net service will resolve")
    }
}

