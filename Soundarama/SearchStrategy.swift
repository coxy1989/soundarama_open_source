//
//  SearchStrategy.swift
//  Soundarama
//
//  Created by Jamie Cox on 25/01/2016.
//  Copyright © 2016 Touchpress Ltd. All rights reserved.
//

protocol SearchStrategyDelegate: class {
    
    func searchStrategyDidFindHost(strategy: SearchStrategy, host: String, port: Int)
}

class SearchStrategy: NSObject {
    
    weak var delegate: SearchStrategyDelegate!
    
    private lazy var serviceBrowser: NSNetServiceBrowser = {
        let b = NSNetServiceBrowser()
        b.delegate = self
        return b
    }()
    
    func search() {
        
        serviceBrowser.searchForServicesOfType("_soundarama_coxy._tcp.", inDomain: "local")
    }
    
    private var service: NSNetService?
}

extension SearchStrategy: NSNetServiceBrowserDelegate {
    
    func netServiceBrowserWillSearch(browser: NSNetServiceBrowser) {
        
        print("Browser will search")
    }
    
    func netServiceBrowserDidStopSearch(browser: NSNetServiceBrowser) {
        
        print("Browser stopped searching")
    }
    
    func netServiceBrowser(browser: NSNetServiceBrowser, didFindDomain domainString: String, moreComing: Bool) {
        
        print("Browser did find domian \(domainString)")
    }
    
    func netServiceBrowser(browser: NSNetServiceBrowser, didNotSearch errorDict: [String : NSNumber]) {
        
        print("Browser did not search \(errorDict)")
    }

    func netServiceBrowser(browser: NSNetServiceBrowser, didRemoveDomain domainString: String, moreComing: Bool) {
        
        print("Browser did remove domain")
    }
    
    func netServiceBrowser(browser: NSNetServiceBrowser, didFindService service: NSNetService, moreComing: Bool) {
        
        print("Browser found service \(service.name)")
        self.service = service
        self.service?.delegate = self
        self.service?.resolveWithTimeout(5)
    }
    
    func netServiceBrowser(browser: NSNetServiceBrowser, didRemoveService service: NSNetService, moreComing: Bool) {
        
        print("Browser removed service")
        /* keep retrying if we lose the service */
        search()
    }
}

extension SearchStrategy: NSNetServiceDelegate {
    
    func netServiceDidResolveAddress(service: NSNetService) {
        
        print("Resolved host: \(service.domain), \(service.hostName), \(service.addresses), \(service.port)")
        if let host = service.hostName {
            delegate.searchStrategyDidFindHost(self, host: host, port: service.port)
        }
    }
    
    func netService(sender: NSNetService, didNotResolve errorDict: [String : NSNumber]) {
        
        print("Failed to resolve service")
        /* keep retrying if we encounter a failure */
        service?.resolveWithTimeout(5)
    }
}
