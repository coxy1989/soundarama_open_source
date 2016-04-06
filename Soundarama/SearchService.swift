//
//  SearchService.swift
//  Soundarama
//
//  Created by Jamie Cox on 30/03/2016.
//  Copyright © 2016 Touchpress Ltd. All rights reserved.
//

class SearchService: NSObject {
    
    private let browser: NSNetServiceBrowser
    
    private let found: (String, Resolvable) -> ()
    
    private let lost: (String, Resolvable) -> ()
    
    private init(browser: NSNetServiceBrowser, lost: (String, Resolvable) -> (), found: (String, Resolvable) -> ()) {
        
        self.lost = lost
        self.found = found
        self.browser = browser
    }
    
    func stop() {
        
        browser.stop()
    }
    
    static func searching(type: String, domain: String, found: (String, Resolvable) -> (), lost: (String, Resolvable) -> (), failed: () -> ()) -> SearchService {
        
        let bs = NSNetServiceBrowser()
        let ss = SearchService(browser: bs, lost: lost, found: found)
        bs.delegate = ss
        ss.browser.searchForServicesOfType(type, inDomain: domain)
        return ss
    }
}

extension SearchService: NSNetServiceBrowserDelegate {
    
    @objc func netServiceBrowserWillSearch(browser: NSNetServiceBrowser) {
        
        print("Browser will search")
    }
    
    @objc func netServiceBrowserDidStopSearch(browser: NSNetServiceBrowser) {
        
        print("Browser stopped searching")
    }
    
    @objc func netServiceBrowser(browser: NSNetServiceBrowser, didFindDomain domainString: String, moreComing: Bool) {
        
        print("Browser did find domian \(domainString)")
    }
    
    @objc func netServiceBrowser(browser: NSNetServiceBrowser, didNotSearch errorDict: [String : NSNumber]) {
        
        print("Browser did not search \(errorDict)")
    }
    
    @objc func netServiceBrowser(browser: NSNetServiceBrowser, didRemoveDomain domainString: String, moreComing: Bool) {
        
        print("Browser did remove domain")
    }
    
    @objc func netServiceBrowser(browser: NSNetServiceBrowser, didFindService service: NSNetService, moreComing: Bool) {
        
        print("Browser found service \(service.name)")
        found(service.name, ResolvableNetService(netService: service))
    }
    
    @objc func netServiceBrowser(browser: NSNetServiceBrowser, didRemoveService service: NSNetService, moreComing: Bool) {
        
        print("Browser removed service")
        lost(service.name, ResolvableNetService(netService: service))
    }
}


protocol Resolvable {
    
    func resolveWithTimeout(timeout: NSTimeInterval, success: (host: String, port: UInt16) -> (), failure: [String : NSNumber] -> ())
}

class ResolvableNetService: NSObject {
    
    let netService: NSNetService
    
    var success: ((String, UInt16) -> ())!
    
    var failure: ([String : NSNumber] -> ())!
    
    private init(netService: NSNetService) {
        
        self.netService = netService
        super.init()
        netService.delegate = self
    }
}

extension ResolvableNetService: Resolvable {
    
    func resolveWithTimeout(timeout: NSTimeInterval, success: (host: String, port: UInt16) -> (), failure: [String : NSNumber] -> ()) {
        
        
        self.success = success
        self.failure = failure
        netService.resolveWithTimeout(timeout)
    }
}

extension ResolvableNetService: NSNetServiceDelegate {
    
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
        
        guard let host = sender.hostName else {
            
            return
        }
        
        print("Net Service resolved address")
        
        success(host, UInt16(sender.port))
    }
    
    func netService(sender: NSNetService, didNotResolve errorDict: [String : NSNumber]) {
        
        print("Net service did not resolve \(errorDict)")
        failure(errorDict)
    }
    
    func netServiceDidStop(sender: NSNetService) {
        
        print("Net service did stop")
    }
    
    func netServiceWillResolve(sender: NSNetService) {
        
        print("Net service will resolve")
    }
}
