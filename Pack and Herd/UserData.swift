//
//  UserData.swift
//  Pack and Herd
//
//  Created by Cameron Watson on 11/13/17.
//  Copyright © 2017 Watts-On Development. All rights reserved.
//

import Foundation
import Firebase

class UserData {
    //MARK: Properties
    public static var userData : [String : Any] = [:]
    
    //MARK: Private Static Methods
    private static func InitalUserdata(_ userUID : String){
        print("Inital User Data!")
        let userDataTable : [String : Any] = {
            var data : [String : Any] = [:]
            let user = Auth.auth().currentUser
            print("Start Auth Details:")
            print(user?.displayName ?? "NO NAME")
            print(user?.email ?? "NO EMAIL")
            print(user?.phoneNumber ?? "NO PHONE")
            print("End Auth Details")
            
            for (key, value) in userData{
                print("Key: \(key), Value: \(value)")
            }
            
            return data
        }()
        let fireStore = Firestore.firestore()
        fireStore.collection("users").document(userUID).setData([
            "TEST" : "TSET",
            "admin" : false
            ], completion:{(error) in
                if let error = error {
                    print("FIRESTORE ERROR: \(error.localizedDescription)")
                }
                
                UpdateLocalUserdata()
        })
    }
    
    //MARK: Static Methods
    public static func CheckUserdata(completionHandler: @escaping (Bool) -> Void){
        if let userUID = Auth.auth().currentUser?.uid {
            Firestore.firestore().collection("users").document(userUID).getDocument(completion: {(document, error) in
                if let error = error {
                    print("ERROR: |\(self)| \(error.localizedDescription)")
                    return
                }
                
                if let docExists = document?.exists {
                    completionHandler(docExists)
                    return
                }
                
                completionHandler(false)
                return
            })
        }
    }
    
    public static func UpdateLocalUserdata(){
        if let userUID = Auth.auth().currentUser?.uid {
            Firestore.firestore().collection("users").document(userUID).getDocument(completion: {(document, error) in
                if let error = error {
                    print("ERROR: |\(self)| \(error.localizedDescription)")
                    return
                }
                
                CheckUserdata(completionHandler: {(found) in
                    print("COMPLETION HANDLER RUNNING!!!")
                    if (found) {
                        print("User Database found!")
                        guard let uData = document?.data() else {
                            print("ERROR: |\(self)| Unable to read data of the user document!")
                            return
                        }
                        userData = uData
                    }else{
                        print("User Database not existant!")
                        InitalUserdata(userUID)
                    }
                })
            })
        }else{
            fatalError("ERROR: Account update called before user was signed in!")
        }
    }
}
