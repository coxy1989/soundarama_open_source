//
//  TP2P.swift
//  Soundarama
//
//  Created by Jamie Cox on 25/01/2016.
//  Copyright © 2016 Touchpress Ltd. All rights reserved.
//

/* Connect */

typealias Address = String

protocol Connectable: class {
    
    weak var connectionDelegate: ConnectableDelegate! { get set }
    
    func connect(strategy: ConnectableStrategy)
}

protocol ConnectableDelegate: class {
    
    func didConnectToAddress(address: Address)
    
    func didDisconnectFromAddress(address: Address)
    
}

enum ConnectableStrategy {
    
    case Search, Broadcast
}

protocol ReadableDelegate: class {
    
    func didReadData(data: NSData)
}

protocol Readable: class {
    
    weak var readableDelegate: ReadableDelegate! { get set }
    
    func readData(terminator: NSData)
}

protocol Writeable {
    
    func writeData(data: NSData, address: Address)
}

protocol Endpoint: Connectable, Readable, Writeable { }

struct TP2P {
    
    static func endpoint() -> Endpoint {
        
        return SocketEndpoint()
    }
}


    /*
    static func publisher() -> Publishable {
        
        return Publisher()
    }
    
    static func subscriber() -> Subscribable {
        
        return Subscriber()
    }
*/


/* Publish */

/*
protocol Publishable: Connectable {
    
    func publish(data: NSData)
    
    func publish(data: NSData, address: Address)
    
}

/* Subscribe */

protocol Subscribable: class, Connectable {
    
    weak var subscriberDelegate: SubscriberDelegate! { get set }
    
    func readData(terminator: NSData)
}

protocol SubscriberDelegate: class {
    
    func didRecieveData(data: NSData)
}
*/
/* PubScribe */

//protocol PubScribable: Publishable, Subscribable {  }

/* Dependecy Inversion */
