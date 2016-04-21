//
//  SearchService.swift
//  Soundarama
//
//  Created by Jamie Cox on 30/03/2016.
//  Copyright © 2016 Touchpress Ltd. All rights reserved.
//

import ReactiveCocoa
import enum Result.NoError


struct ResolvableEnvelope {
    
    let resolvable: Resolvable
    
    let name: String
    
    let id: Int
}

enum SearchStreamEvent {
    
    case Found (ResolvableEnvelope)
    
    case Lost (ResolvableEnvelope)
}

class SearchService: NSObject {
    
    private var browser: NSNetServiceBrowser!
    
    private var stream: (SearchStreamEvent -> ())!
    
    private var stopped: (() -> ())?
    
    override init() {

        super.init()
        self.browser = NSNetServiceBrowser()
        self.browser.delegate = self
    }
    
    // TODO: make this an instance method
    
    static func start(searchService: SearchService, type: String, domain: String) -> SignalProducer<SearchStreamEvent, NoError> {
        
        searchService.browser.searchForServicesOfType(type, inDomain: domain)
        
        return SignalProducer<SearchStreamEvent, NoError> { s, d in
            
            searchService.stream = {
                
                s.sendNext($0)
            }
            
            searchService.stopped = {
                
                s.sendCompleted()
            }
        }
    }
} 

extension SearchService {
    
    func stop() {
        
        browser.stop()
        stopped?()
    }
}

extension SearchService: NSNetServiceBrowserDelegate {
    
    @objc func netServiceBrowserWillSearch(browser: NSNetServiceBrowser) {
        
        debugPrint("Browser will search")
    }
    
    @objc func netServiceBrowserDidStopSearch(browser: NSNetServiceBrowser) {
        
        debugPrint("Browser stopped searching")
    }
    
    @objc func netServiceBrowser(browser: NSNetServiceBrowser, didFindDomain domainString: String, moreComing: Bool) {
        
        debugPrint("Browser did find domian \(domainString)")
    }
    
    @objc func netServiceBrowser(browser: NSNetServiceBrowser, didNotSearch errorDict: [String : NSNumber]) {
        
        debugPrint("Browser did not search \(errorDict)")
    }
    
    @objc func netServiceBrowser(browser: NSNetServiceBrowser, didRemoveDomain domainString: String, moreComing: Bool) {
        
        debugPrint("Browser did remove domain")
    }
    
    @objc func netServiceBrowser(browser: NSNetServiceBrowser, didFindService service: NSNetService, moreComing: Bool) {
        
        debugPrint("Browser found service \(service.name)")
        let e = ResolvableEnvelope(resolvable: ResolvableNetService(netService: service), name: service.name, id: service.hash)
        stream(SearchStreamEvent.Found(e))
    }
    
    @objc func netServiceBrowser(browser: NSNetServiceBrowser, didRemoveService service: NSNetService, moreComing: Bool) {
        
        debugPrint("Browser removed service")
        let e = ResolvableEnvelope(resolvable: ResolvableNetService(netService: service), name: service.name, id: service.hash)
        stream(SearchStreamEvent.Lost(e))
    }
}
