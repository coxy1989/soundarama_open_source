//
//  BroadcastStrategy.swift
//  Soundarama
//
//  Created by Jamie Cox on 25/01/2016.
//  Copyright © 2016 Touchpress Ltd. All rights reserved.
//

class BroadcastStrategy: NSObject {
    
    private let tcpPort: Int32
    
    private lazy var service: NSNetService = { [unowned self] in
        
        let s = NSNetService(domain: "local", type: "_soundarama_coxy._tcp.", name: "coxy", port: self.tcpPort)
        s.delegate = self
        return s
    }()
    
    init(tcpPort: Int32) {
        
        self.tcpPort = tcpPort
    }
    
    func broadcast() {
        
        service.publish()
    }
}

extension BroadcastStrategy: NSNetServiceDelegate {
    
    func netServiceWillPublish(sender: NSNetService) {
        
        print("Net service will publish")
    }
    
    func netServiceDidPublish(sender: NSNetService) {
        
        print("Net service published...")
    }
    
    func netService(sender: NSNetService, didNotPublish errorDict: [String : NSNumber]) {
        
        print("Net service failed to publish")
    }
    
    func netServiceDidResolveAddress(sender: NSNetService) {
        
        print("Net service did not resolve address")
    }
    
    func netService(sender: NSNetService, didNotResolve errorDict: [String : NSNumber]) {
        
        print("Net service did not resolve \(errorDict)")
    }
    
    func netServiceDidStop(sender: NSNetService) {
        
        print("Net service did stop")
    }
    
    func netServiceWillResolve(sender: NSNetService) {
        
        print("Net service will resolve")
    }
}

