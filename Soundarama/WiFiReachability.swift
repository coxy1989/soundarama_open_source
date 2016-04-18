//
//  WiFiReachability.swift
//  Soundarama
//
//  Created by Jamie Cox on 01/04/2016.
//  Copyright © 2016 Touchpress Ltd. All rights reserved.
//

import ReactiveCocoa
import enum Result.NoError

class WifiError: ErrorType {
    
}

class WiFiReachability2 {
    
    static func reachability(r: Reachability) -> SignalProducer<Bool, Result.NoError> {
        
        return SignalProducer<Bool, NoError> { observer, disposable in
    
            r.whenReachable = { reachability in
                
                reachability.isReachableViaWiFi() ? observer.sendNext(true) : observer.sendNext(false)
            }
            
            r.whenUnreachable = { reachability in
                
                observer.sendNext(false)
            }
            
            r.whenStopped = {
                
                observer.sendCompleted()
            }
        }
    }
}

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
