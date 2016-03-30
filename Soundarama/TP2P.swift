//
//  TP2P.swift
//  Soundarama
//
//  Created by Jamie Cox on 25/01/2016.
//  Copyright © 2016 Touchpress Ltd. All rights reserved.
//

/* Representation of one end of a connection */

protocol Endpoint: Connectable, Readable, Writeable { }

/* Connect */

typealias Address = String

protocol Connectable: class {
    
    weak var connectionDelegate: ConnectableDelegate! { get set }
   
    func connect()
    
    func disconnect()
}

protocol ConnectableDelegate: class {
    
    func didConnectToAddress(address: Address)
    
    func didDisconnectFromAddress(address: Address)
    
}

/* Read */

protocol ReadableDelegate: class {
    
    func didReadData(data: NSData, address: Address)
}

protocol Readable: class {
    
    weak var readableDelegate: ReadableDelegate! { get set }
    
    func readData(terminator: NSData)
    
    func readData(terminator: NSData, address: Address)
}

/* Write */

protocol WriteableDelegate: class {
    
    func didWriteData(data: NSData)
}


protocol Writeable: class  {
    
    weak var writeableDelegate: WriteableDelegate? { get set }
    
    func writeData(data: NSData)
    
    func writeData(data: NSData, address: Address)
}
