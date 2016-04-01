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

/*
class ResolveService {
   
    private let resolvable: Resolvable
    
    private init(resolvable: Resolvable) {
    
        self.resolvable = resolvable
    }
    
    static func resolving(resolvable: Resolvable, timeout: NSTimeInterval) -> ResolveService {
        
        let rs = ResolveService(resolvable: resolvable)
        //resolvable.resolveWithTimeout(timeout)
        return rs
    }
}
*/

protocol Resolvable {
    
    func resolveWithTimeout(timeout: NSTimeInterval, success: (host: String, port: UInt16) -> (), failure: [String : NSNumber] -> ())
}

class ResolvableNetService: Resolvable {
    
    let netService: NSNetService
    
    private init(netService: NSNetService) {
        
        self.netService = netService
    }
    
    func resolveWithTimeout(timeout: NSTimeInterval, success: (host: String, port: UInt16) -> (), failure: [String : NSNumber] -> ()) {
        
        netService.resolveWithTimeout(timeout)
        
        //TODO route delegates methods to callbacks
    }
}
