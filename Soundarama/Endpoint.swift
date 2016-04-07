//
//  Endpoint.swift
//  Soundarama
//
//  Created by Jamie Cox on 05/04/2016.
//  Copyright © 2016 Touchpress Ltd. All rights reserved.
//

import Foundation

protocol  DisconnectableEndpoint: Disconnectable, Endpoint { }

protocol Disconnectable {
    
    func disconnect()
    
    func onDisconnect(handler: () -> ())
}

protocol Endpoint: Readable, Writeable { }

typealias Address = String

protocol ReadableDelegate: class {
    
    func didReadData(data: NSData)
}

protocol Readable: class {
    
    weak var readableDelegate: ReadableDelegate? { get set }
    
    func readData(terminator: NSData)
}

protocol WriteableDelegate: class {
    
    func didWriteData()
}

protocol Writeable: class  {
    
    weak var writeableDelegate: WriteableDelegate? { get set }
    
    func writeData(data: NSData)
}
