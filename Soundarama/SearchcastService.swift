//
//  SearchcastService.swift
//  Soundarama
//
//  Created by Jamie Cox on 31/03/2016.
//  Copyright © 2016 Touchpress Ltd. All rights reserved.
//

class SearchcastService {
    
    private var search: SearchService?
    
    private var broadcast: BroadcastService?
    
    static func searching(type: String, domain: String, added: String -> (), removed: String -> ()) -> SearchcastService {
     
        let service = SearchcastService()
        service.search = SearchService.searching(type, domain: domain, found: { added($0.0) }, lost: { removed($0.0) }, failed: {})
        return service
    }
    
    func broadcast(type: String, domain: String, port: Int32, identifier: String) {
        
        broadcast = BroadcastService.broadcasting(domain, type: type, name: identifier, port: port)
    }
    
    func stop() {
        
        search?.stop()
        broadcast?.stop()
    }
}
