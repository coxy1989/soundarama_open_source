//
//  Math.swift
//  TouchpressKit
//
//  Created by Karim Sallam on 26/11/2015.
//  Copyright © 2015 Touchpress Ltd. All rights reserved.
//

import Foundation

extension Float {
    
    func round(decimalNumbers decimalNumbers: Int64) -> Float {
        
        let multiplayer = pow(10, Float(decimalNumbers))
        return Float(roundf(multiplayer * self) / multiplayer)
    }
}
