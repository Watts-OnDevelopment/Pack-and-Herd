//
//  AvailabilityDatePicker.swift
//  Pack and Herd
//
//  Created by Cameron Watson on 12/2/17.
//  Copyright © 2017 Watts-On Development. All rights reserved.
//

import UIKit
import Firebase

class AvailabilityDatePicker: UIPickerView, UIPickerViewDelegate, UIPickerViewDataSource {
    //MARK: Properties
    private var unavailableTimes : [DateInterval] = []
    private var currentYearDisabledRows : [IndexPath : Bool] = [:]
    private var nextYearDisabledRows : [IndexPath : Bool] = [:]
    public var minimumDate : Date = Date(timeIntervalSinceNow: 0)
    @IBInspectable private let date : Bool = true
    
    //MARK: Inits
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        loadUnavailableTimes()
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    //MARK: Methods
    private func loadUnavailableTimes(){
        getEventTimes(completion: {(dateIntervals) in
            for dateInterval in dateIntervals {
                self.unavailableTimes.append(dateInterval)
            }
            
            self.getUnavailableTimes(completion: {(dateIntervals) in
                for dateInterval in dateIntervals {
                    self.unavailableTimes.append(dateInterval)
                }
                
                self.setDisabledRows()
                print("Current year disabled rows \(self.currentYearDisabledRows)")
                print("Next year disabled rows \(self.nextYearDisabledRows)")
                print("Recall components! \(self.unavailableTimes)")
                self.reloadAllComponents()
            })
        })
    }
    
    private func setDisabledRows(){
        var dateComponents : DateComponents = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: Date(timeIntervalSinceNow: 0))
        dateComponents.calendar = Calendar.current
        dateComponents.timeZone = Calendar.current.timeZone
        
        let currentYear = dateComponents.year!
        
