//
//  Functional.swift
//  Soundarama
//
//  Created by Jamie Cox on 17/03/2016.
//  Copyright © 2016 Touchpress Ltd. All rights reserved.
//

protocol Butcher {
    
    typealias T
    
    var head: T { get }
    
    var tail: Array<T> { get }
}

extension Array: Butcher {
    
    var head: Element {

        get { return self[0] }
    }
    
    var tail: Array<Element> {
        get {
            return self.count > 1 ? Array(self[1..<self.count]) : []
        }
    }
}
