//
//  WiFiReachability.swift
//  Soundarama
//
//  Created by Jamie Cox on 01/04/2016.
//  Copyright © 2016 Touchpress Ltd. All rights reserved.
//

class WiFiReachability {
    
    private var reachability: Reachability?
    
    private var reachable: (() -> ())!
    
    private var unreachable: (() -> ())!
    
    private var failure: (() -> ())!
    
    func isReachable() -> Bool {
        
        return reachability?.isReachable() ?? false
    }
    
    func stop() {
        
        reachability?.stopNotifier()
    }
    
    static func monitoringReachability(reachable: () -> (), unreachable: () -> (), failure: () -> ()) -> WiFiReachability {
        
        let wr = WiFiReachability()
        
        do {
            
            wr.reachability = try Reachability.reachabilityForInternetConnection()
        }
            
        catch {
            
            failure()
        }
        
        wr.reachability!.whenReachable = { reachability in
            
            dispatch_async(dispatch_get_main_queue()) {
                
                reachability.isReachableViaWiFi() ? reachable() : unreachable()
                
            }
        }
        
        wr.reachability!.whenUnreachable = { reachability in
            
            dispatch_async(dispatch_get_main_queue()) {
                
                unreachable()
                
            }
        }
        
        do {
            
            try wr.reachability!.startNotifier()
        }
            
        catch {
            
            failure()
            
        }
        
        return wr
    }
}
