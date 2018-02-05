//
//  NSLocale.swift
//  TouchpressFoundation
//
//  Created by Joseph Thomson on 09/03/2016.
//  Copyright © 2016 Touchpress. All rights reserved.
//

import Foundation

public extension NSLocale {
    
    /// The supported language codes in lowercase. Defaults to ["en"].
    @nonobjc static var supportedLanguages = ["en"]
    
    /// The best match from NSLocale.preferredLanguages() which is also contained in NSLocale.supportedLanguages
    static var bestSupportedLanguageForDeviceSettings: String
    {
        var hasMatchedChinese = false
        
        for language in NSLocale.preferredLanguages() {
            
            // Use language if it is supported
            if NSLocale.supportedLanguages.contains(language.lowercaseString) {
                return language
            }
            
            let languageComponents = language.componentsSeparatedByString("-")
            
            // If the user is English, prefer British English over American. (en-us users will have already been caught by the first if statement.)
            if languageComponents.first == "en" {
                if NSLocale.supportedLanguages.contains("en-gb") {
                    return "en-GB"
                }
                else if NSLocale.supportedLanguages.contains("en") {
                    return "en"
                }
            }
            
            let regionComponent = languageComponents.last ?? ""
            // Remove the locale string (e.g. the '-ca' of 'fr-ca', or the '-hk' of 'zh-hant-hk') and try again
            let languageWithoutLocale = language.stringByReplacingOccurrencesOfString("-\(regionComponent)", withString: "")
            if NSLocale.supportedLanguages.contains(languageWithoutLocale.lowercaseString) {
                return languageWithoutLocale
            }
            
            // Hong Kong uses zh-hant
            if language.lowercaseString == "zh-hk" && NSLocale.supportedLanguages.contains("zh-hant") {
                return "zh-Hant"
            }
            
            if language.lowercaseString.hasPrefix("zh") {
                // Record that this user knows Chinese, even if they don't know Simplified.
                hasMatchedChinese = true
            }
        }
        
        // If no language has been matched and the user knows 'zh-hant', default to 'zh-hans'
        if hasMatchedChinese && NSLocale.supportedLanguages.contains("zh-hans") {
            return "zh-Hans"
        }
        
        // If no language has been matched default to 'en-gb', or if that doesn't exist 'en'
        if NSLocale.supportedLanguages.contains("en-gb") {
            return "en-GB"
        }
        else if NSLocale.supportedLanguages.contains("en") {
            return "en"
        }
        
        // If no language has been found, return a supported language
        return NSLocale.supportedLanguages.first ?? "en"
    }
    
}
