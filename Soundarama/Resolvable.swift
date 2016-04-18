//
//  Resolvable.swift
//  Soundarama
//
//  Created by Jamie Cox on 16/04/2016.
//  Copyright © 2016 Touchpress Ltd. All rights reserved.
//

import Foundation
import PromiseK
import Result

protocol Resolvable {
    
    func resolve() -> Promise<Result<(String, UInt16), ConnectionError>>
}

class ResolvableNetService: NSObject {
    
    let netService: NSNetService
    
    var success: ((String, UInt16) -> ())!
    
    var failure: ([String : NSNumber] -> ())!
    
    
    init(netService: NSNetService) {
        
        self.netService = netService
        super.init()
        netService.delegate = self
    }
}

extension ResolvableNetService: Resolvable {
    
    func resolve() -> Promise<Result<(String, UInt16), ConnectionError>> {
        
        netService.resolveWithTimeout(NetworkConfiguration.resolveTimeout)
        
        return Promise<Result<(String, UInt16), ConnectionError>> { [weak self] execute in
            
            self?.success = { v in
                
                let result = Result<(String, UInt16), ConnectionError>.Success(v)
                let promise = Promise<Result<(String, UInt16), ConnectionError>>(result)
                execute(promise)
            }
            
            self?.failure = { f in
                
                let result = Result<(String, UInt16), ConnectionError>.Failure(ConnectionError.ResolveFailed)
                let promise = Promise<Result<(String, UInt16), ConnectionError>>(result)
                execute(promise)
            }
        }
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
        
        netService.stop()
        success(host, UInt16(sender.port))
    }
    
    func netService(sender: NSNetService, didNotResolve errorDict: [String : NSNumber]) {
        
        debugPrint("Net service did not resolve \(errorDict)")
        netService.stop()
        failure(errorDict)
    }
    
    func netServiceDidStop(sender: NSNetService) {
        
        debugPrint("Net service did stop")
    }
    
    func netServiceWillResolve(sender: NSNetService) {
        
        debugPrint("Net service will resolve")
    }
}

