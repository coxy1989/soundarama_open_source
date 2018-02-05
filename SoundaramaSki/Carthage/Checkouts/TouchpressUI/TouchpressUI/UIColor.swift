//
//  Types.swift
//  TouchpressKit
//
//  Created by Karim Sallam on 16/12/2015.
//  Copyright © 2015 Touchpress Ltd. All rights reserved.
//

import UIKit

public let RGBColorBlack = RGBColorMake(0, 0, 0)

public struct RGBColor {
    
    public var red: Float
    public var green: Float
    public var blue: Float
}

public func RGBColorMake(red: Float, _ green: Float, _ blue: Float) -> RGBColor {
    
    return RGBColor(red: red, green: green, blue: blue)
}

public func RGBColorMakeWithColor(color: UIColor) -> RGBColor {
    
    var red: CGFloat = 0, green: CGFloat = 0, blue: CGFloat = 0, alpha: CGFloat = 0
    
    guard color.getRed(&red, green: &green, blue: &blue, alpha: &alpha) else {
        return RGBColorBlack
    }
    
    return RGBColorMake(Float(red), Float(green), Float(blue))
}

extension UIColor {
    
    func darkerColor() -> UIColor? {
        
        var h: CGFloat = 0
        var s: CGFloat = 0
        var b: CGFloat = 0
        var a: CGFloat = 0
        
        guard getHue(&h, saturation: &s, brightness: &b, alpha: &a) else {
            return nil
        }

        return UIColor(hue: h, saturation: s, brightness: b * 0.75, alpha: a)
    }
    
    func lighterColor() -> UIColor? {
        
        var h: CGFloat = 0
        var s: CGFloat = 0
        var b: CGFloat = 0
        var a: CGFloat = 0
        
        
        guard getHue(&h, saturation: &s, brightness: &b, alpha: &a) else {
            return nil
        }
        
        return UIColor(hue: h, saturation: s, brightness: b * 1.25, alpha: a)
    }
}

