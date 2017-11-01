//
//  TextFieldValidations.swift
//  Pack and Herd
//
//  Created by Cameron Watson on 10/31/17.
//  Copyright © 2017 Watts-On Development. All rights reserved.
//

import Foundation

class TextFieldValidations {
    // Properties
    public enum SecurityLevels {
        case invalid
        case weak
        case strong
    }
    
    
    //MARK: Methods
    static public func CheckEmailValid(emailText : String) -> String?{
        let trimmedEmailText = emailText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard let dataChecker = try? NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue) else{
            return nil
        }
        print("Email: \(trimmedEmailText)")
        let matchRange = NSMakeRange(0, trimmedEmailText.characters.count)
        print(matchRange)
        
        let allMatches = dataChecker.matches(in: trimmedEmailText, options: [], range: matchRange)
        print(allMatches)
        print(allMatches.first?.url ?? "NIL")
        print(allMatches.first?.url?.absoluteString ?? "NIL")
        
        if(allMatches.count == 1 && allMatches.first?.url?.absoluteString.contains("mailto:") == true){
            return trimmedEmailText
        }else{
            return nil
        }
    }
    
    static public func CheckPasswordStrength(passwordText : String) -> SecurityLevels?{
        let weakPasswordRequirement = "^(?=.*[a-z]).{8,}$" // Medium
        //let strongPasswordRequirement = "^.*[a-z].*[A-Z].*[$@$#!%*?&].{8,}$" // Strong
        let strongPasswordRequirement = "^(?=.*[a-z])(?=.*[0-9])(?=.*[A-Z]).{8,}$" // Strong
        
        let weakPasswordChecker = NSPredicate(format: "SELF MATCHES %@", weakPasswordRequirement)
        let strongPasswordChecker = NSPredicate(format: "SELF MATCHES %@", strongPasswordRequirement)
        if (strongPasswordChecker.evaluate(with: passwordText)){
            // Password is strong
            return SecurityLevels.strong
        }else if (weakPasswordChecker.evaluate(with: passwordText)){
            // Password is weak
            return SecurityLevels.weak
        }else{
            // Password is invalid
            return SecurityLevels.invalid
        }
    }
}
