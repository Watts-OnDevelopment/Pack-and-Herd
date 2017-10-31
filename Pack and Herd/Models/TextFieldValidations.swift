//
//  TextFieldValidations.swift
//  Pack and Herd
//
//  Created by Cameron Watson on 10/31/17.
//  Copyright © 2017 Watts-On Development. All rights reserved.
//

import Foundation

class TextFieldValidations {
    
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
    
    static public func CheckPasswordValid(passwordText : String) -> String?{
        let passwordRegEx : String = "^(?=.*[a-z])(?=.*[A-Z])(?=.*[$@$#!%*?&]).{8,}$"
        let passwordPredicate = NSPredicate(format: "SELF MATCHES %@", passwordRegEx)
        print("Validation for Password")
        print(passwordPredicate.evaluate(with: passwordText))
        
        let passwordReqs : [String] = ["^(?=.*[a-z])$", "^(?=.*[A-Z])$", "^(?=.*[$@$#!%*?&])$", "^.{8,}$"]
        
        return nil
    }
}
