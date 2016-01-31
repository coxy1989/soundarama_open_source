//
//  UIDevice.swift
//  Soundarama
//
//  Created by Jamie Cox on 29/01/2016.
//  Copyright © 2016 Touchpress Ltd. All rights reserved.
//

import UIKit

extension UIDevice {
    
    static func isPad() -> Bool {
        
        return UIDevice.currentDevice().userInterfaceIdiom == .Pad
    }
}