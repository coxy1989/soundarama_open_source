//
//  UIFont.swift
//  Soundarama
//
//  Created by Jamie Cox on 30/01/2016.
//  Copyright © 2016 Touchpress Ltd. All rights reserved.
//

import UIKit

extension UIFont {
    
    class func fontAttribute(font: UIFont) -> [String : UIFont] {
        
        return [NSFontAttributeName : font]
    }
}

extension UIFont {
    
    class func avenirLight(size: CGFloat) -> UIFont {
        
        return UIFont.customFontWithName("Avenir-Light", size: size)
    }
    
    class func avenirHeavy(size: CGFloat) -> UIFont {
        
        return UIFont.customFontWithName("Avenir-Heavy", size: size)
    }
    
    class func avenirRoman(size: CGFloat) -> UIFont {
        
        return UIFont.customFontWithName("Avenir-Roman", size: size)
    }
}

extension UIFont {
    
    private class func customFontWithName(name: String, size: CGFloat) -> UIFont {
        
        if let font = UIFont(name: name, size: size) {
            return font
        }
        #if !TARGET_INTERFACE_BUILDER
            assert(false, "Font \(name) failed to load") //IBDesignables sometimes fail to load fonts
        #endif
        return UIFont.systemFontOfSize(size)
    }
}