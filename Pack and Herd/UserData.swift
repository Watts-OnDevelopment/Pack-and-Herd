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
        
         // Check if the initial user data is already set
        CheckUserdata(completionHandler: {(exists) in
            if exists {
                RetrieveUserData(completion: {(userData) in
                    if userData.count < 4 {
                        // Userdata is incomplete
                        let userDataTable : [String : Any] = {
                            var data : [String : Any] = [:]
                            let user = Auth.auth().currentUser
                            
                            data["admin"] = false
                            data["email"] = user?.email
                            data["phone"] = user?.phoneNumber
                            data["name"] = user?.displayName ?? ""
                            data["address"] = ""
                            
                            return data
                        }()
                        SetUserData(userData: userDataTable)
                    }else{
                        print("Data already created!")
                    }
                })
            }else{
                let userDataTable : [String : Any] = {
                    var data : [String : Any] = [:]
                    let user = Auth.auth().currentUser
                    
                    data["admin"] = false
                    data["email"] = user?.email
                    data["phone"] = user?.phoneNumber
                    data["name"] = user?.displayName ?? ""
                    data["address"] = ""
                    
                    return data
                }()
                SetUserData(userData: userDataTable)
            }
        })
        
        // Set initial pets
        
    }
    
    //MARK: Checker Methods
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
    
    //MARK: Setter Methods
    public static func SetUserData(userData : [String:Any]) {
        if let userUID = Auth.auth().currentUser?.uid {
            print("Set User Data: \(userData)")
            
            let changeRequest = Auth.auth().currentUser?.createProfileChangeRequest()
            changeRequest?.displayName = userData["name"] as? String
            changeRequest?.commitChanges(completion: {(error) in
                if let error = error {
                    print("<ERR> : \(error)")
                    return
                }
            })
            
            
            Firestore.firestore().collection("users").document(userUID).setData(userData, options: SetOptions.merge(), completion: {(error) in
                if let error = error {
                    print("<ERR> |\(self)| : \(error)")
                }
            })
        }else{
            fatalError("ERROR: Account update called before user was signed in!")
        }
    }
    
    public static func SetUserImage(userName : String, userImage : UIImage){
        if let userUID = Auth.auth().currentUser?.uid {
            print(userImage)
            guard let userImageData = UIImageJPEGRepresentation(userImage, 0.5) else {
                fatalError("<ERR> : Unable to convert image to data.")
            }
            let userNSName = NSString(string: userName)
            userNSName.replacingOccurrences(of: " ", with: "")
            
            let userImageFile = Storage.storage().reference().child("images.\(userUID)/\(String.init(userNSName)).jpg")
            userImageFile.putData(userImageData)
            
        }else{
            fatalError("ERROR: Account update called before user was signed in!")
        }
    }
    
    public static func SetPetsData(petsData : [SettingsViewController.PetCell]){
        if let userUID = Auth.auth().currentUser?.uid {
            for pet in petsData {
                print("ADD ONLINE PET: \(pet)")
                let petInfo : [String : Any] = ["name" : pet.name, "info" : pet.info, "species" : pet.species]
                Firestore.firestore().collection("users").document(userUID).collection("pets").document(pet.name!).setData(petInfo, completion: {(error) in
                    if let error = error {
                        print("<ERR> |\(self)| : \(error)")
                    }
                })
            }
        }else{
            fatalError("ERROR: Account update called before user was signed in!")
        }
    }
    
    public static func SetPetImage(petName : String, petImage : UIImage){
        if let userUID = Auth.auth().currentUser?.uid {
            guard let petImageData = UIImageJPEGRepresentation(petImage, 0.5) else {
                fatalError("<ERR> : Unable to convert image to data.")
            }
            let petNSName = NSString(string: petName)
            petNSName.replacingOccurrences(of: " ", with: "")
            
            let petImageFile = Storage.storage().reference().child("images.\(userUID)/\(String.init(petNSName)).jpg")
            petImageFile.putData(petImageData)
            
        }else{
            fatalError("ERROR: Account update called before user was signed in!")
        }
    }
    
    //MARK: Retrieve Methods
    public static func RetrieveUserData(completion : @escaping ([String : Any]) -> Void) {
        if let userUID = Auth.auth().currentUser?.uid {
            Firestore.firestore().collection("users").document(userUID).getDocument(completion: {(document, error) in
                if let error = error {
                    if(error.localizedDescription == "Missing or insufficient permissions."){
                        self.InitalUserdata(userUID)
                    }
                    print("ERROR: |\(self)| 2 \(error.localizedDescription)")
                    return
                }
                
                guard let document = document else{
                    fatalError("<ERR> : Document not valid.")
                }
                
                if document.exists {
                    let documentData = document.data()
                    
                    print("IS HE ADMIN??")
                    
                    if let isAdmin = documentData["admin"] as? Bool {
                        self.f_admin = isAdmin
                        print(self.f_admin)
                    }
                    
                    completion(documentData)
                }else {
                    self.InitalUserdata(userUID)
                }
            })
        }else{
            fatalError("ERROR: Account update called before user was signed in!")
        }
    }
    
    public static func RetrieveUserImage(userName : String, completion : @escaping (UIImage) -> Void){
        if let userUID = Auth.auth().currentUser?.uid {
            let userNSName = NSString(string: userName)
            userNSName.replacingOccurrences(of: " ", with: "")
            
            Storage.storage().reference().child("images.\(userUID)/\(String.init(userNSName)).jpg").getData(maxSize: 20000000, completion: {(data, error) in
                if let error = error {
                    print("<ERR> : \(error)")
                }
                
                guard let userData = data else {
                    print("<ERR> : Data found was corrupt!")
                    return
                }
                
                guard let userImage = UIImage(data: userData) else{
                    print("<ERR> : UIImage could not be generated from given data!")
                    return
                }
                
                completion(userImage)
                
            })
        }else{
            fatalError("ERROR: Account update called before user was signed in!")
        }
    }
    
    public static func RetrievePetsData(completion : @escaping ([[String : Any]]?) -> Void){
        if let userUID = Auth.auth().currentUser?.uid {
            // Cam so you have to make the parameter for the competion an array of the String : Any Dictionary, then you want to loop throiugh each document and add it to the table.
            Firestore.firestore().collection("users").document(userUID).collection("pets").getDocuments(completion: {(querySnapshot, error) in
                var petsList : [[String : Any]] = []
                
                if let error = error  {
                    if(error.localizedDescription == "Missing or insufficient permissions."){
                        self.InitalUserdata(userUID)
                    }
                    print("<ERR> |\(self)| : \(error.localizedDescription)")
                    return
                }
                
                guard let queryDocuments = querySnapshot?.documents else {
                    fatalError("<ERR> : Documents section not found!")
                }
                
                for docSnap in queryDocuments {
                    petsList.append(docSnap.data())
                }
                
                completion(petsList)
            })
        }else{
            fatalError("ERROR: Account update called before user was signed in!")
        }
    }
    
    public static func RetrievePetImage(petName : String, completion : @escaping (UIImage) -> Void){
        if let userUID = Auth.auth().currentUser?.uid {
            let petNSName = NSString(string: petName)
            petNSName.replacingOccurrences(of: " ", with: "")
            
            Storage.storage().reference().child("images.\(userUID)/\(String.init(petNSName)).jpg").getData(maxSize: 20000000, completion: {(data, error) in
                if let error = error {
                    print("<ERR> : \(error)")
                }
                
                guard let petData = data else {
                    print("<ERR> : Data found was corrupt!")
                    return
                }
                
                guard let petImage = UIImage(data: petData) else{
                    print("<ERR> : UIImage could not be generated from given data!")
                    return
                }
                
                completion(petImage)
                
            })
        }else{
            fatalError("ERROR: Account update called before user was signed in!")
        }
    }
    
    //MARK: Delete Methods
    public static func ClearPetsData(completion: @escaping () -> Void){
        if let userUID = Auth.auth().currentUser?.uid {
            Firestore.firestore().collection("users").document(userUID).collection("pets").getDocuments(completion: {(query, error) in
                if let error = error {
                    print("<ERR> : \(error)")
                }
                
                for document in query!.documents {
                    document.reference.delete()
                }
                
                completion()
            })
        }else{
            fatalError("ERROR: Account update called before user was signed in!")
        }
    }
    
    //MARK: Save Methods
    /*
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
 */
}
