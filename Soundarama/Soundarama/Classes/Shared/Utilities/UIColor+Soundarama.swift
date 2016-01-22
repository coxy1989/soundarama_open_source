//
//  UIColor+Soundarama.swift
//  Soundarama
//
//  Created by Tom Weightman on 09/12/2015.
//  Copyright © 2015 Touchpress Ltd. All rights reserved.
//

import Foundation
import UIKit

extension UIColor
{
    func darkerColor() -> UIColor?
    {
        var h: CGFloat = 0
        var s: CGFloat = 0
        var b: CGFloat = 0
        var a: CGFloat = 0
        
        if self.getHue(&h, saturation: &s, brightness: &b, alpha: &a)
        {
            return UIColor(hue: h, saturation: s, brightness: b * 0.75, alpha: a)
        }
        
        return nil
    }
    
    func lighterColor() -> UIColor?
    {
        var h: CGFloat = 0
        var s: CGFloat = 0
        var b: CGFloat = 0
        var a: CGFloat = 0
        
        if self.getHue(&h, saturation: &s, brightness: &b, alpha: &a)
        {
            return UIColor(hue: h, saturation: s, brightness: b * 1.25, alpha: a)
        }
        
        return nil
    }
}