//
//  BroadcastService.swift
//  Soundarama
//
//  Created by Jamie Cox on 30/03/2016.
//  Copyright © 2016 Touchpress Ltd. All rights reserved.
//

class BroadcastService: NSObject {
    
    private var service: NSNetService!
    
    func stop() {
        
        service.stop()
    }
    
    static func broadcasting(domain: String, type: String, name: String, port: Int32) -> BroadcastService {
        
        let bs = BroadcastService()
    
        bs.service = NSNetService(domain: "local", type: "_soundarama_coxy._tcp.", name: name, port: port)
        bs.service.delegate = bs
        bs.service.publish()
        return bs
    }
}

extension BroadcastService: NSNetServiceDelegate {
    
    @objc func netServiceWillPublish(sender: NSNetService) {
        
        print("BroadcastService service will publish")
    }
    
    @objc func netServiceDidPublish(sender: NSNetService) {
        
        print("BroadcastService service published...")
    }
    
    @objc func netService(sender: NSNetService, didNotPublish errorDict: [String : NSNumber]) {
        
        print("BroadcastService service failed to publish")
    }
    
    @objc func netServiceDidResolveAddress(sender: NSNetService) {
        
        print("BroadcastService service did not resolve address")
    }
    
    @objc func netService(sender: NSNetService, didNotResolve errorDict: [String : NSNumber]) {
        
        print("BroadcastService service did not resolve \(errorDict)")
    }
    
    @objc func netServiceDidStop(sender: NSNetService) {
        
        print("BroadcastService service did stop")
    }
    
    @objc func netServiceWillResolve(sender: NSNetService) {
        
        print("BroadcastService service will resolve")
    }
}
