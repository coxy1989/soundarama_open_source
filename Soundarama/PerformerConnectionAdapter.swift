//
//  SubscriberConnectionAdapter.swift
//  Soundarama
//
//  Created by Jamie Cox on 25/01/2016.
//  Copyright © 2016 Touchpress Ltd. All rights reserved.
//

/* Is this indirection really necessary? .. the interactor knows about `Connectable` anyway. */

class PerformerConnectionAdapter: ConnectableDelegate {
    
    weak var delegate: PerformerConnectionAdapterDelegate!
    
    init(connection: Connectable) {
        
        connection.connectionDelegate = self
    }
    
    func didConnectToAddress(address: Address) {
        
        delegate.performerConnectionStateDidChange(.Connected)
    }
    
    func didDisconnectFromAddress(address: Address) {
        
        delegate.performerConnectionStateDidChange(.NotConnected)
    }
}

protocol PerformerConnectionAdapterDelegate: class {
    
    func performerConnectionStateDidChange(state: ConnectionState)
}