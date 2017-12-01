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
    
    //MARK: Get Methods
    static func GetDayEvents(completion : ([Event]) -> Void){
        if(Auth.auth().currentUser != nil){
            GetEvents(completion: {(events) in
                for event in events{
                    
                }
            })
        }else{
            fatalError("<ERR> : User is not signed in!")
        }
    }
    
    /**
     Default method to get all events from
     */
    static func GetEvents(completion : @escaping ([Event]) -> Void){
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
                
                var events : [Event] = []
                
                for document in documents {
                    let event = ConvertToEvent(eventDictionary: document.data())
                    events.append(event)
                }
                
                completion(events)
            })
        }else{
            fatalError("<ERR> : User is not signed in!")
        }
    }
    
    //MARK: Set Methods
    
    
    //MARK: Event Conversion
    
    /**
     Converts the Event struct into a [String:Any] dictionary for online database.
     */
    static func ConvertFromEvent(event : Event) -> [String : Any]{
        let eventDictionary : [String : Any] = ["name" : event.name, "length" : event.length, "cost" : event.cost]
        return eventDictionary
    }
    
    /**
     Converts the [String:Any] dictionary from an online database back to local Event struct.
     */
    static func ConvertToEvent(eventDictionary : [String : Any]) -> Event{
        let event = Event.init(eventDictionary["name"] as! String,  eventDictionary["length"] as! Int, eventDictionary["cost"] as! Double)
        return event
    }
    
}

/**
 `name` is the publicly read title of the event
 
 `length` is the duration of the event in minutes
 
 `cost` is the total cost of the event
 */
public class Event {
    //MARK: Properties
    var name : String = ""
    var length : Int = 0
    var cost : Double = 0
    
    //MARK: Inits
    init(_ name : String, _ length : Int, _ cost : Double){
        self.name = name
        self.length = length
        self.cost = cost
    }
    
    //MARK: Methods
    public func toDictionary() -> [String:Any]{
        let eventDictionary : [String : Any] = ["name" : self.name, "length" : self.length, "cost" : self.cost]
        return eventDictionary
    }
    
}

/**
 `userID` is the user id for the user
 
 `eventID` is the reference identifing number used as the document title
 */
public class ScheduledEvent {
    //MARK: Properties
    var userID : String = ""
    var eventID : String = ""
    var location : String = ""
    var paid : Bool = false
    var startDate : Date = Date()
    var endDate : Date = Date()
    
    //MARK: Inits
    init(_ uid : String, _ eventIdentifier : String, _ loc : String, _ cashPay : Bool, _ startTime : Date, _ endTime : Date){
        userID = uid
        eventID = eventIdentifier
        location = loc
        paid = cashPay
        startDate = startTime
        endDate = endTime
    }
    
    //MARK: Methods
    public func toDictionary() -> [String:Any]{
        let eventDictionary : [String : Any] = ["userID" : self.userID, "eventID" : self.eventID, "location" : self.location, "paid" : self.paid, "startDate" : self.startDate, "endDate" : self.endDate]
        return eventDictionary
    }
}

extension Dictionary where Key == String, Value == Any{
    public func toEvent() -> Event?{
        if let name = self["name"] as? String, let length = self["length"] as? Int, let cost : Double =  self["cost"] as? Double{
            return Event.init(name, length, cost)
        }else{
            print(self["name"] as? String)
            print(self["length"] as? Int)
            print(self["cost"] as? Float)
            print(self["cost"] as? Double)
            return nil
        }
    }
    
    public func toScheduledEvent() -> ScheduledEvent?{
        if let userID = self["userID"] as? String, let eventID = self["eventID"] as? String, let location = self["location"] as? String, let paid = self["paid"] as? Bool, let startDate = self["startDate"] as? Date, let endDate = self["endDate"] as? Date{
            return ScheduledEvent.init(userID, eventID, location, paid, startDate, endDate)
        }else{
            return nil
        }
    }
}
