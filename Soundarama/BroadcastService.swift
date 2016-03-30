//
//  BroadcastService.swift
//  Soundarama
//
//  Created by Jamie Cox on 30/03/2016.
//  Copyright © 2016 Touchpress Ltd. All rights reserved.
//

class BroadcastService: NSObject {
    
    private var service: NSNetService!
    
    static func broadcasting(domain: String, type: String, name: String, port: Int32, failure: ([String : NSNumber]) -> ()) -> BroadcastService {
        
        let bs = BroadcastService()
        bs.service = NSNetService(domain: "local", type: "_soundarama_coxy._tcp.", name: name, port: port)
        bs.service.delegate = bs
        bs.service.publish()
        return bs
    }
}

extension BroadcastService: NSNetServiceDelegate {
    
    @objc func netServiceWillPublish(sender: NSNetService) {
        
        print("Net service will publish")
    }
    
    @objc func netServiceDidPublish(sender: NSNetService) {
        
        print("Net service published...")
    }
    
    @objc func netService(sender: NSNetService, didNotPublish errorDict: [String : NSNumber]) {
        
        print("Net service failed to publish")
    }
    
    @objc func netServiceDidResolveAddress(sender: NSNetService) {
        
        print("Net service did not resolve address")
    }
    
    @objc func netService(sender: NSNetService, didNotResolve errorDict: [String : NSNumber]) {
        
        print("Net service did not resolve \(errorDict)")
    }
    
    @objc func netServiceDidStop(sender: NSNetService) {
        
        print("Net service did stop")
    }
    
    @objc func netServiceWillResolve(sender: NSNetService) {
        
        print("Net service will resolve")
    }
}
