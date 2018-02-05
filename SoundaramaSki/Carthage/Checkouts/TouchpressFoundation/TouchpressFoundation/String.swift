//
//  String.swift
//  TouchpressFoundation
//
//  Created by Joseph Thomson on 09/03/2016.
//  Copyright © 2016 Touchpress. All rights reserved.
//

import Foundation

public extension String {
    
    private static var cachedStringsDictionaries: [String: String]?
    
    /// Returns a 
    /**
     Returns a localized string from the key using NSLocale.supportedLanguages
     
     - Returns: A localized string if it exists, otherwise the key itself
     }
     */
    var localizedString: String
    {
        if let cachedStringsDictionary = String.cachedStringsDictionaries, localizedString = cachedStringsDictionary[self]
        {
            // Use the cache if it exists and has a matching string
            return localizedString
        }
        else if let localizedString = localizedStringForLanguage(NSLocale.bestSupportedLanguageForDeviceSettings)
        {
            // Use the best supported language for user if it exists and has a matching string
            return localizedString
        }
        else if let localizedString = localizedStringForLanguage(NSLocale.supportedLanguages.first)
        {
            // Use the first supported language if it exists and has a matching string
            return localizedString
        }
        
        // Return the key if there is still no match
        return self
    }
    
    private func localizedStringForLanguage(language: String?) -> String?
    {
        if let language = language,
         stringsFileURL = NSBundle.mainBundle().URLForResource("Localizable", withExtension: "strings", subdirectory: nil, localization: language),
  stringsFileDictionary = NSDictionary(contentsOfURL: stringsFileURL) as? [String: String]
        {
            if String.cachedStringsDictionaries == nil
            {
                String.cachedStringsDictionaries = stringsFileDictionary
            }
            return stringsFileDictionary[self]
        }
        return nil
    }
    
}
