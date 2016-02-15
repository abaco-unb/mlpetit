//
//  CountryUtils.swift
//  mplango
//
//  Created by Bruno on 13/02/16.
//  Copyright © 2016 unb.br. All rights reserved.
//

import Foundation

class CountryUtils {
    
    struct Locale {
        let countryCode: String
        let countryName: String
    }
    
    func getList(localeIdentifier: String) -> Array<String>{
        
        var list: Array<String> = []
        let locale : NSLocale = NSLocale.init(localeIdentifier : localeIdentifier)
        
        for localeCode in NSLocale.ISOCountryCodes() {
            let countryName = locale.displayNameForKey(NSLocaleCountryCode, value: localeCode)!
            let countryCode = localeCode
            let locale = Locale(countryCode: countryCode, countryName: countryName)
            list.append(locale.countryName);
        }
        return list
        
    }
}