        for i in 1...12 {
            dateComponents.month = i
            dateComponents.year = currentYear
            
            guard let date = dateComponents.date else{
                print("<ERR>: Unable to make date with year")
                return
            }
            
            for d in 1...Calendar.current.range(of: .day, in: .month, for: date)!.count{
                let indexPath = IndexPath(item: d, section: i)
                dateComponents.day = d
                if let newDate = dateComponents.date {
                    for unavailableTime in unavailableTimes {
                        print("Check time: Unavailable Time = \(unavailableTime) Date = \(newDate)")
                        if unavailableTime.contains(newDate){
                            currentYearDisabledRows[indexPath] = true
                        }else{
                            //currentYearDisabledRows[indexPath] = false
                        }
                    }
                }
            }
            
            // Next year
            dateComponents.year = currentYear + 1
            
            guard let futDate = dateComponents.date else{
                print("<ERR>: Unable to make date with year")
                return
            }
            
            for d in 1...Calendar.current.range(of: .day, in: .year, for: futDate)!.count{
                let indexPath = IndexPath(item: d, section: i)
                dateComponents.day = d
                if let futureDate = dateComponents.date {
                    for unavailableTime in unavailableTimes {
                        if unavailableTime.contains(futureDate){
                            nextYearDisabledRows[indexPath] = true
                        }else{
                            //nextYearDisabledRows[indexPath] = false
                        }
                    }
                }
            }
        }
    }
    
    //MARK: PickerViewDataSource Methods
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        if date {
            return 3
        }else{
            return 2
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if date {
            switch(component){
            case 0: // Month
                return 12
            case 1: // Day
                var currentDateComponents = Calendar.current.dateComponents([.year, .calendar], from: Date(timeIntervalSinceNow: 0))
                currentDateComponents.setValue(pickerView.selectedRow(inComponent: 0) + 1, for: .month)
                
                if pickerView.numberOfComponents == 3 {
                    currentDateComponents.setValue(pickerView.selectedRow(inComponent: 2) + currentDateComponents.year!, for: .year)
                }
                
                guard let currentDate = currentDateComponents.date else{
                    fatalError("<ERR>: Unable to create date from components")
                }
               
                let days = Calendar.current.range(of: .day, in: .month, for: currentDate)!.count
                return days
            case 2: // Year
                return 2
            default:
                return 0
            }
        }else{
            switch(component){
                case 0: // Hour
                return 24
                case 1: // Minute
                return 4
                default:
                return 0
            }
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, widthForComponent component: Int) -> CGFloat {
        switch component {
        case 0:
            return 150
        case 1:
            return 50
        case 2:
            return 150
        default:
            return 0
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 30
    }
    
    func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        var text : String = ""
        
        switch(component){
        case 0: // Month
            text = Calendar.current.monthSymbols[row]
        case 1: // Day
            text = String(row+1)
        case 2: // Year
            let year = Calendar.current.component(.year, from: Date(timeIntervalSinceNow: 0))
            text = String(year + row)
        default:
            break;
        }
        
        var coloredTitle = NSAttributedString(string: text, attributes: [NSAttributedStringKey.foregroundColor : UIColor.darkGray])
        
        if component == 1 { // Day
            let year = pickerView.selectedRow(inComponent: 2)
            let month = pickerView.selectedRow(inComponent: 0)+1
            
            print("Year: \(year) Month: \(month) Day: \(row+1)")
            
            if year == 0 {
                if let disabledRow = currentYearDisabledRows[IndexPath(row: row+1, section: month)]{
                    print("DISSABLEEEEEED")
                    if disabledRow {
                        coloredTitle = NSAttributedString(string: text, attributes: [NSAttributedStringKey.foregroundColor : UIColor.red])
                    }
                }
            }else{
                if let disabledRow = nextYearDisabledRows[IndexPath(row: row+1, section: month)]{
                    if disabledRow {
                        coloredTitle = NSAttributedString(string: text, attributes: [NSAttributedStringKey.foregroundColor : UIColor.blue])
                    }
                }
            }
        }
        
        return coloredTitle
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if component == 1 { // Day
            let year = pickerView.selectedRow(inComponent: 2)
            let month = pickerView.selectedRow(inComponent: 0)+1
            
            print("Year: \(year) Month: \(month) Day: \(row+1)")
            
            if year == 0 {
                if let disabledRow = currentYearDisabledRows[IndexPath(row: row+1, section: month)]{
                    if disabledRow {
                        let dateComponents = Calendar.current.dateComponents([.month, .day], from: minimumDate)
                        pickerView.selectRow(dateComponents.month!, inComponent: 0, animated: true)
                        self.pickerView(pickerView, didSelectRow: dateComponents.month!, inComponent: 0)
                        pickerView.selectRow(dateComponents.day!, inComponent: 1, animated: true)
                        self.pickerView(pickerView, didSelectRow: dateComponents.day!, inComponent: 0)
                    }
                }
            }else{
                if let disabledRow = nextYearDisabledRows[IndexPath(row: row+1, section: month)]{
                    if disabledRow {
                        let dateComponents = Calendar.current.dateComponents([.month, .day], from: minimumDate)
                        pickerView.selectRow(dateComponents.month!, inComponent: 0, animated: true)
                        self.pickerView(pickerView, didSelectRow: dateComponents.month!, inComponent: 0)
                        pickerView.selectRow(dateComponents.day!, inComponent: 1, animated: true)
                        self.pickerView(pickerView, didSelectRow: dateComponents.day!, inComponent: 0)
                    }
                }
            }
        }else
        {
            print("Relaod Component")
            pickerView.reloadComponent(1)
        }
        
        var selectedDateComponents : DateComponents = Calendar.current.dateComponents([.day, .month, .year, .hour, .minute, .calendar], from: Date(timeIntervalSinceNow: 0))
        selectedDateComponents.calendar = Calendar.current
        selectedDateComponents.day = pickerView.selectedRow(inComponent: 1) + 1
        selectedDateComponents.month = pickerView.selectedRow(inComponent: 0) + 1
        selectedDateComponents.year = (pickerView.selectedRow(inComponent: 2) + selectedDateComponents.year!)
        
        guard let selectedDate = selectedDateComponents.date else{
            print("<ERR>: Unable to create date from components!")
            return
        }
        
        self.minimumDate = Date(timeIntervalSinceNow: 2.fromDays())
        //print("Dates: min \(minimumDate) current \(selectedDate)")
        //print("Comparison: \(selectedDate.compare(minimumDate) == .orderedAscending)")
        if selectedDate.compare(minimumDate) == .orderedAscending {
            pickerView.selectRow(0, inComponent: 2, animated: true)
            self.pickerView(pickerView, didSelectRow: 0, inComponent: 0)
            pickerView.selectRow(Calendar.current.component(.month, from: minimumDate) - 1, inComponent: 0, animated: true)
            self.pickerView(pickerView, didSelectRow: Calendar.current.component(.month, from: minimumDate) - 1, inComponent: 0)
            pickerView.selectRow(Calendar.current.component(.day, from: minimumDate) - 1, inComponent: 1, animated: true)
            self.pickerView(pickerView, didSelectRow: Calendar.current.component(.day, from: minimumDate) - 1, inComponent: 0)
            
        }
        
    }
    
    //MARK: PickerViewDelegate Methods
    
    //MARK: Firestore Methods
    private func getEventTimes(completion: @escaping ([DateInterval]) -> Void){
        Firestore.firestore().collection("times").getDocuments(completion: {(snapshot, error) in
            if let error = error {
                print("<ERR>: \(error)")
            }
            
            guard let documents = snapshot?.documents else{
                print("<ERR>: Documents could not be retrieved from times snapshot")
                return
            }
            
            var eventDateIntervals : [DateInterval] = []
            for document in documents {
                if document.exists {
                    let documentData = document.data()
                    print("Document Data: \(document.data())")
                    if let startDate = documentData["start"] as? Date, let endDate = documentData["start"] as? Date{
                        let dateInterval = DateInterval(start: startDate, end: endDate)
                        eventDateIntervals.append(dateInterval)
                    }else{
                        //print("<ERR>: Unable to convert start and end values to dates")
                    }
                }
            }
            
            completion(eventDateIntervals)
        })
    }
    
    private func getUnavailableTimes(completion: @escaping ([DateInterval]) -> Void){
        ServerData.GetUnavailableTimes(completion: {(timeLists) in
            var dateIntervals : [DateInterval] = []
            for timeList in timeLists {
                if let intervalDictionary = timeList.value as? [String:Any] {
                    if let startDate = intervalDictionary["start"] as? Date, let endDate = intervalDictionary["end"] as? Date{
                        let dateInterval = DateInterval(start: startDate, end: endDate)
                        dateIntervals.append(dateInterval)
                    }else{
                        //print("<ERR>: Unable to convert start and end values to dates")
                    }
                }
            }
            
            completion(dateIntervals)
        })
    }
    
}
