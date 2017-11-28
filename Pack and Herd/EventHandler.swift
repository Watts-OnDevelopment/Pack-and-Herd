//
//  EventHandler.swift
//  Pack and Herd
//
//  Created by Cameron Watson on 11/28/17.
//  Copyright © 2017 Watts-On Development. All rights reserved.
//

import Foundation
import Firebase

public class EventHandler {
    
    //MARK: Structs
    
    /**
     `name` is the publicly read title of the event
     
     `length` is the duration of the event in minutes
     
     `cost` is the total cost of the event
     
     `uniqueCosts` is a dictionary of unique prices per person uid
     */
    public struct Event{
        var name : String = ""
        var length : Int = 0
        var cost : Decimal = 0
        var uniqueCosts : [String : Decimal] = [:]
    }
    
    //MARK: Get Methods
    static func GetDayEvents(completion : ([Event]) -> Void){
        if(Auth.auth().currentUser != nil){
            Firestore.firestore().collection("events").getDocuments(completion: {(query, error) in
                if let error = error{
                    print("<ERR> : \(error)")
                    return
                }
                guard let documents = query?.documents else{
                    print("<ERR> : Failed to retrieve stored documents in the events collection")
                    return
                }
                
                var eventsTable : [Event] = []
                
                for document in documents {
                    
                }
                
            })
        }else{
            fatalError("<ERR> : User is not signed in!")
        }
    }
    
    // HEY! So just a recap. You are setting up methods to get all events and then return them in a table for use, use a closure to return the table of events and put the closure call in the closure of GetEvents
    
    /**
     Default method to get all events from
     */
    static func GetEvents(){
        
    }
    
    //MARK: Set Methods
    
    //MARK: Event Conversion
    
    /**
     Converts the Event struct into a [String:Any] dictionary for online database.
     */
    static func ConvertFromEvent(event : Event) -> [String : Any]{
        let eventDictionary : [String : Any] = ["name" : event.name, "length" : event.length, "cost" : event.cost, "uniqueCosts" : event.uniqueCosts]
        return eventDictionary
    }
    
    /**
     Converts the [String:Any] dictionary from an online database back to local Event struct.
     */
    static func ConvertToEvent(eventDictionary : [String : Any]) -> Event{
        let event = Event(name: eventDictionary["name"] as! String, length: eventDictionary["length"] as! Int, cost: eventDictionary["cost"] as! Decimal, uniqueCosts: eventDictionary["uniqueCosts"] as! [String : Decimal])
        return event
    }
    
}
