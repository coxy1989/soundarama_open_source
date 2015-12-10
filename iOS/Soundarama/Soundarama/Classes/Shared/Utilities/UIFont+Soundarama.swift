//
//  UIFont+Soundarama.swift
//  Soundarama
//
//  Created by Tom Weightman on 09/12/2015.
//  Copyright © 2015 Touchpress Ltd. All rights reserved.
//

import Foundation
import UIKit

extension UIFont
{
    class func soundaramaSansSerifLightFont(size size: CGFloat) -> UIFont
    {
        return UIFont.customFontWithName("Avenir-Light", size: size)
    }
    
    class func soundaramaSansSerifRomanFont(size size: CGFloat) -> UIFont
    {
        return UIFont.customFontWithName("Avenir-Roman", size: size)
    }
    
    class func soundaramaSansSerifHeavyFont(size size: CGFloat) -> UIFont
    {
        return UIFont.customFontWithName("Avenir-Heavy", size: size)
    }
    
    class func soundaramaSansSerifBookFont(size size: CGFloat) -> UIFont
    {
        return UIFont.customFontWithName("Avenir-Book", size: size)
    }
    
    class func customFontWithName(name: String, size: CGFloat) -> UIFont
    {
        if let font = UIFont(name: name, size: size)
        {
            return font
        }
        #if !TARGET_INTERFACE_BUILDER
            assert(false, "Font \(name) failed to load") //IBDesignables sometimes fail to load fonts
        #endif
        return UIFont.systemFontOfSize(size)
    }
}