//
//  WiFiReachability.swift
//  Soundarama
//
//  Created by Jamie Cox on 01/04/2016.
//  Copyright © 2016 Touchpress Ltd. All rights reserved.
//

import ReactiveCocoa
import enum Result.NoError

enum WifiReachabilityEvent {
    
    case Reachable
    
    case Unreachable
}

class WiFiReachability {
    
    private var reachability: Reachability?
    
    private var reachable: (() -> ())!
    
    private var unreachable: (() -> ())!
    
    private var failure: (() -> ())!
    
    func reactiveReachability() -> SignalProducer<WifiReachabilityEvent, WifiReachabilityError> {
        
        return SignalProducer<WifiReachabilityEvent, WifiReachabilityError> { [weak self] observer, disposable in

            do {
                
                self?.reachability = try Reachability.reachabilityForInternetConnection()
                try self?.reachability?.startNotifier()
            }
                
            catch {
                
                observer.sendFailed(.ReachabilityFailed)
            }
            
            self?.reachability?.whenReachable = { reachability in
                
                reachability.isReachableViaWiFi() ? observer.sendNext(.Reachable) : observer.sendNext(.Unreachable)
            }
            
            self?.reachability?.whenUnreachable = { reachability in
                
                observer.sendNext(.Unreachable)
            }
            
            self?.reachability?.whenStopped = {
                
                observer.sendCompleted()
            }
        }
    }
    
    
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
