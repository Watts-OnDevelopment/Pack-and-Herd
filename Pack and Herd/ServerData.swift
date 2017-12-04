//
//  ServerData.swift
//  Pack and Herd
//
//  Created by Cameron Watson on 11/30/17.
//  Copyright © 2017 Watts-On Development. All rights reserved.
//

import Foundation
import Firebase

class ServerData {
    
    //MARK: Setter Methods
    
    static func SetEventTypes(events : [Event], completion : @escaping (Error) -> Void){
        if(Auth.auth().currentUser != nil){
            let eventsArray : [[String:Any]] = {
                var eventsList : [[String:Any]] = []
                for event in events {
                    let eventDictionary : [String:Any] = event.toDictionary()
                    eventsList.append(eventDictionary)
                }
                return eventsList
            }()
            
            var eventsDictionary : [String : [String:Any]] = [:]
            for eventDictionary in eventsArray {
                let eventID : String = eventDictionary["name"] as! String
                eventsDictionary[eventID] = eventDictionary
            }
            
            Firestore.firestore().collection("server-settings").document("eventTypes").setData(eventsDictionary)
        }else{
            fatalError("<ERR> : User is not signed in!")
        }
    }
    
    static func SetSpecies(species : [String], completion : @escaping (Error) -> Void){
        if(Auth.auth().currentUser != nil){
            let speciesDictionary : [String: String] = {
                var dictionary : [String : String] = [:]
                for i in 0..<species.count {
                    dictionary["\(i)"] = species[i]
                }
                return dictionary
            }()
            Firestore.firestore().collection("server-settings").document("species").setData(speciesDictionary)
        }else{
            fatalError("<ERR> : User is not signed in!")
        }
    }
    
    static func SetUnavailableTimes(unavailableTimes : [DateInterval], completion : @escaping (Error) -> Void){
        if(Auth.auth().currentUser != nil){
            let unavailableArray : [[String:Any]] = {
                var unavailableList : [[String:Any]] = []
                for unavailableItem in unavailableTimes {
                    let unavailableDictionary : [String:Any] = unavailableItem.toDictionary()
                    unavailableList.append(unavailableDictionary)
                }
                return unavailableList
            }()
            
            var timesDictionary : [String : [String:Any]] = [:]
            for timeDictionary in unavailableArray {
                let timeID : String = String.randomString(length: 10)
                timesDictionary[timeID] = timeDictionary
            }
            Firestore.firestore().collection("server-settings").document("unavailableTimes").setData(timesDictionary)
        }else{
            fatalError("<ERR> : User is not signed in!")
        }
    }
    
    //MARK: Getter Methods
    
    /**
     Get all event types from database
     */
    static func GetEventTypes(completion : @escaping ([String:Any]) -> Void){
        if(Auth.auth().currentUser != nil){
            Firestore.firestore().collection("server-settings").document("eventTypes").getDocument(completion: {(document, error) in
                if let error = error{
                    print("<ERR> : \(error)")
                    return
                }
                
                guard let document = document else{
                    print("<ERR> : Document not found.")
                    return
                }
                
                if document.exists {
                    completion(document.data())
                }else{
                    print("Document not existant!")
                }
            })
        }else{
            fatalError("<ERR> : User is not signed in!")
        }
    }
    
    /**
     Get all species from database
     */
    static func GetSpecies(completion : @escaping ([String:Any]) -> Void){
        if(Auth.auth().currentUser != nil){
            Firestore.firestore().collection("server-settings").document("species").getDocument(completion: {(document, error) in
                if let error = error{
                    print("<ERR> : \(error)")
                    return
                }
                
                guard let document = document else{
                    print("<ERR> : Document not found.")
                    return
                }
                
                if document.exists {
                    completion(document.data())
                }else{
                    print("Document not existant!")
                }
            })
        }else{
            fatalError("<ERR> : User is not signed in!")
        }
    }
    
    static func GetUnavailableTimes(completion : @escaping ([String:Any]) -> Void){
        if(Auth.auth().currentUser != nil){
            Firestore.firestore().collection("server-settings").document("unavailableTimes").getDocument(completion: {(document, error) in
                if let error = error{
                    print("<ERR> : \(error)")
                    return
                }
                
                guard let document = document else{
                    print("<ERR> : Document not found.")
                    return
                }
                
                if document.exists {
                    completion(document.data())
                }else{
                    print("Document not existant!")
                }
            })
        }else{
            fatalError("<ERR> : User is not signed in!")
        }
    }
}
