//
//  UIImage.swift
//  TouchpressFoundation
//
//  Created by Joseph Thomson on 09/03/2016.
//  Copyright © 2016 Touchpress. All rights reserved.
//

import UIKit

public extension UIImage {
    
    /**
     Creates an image localized using NSLocale.supportedLanguages
     
     - Parameters:
     - imageName: The unlocalized name of the image. (e.g. if the image is named 'MyImage-en', pass in 'MyImage')
     
     - Returns: A localized image if it exists, otherwise nil
     }
     */
    convenience init?(localizedNamed imageName: String) {
        
        let language = NSLocale.bestSupportedLanguageForDeviceSettings
        if UIImage(named: UIImage.imageName(imageName, withLanguage: language)) != nil
        {
            // Use the best supported language for user if there is a matching image
            self.init(named: UIImage.imageName(imageName, withLanguage: language))
        }
        else if let language = NSLocale.supportedLanguages.first where UIImage(named: UIImage.imageName(imageName, withLanguage: language)) != nil
        {
            // Use the first supported language if it has a matching image
            self.init(named: UIImage.imageName(imageName, withLanguage: language))
        }
        else
        {
            // Return nil if there is still no match
            return nil
        }
    }
    
    private static func imageName(imageName: String, withLanguage language: String) -> String {
        return "\(imageName)-\(language)"
    }
}
