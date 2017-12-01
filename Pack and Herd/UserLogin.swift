//
//  UserLogin.swift
//  Pack and Herd
//
//  Created by Cameron Watson on 11/27/17.
//  Copyright © 2017 Watts-On Development. All rights reserved.
//

import Foundation
import Firebase

class UserLogin {
    //MARK: Login Methods
    public static func LoginEmail(email : String , password: String, completion: @escaping (_ exists : Bool) -> Void){
        let emailCredential : AuthCredential = EmailAuthProvider.credential(withEmail: email, password: password)
        
        if let user = Auth.auth().currentUser{
            user.link(with: emailCredential, completion: {(user, error) in
                if let error = error {
                    print("<ERR> : \(error)")
                    return
                }
                completion(true)
            })
        }else{
            Auth.auth().signIn(with: emailCredential, completion: {(user, error) in
                if let error = error {
                    print("<ERR> : \(error)")
                    return
                }
                completion(false)
            })
            
            
        }
    }
    
    public static func LoginPhone(verificationID : String, verificationCode : String, completion: @escaping (_ exists : Bool) -> Void){
        let phoneCredential : PhoneAuthCredential = PhoneAuthProvider.provider().credential(withVerificationID: verificationID, verificationCode: verificationCode)
        
        if let user = Auth.auth().currentUser{
            user.link(with: phoneCredential, completion: {(user, error) in
                if let error = error {
                    print("<ERR> : \(error)")
                    return
                }
                completion(true)
            })
        }else{
            Auth.auth().signIn(with: phoneCredential, completion: {(user, error) in
                if let error = error {
                    print("<ERR> : \(error)")
                    return
                }
                completion(false)
            })
            

        }
    }
    
    public static func LoginGoogle(idToken : String, accessToken : String, completion : @escaping (Bool) -> Void){
        let googleCredential : AuthCredential = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: accessToken)
        Auth.auth().signIn(with: googleCredential, completion: {(user, error) in
            if let error = error {
                print("<ERR>: Failed login to Google! \(error)")
                completion(false)
            }
            
            completion(true)
        })
    }
    
    public static func Logout(sender : UIViewController) -> Bool{
        if Auth.auth().currentUser != nil {
            do{
                try Auth.auth().signOut()
            }catch AuthErrorCode.keychainError {
                print("<THW> : User logout threw keychain error")
                return false
            }catch{
                print("<THW> : User logout threw error that wasn't properly caught!")
                return false
            }
            
        }else{
            print("<ERR> : User attempted to logout without being logged in!")
            return false
        }
        return true
    }
    
    //MARK: Verification Methods
    public static func VerifyEmail(email : String, password : String, completion: @escaping (String?, String?, Int?) -> Void){
        Auth.auth().fetchProviders(forEmail: email, completion: {(ids, error) in
            if let error = error as NSError? {
                completion(nil, nil, error.code)
            }
            
            guard let ids = ids else{
                print("There are no ids for this email!")
                completion(email, password, nil)
                return
            }
            for id in ids {
                print("ID: \(id)")
                if (id == "password"){
                    // Account exists!
                    completion(email, password, nil)
                }else{
                    fatalError("ERROR: Password not found in account!")
                }
            }
        })
    }
    
    public static func VerifyPhone(phoneNumber : String, completion: @escaping (_ verifID: String?, _ verifCode : String?, _ error : Int?) -> Void){
        PhoneAuthProvider.provider().verifyPhoneNumber(phoneNumber, uiDelegate: nil, completion: {(verificationID, error) in
            if let error = error as NSError? {
                print("<ERR> : \(error)")
                completion(nil, nil, error.code)
                
            }
            
            guard let verificationID = verificationID else{
                print("<ERR> : Verification ID was corrupt!")
                return
            }
            
            print("<GEN> : Verification ID: \(verificationID)")
            
            
            let verificationCodeConfirm = UIAlertController(title: "Phone Verification", message: "For security purposes, please enter the verification code sent to your phone.", preferredStyle: UIAlertControllerStyle.alert)
            verificationCodeConfirm.addAction(UIAlertAction(title: "Confirm", style: UIAlertActionStyle.default, handler: {(alertAction) in
                if let verificationCode = verificationCodeConfirm.textFields?[0].text {
                    completion(verificationID, verificationCode, nil)
                }
            }))
            verificationCodeConfirm.addAction(UIAlertAction(title: "Resend", style: UIAlertActionStyle.default, handler: {(alertAction) in
                VerifyPhone(phoneNumber: phoneNumber, completion: completion)
            }))
            verificationCodeConfirm.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: {(alertAction) in
                
            }))
            verificationCodeConfirm.addTextField(configurationHandler: {(textField) in
                
            })
            
            UIApplication.shared.keyWindow?.rootViewController?.presentedViewController?.present(verificationCodeConfirm, animated: true, completion: {() in
                
            })
            
            
        })
    }
}
