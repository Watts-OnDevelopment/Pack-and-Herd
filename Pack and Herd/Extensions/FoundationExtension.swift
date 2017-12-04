//
//  NumberExtension.swift
//  Pack and Herd
//
//  Created by Cameron Watson on 12/3/17.
//  Copyright © 2017 Watts-On Development. All rights reserved.
//

import Foundation

extension String{
    /**
     Generates a random string comprising of lowercase characters, uppercase characters, and integers.
     
     `length` specifies the length of the returned random String
     */
    static func randomString(length : Int) -> String{
        let possibleChars : String = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ123456789"
        let possibleCharsCount : UInt32 = UInt32(possibleChars.count)
        var randString : String = ""
        
        for _ in 0..<length {
            let random = Int(arc4random_uniform(possibleCharsCount))
            let randomIndex = possibleChars.index(possibleChars.startIndex, offsetBy: random)
            randString += String(possibleChars[randomIndex])
        }
        
        return randString
    }
}

extension Double{
    func toMinutes() -> Double{
        return self/60
    }
    func toHours() -> Double{
        return self/3600
    }
    func toDays() -> Double{
        return self/86400
    }
    func toWeeks() -> Double{
        return self/604800
    }
    
    func fromMinutes() -> Double{
        return self * 60
    }
    func fromHours() -> Double{
        return self * 3600
    }
    func fromDays() -> Double{
        return self * 86400
    }
    func fromWeeks() -> Double{
        return self * 604800
    }
}
