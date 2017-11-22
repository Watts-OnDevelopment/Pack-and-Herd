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
    public static var f_admin : Bool = false
    
    //MARK: Private Static Methods
    private static func InitalUserdata(_ userUID : String){
        print("Inital User Data!")
        let userDataTable : [String : Any] = {
            var data : [String : Any] = [:]
            let user = Auth.auth().currentUser
            
            data["admin"] = false
            data["email"] = user?.email
            data["phone"] = user?.phoneNumber
            data["name"] = user?.displayName ?? ""
            data["pets"] = [] as [SettingsViewController.PetCell]
            data["address"] = ""
            
            return data
        }()
        let fireStore = Firestore.firestore()
        fireStore.collection("users").document(userUID).setData(userDataTable, completion:{(error) in
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
                    if docExists {
                        userDocumentRef = document
                    }
                    
                    completionHandler(docExists)
                    return
                }
                
                completionHandler(false)
                return
            })
        }
    }
    
    //MARK: Setter Methods
    public static func SetUserData(userData : [String:Any], completion : @escaping () -> Void) {
        if let userUID = Auth.auth().currentUser?.uid {
            Firestore.firestore().collection("users").document(userUID).setData(userData)
            
        }else{
            fatalError("ERROR: Account update called before user was signed in!")
        }
    }
    
    //MARK: Retrieve Methods
    public static func RetrieveUserData(completion : @escaping ([String : Any]) -> Void) {
        if let userUID = Auth.auth().currentUser?.uid {
            Firestore.firestore().collection("users").document(userUID).getDocument(completion: {(document, error) in
                if let error = error {
                    print("ERROR: |\(self)| \(error.localizedDescription)")
                    return
                }
                
                guard let document = document else{
                    fatalError("<ERR> : Document not valid.")
                }
                
                guard let documentData = document.data() as? [String : Any] else{
                    fatalError("<ERR> : Document data not valid.")
                }
                
                completion(documentData)
                
                
            })
        }else{
            fatalError("ERROR: Account update called before user was signed in!")
        }
    }
    
    //MARK: Save Methods
    public static func UpdateServerProfileData(profileData : [AnyHashable : Any], petsData : [SettingsViewController.PetCell]){
        // Save profile data
        if let userUID = Auth.auth().currentUser?.uid {
            print("<UPD> Sync profile info to online database!")
            
            Firestore.firestore().collection("users").document(userUID).updateData(profileData, completion: {(error) in
                if let error = error {
                    fatalError("ERROR: |\(self)| \(error.localizedDescription)")
                }
                print("<SCS> : Successfully synced online database with profile info!")
            })
            
            for pet in petsData {
                guard let petName = pet.name else{
                    fatalError("<ERR> : No name varaible is found for the pet!")
                }
                let petTable : [String : Any] = ["name" : petName, "species" : pet.species ?? 0, "pictute" : pet.picture ?? UIImage(), "info" : pet.info ?? "info"]
                Firestore.firestore().collection("users").document(userUID).collection("pets").document(petName).setData(petTable)
            }
            
        }else{
            fatalError("<ERR> : Account update called before user was signed in!")
        }
    }
    
    private static func isAdmin() -> Bool{
        print("isAdmin is being run!")
        print(UserData.userData)
        if let adminData = UserData.userData["admin"] {
            if let f_admin = adminData as? Bool{
                return f_admin
            }else {
                fatalError("ERROR: |\(self)| admin field is not a boolean!")
            }
        }else {
            fatalError("ERROR: |\(self)| admin field in User Data not found!")
        }
    }
}
