//
//  AdminSettingsController.swift
//  Pack and Herd
//
//  Created by Cameron Watson on 11/30/17.
//  Copyright © 2017 Watts-On Development. All rights reserved.
//

import Foundation
import UIKit
import Firebase

class AdminSettingsController : UITableViewController, UITextFieldDelegate {
    
    //MARK: Properties
    private var eventCellList : [Event] = []
    private var speciesCellList : [String] = []
    private var unavailabilityDateList : [DateInterval] = []
    private var calendar = Calendar(identifier: .gregorian)
    @IBInspectable var firstSectionHeight : CGFloat = 400
    @IBInspectable var secondSectionHeight : CGFloat = 400
    @IBInspectable var thirdSectionHeight : CGFloat = 400
    
    //MARK: Inits
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Customization after view has loaded
        let saveButton = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(saveAction))
        navigationItem.setRightBarButton(saveButton, animated: true)
        
        InitialLoad()
    }
    
    //MARK: Actions
    @objc private func addSpecies(){
        print("Add Species!")
        let species = ""
        speciesCellList.append(species)
        
        tableView.beginUpdates()
        tableView.insertRows(at: [IndexPath.init(row: speciesCellList.count-1, section: 0)], with: UITableViewRowAnimation.automatic)
        tableView.endUpdates()
    }
    @objc private func addEvent(){
        print("Add Event!")
        let event : Event = Event.init("", 0, 0)
        eventCellList.append(event)
        
        tableView.beginUpdates()
        tableView.insertRows(at: [IndexPath.init(row: eventCellList.count-1, section: 1)], with: UITableViewRowAnimation.automatic)
        tableView.endUpdates()
    }
    @objc private func addUnavailability(){
        print("Add Unavailability!")
        
        var dateComponents = calendar.dateComponents([.minute, .hour, .month, .day, .year, .calendar], from: Date(timeIntervalSinceNow: 1.fromDays()))
        dateComponents.calendar = calendar
        dateComponents.setValue(0, for: .minute)
        dateComponents.setValue(0, for: .hour)
        guard let startDate = dateComponents.date else{
            return
        }
        dateComponents.setValue(24, for: .hour)
        guard let endDate = dateComponents.date else{
            return
        }
        
        print("Start date: \(startDate)")
        print("End date: \(endDate)")
        
        let unavailabileDate : DateInterval = DateInterval(start: startDate, end: endDate)
        unavailabilityDateList.append(unavailabileDate)
        
        tableView.beginUpdates()
        tableView.insertRows(at: [IndexPath.init(row: unavailabilityDateList.count-1, section: 2)], with: UITableViewRowAnimation.automatic)
        tableView.endUpdates()
    }
    @objc private func unavailabilityStartDateChange(sender: UIDatePicker){
        guard let senderParentCell = sender.superview?.superview as? UITableViewCell else{
            fatalError("<FAT>: Content view's superview is not a UITableViewCell")
        }
        guard let parentCellIndex = tableView.indexPath(for: senderParentCell) else{
            fatalError("<FAT>: Parent cell is not in current tableview")
        }
        
        let originalDateInterval : DateInterval = unavailabilityDateList[parentCellIndex.row]
        if sender.date.compare(originalDateInterval.end) == ComparisonResult.orderedDescending || sender.date.compare(originalDateInterval.end) == ComparisonResult.orderedSame{
            sender.setDate(originalDateInterval.start, animated: true)
            return
        }
        print(sender.date.compare(originalDateInterval.end) == ComparisonResult.orderedAscending)
        
        let newDateInterval : DateInterval = DateInterval(start: sender.date, end: originalDateInterval.end)
        unavailabilityDateList[parentCellIndex.row] = newDateInterval
        
        print(newDateInterval)
        
        if let endTimePicker = senderParentCell.subviews.first?.subviews[4] as? UIDatePicker {
            endTimePicker.minimumDate = Date(timeInterval: 15.fromMinutes(), since: newDateInterval.start)
            
            if let endDatePicker = senderParentCell.subviews.first?.subviews[1] as? UIDatePicker {
                endDatePicker.minimumDate = Date(timeInterval: 15.fromMinutes(), since: newDateInterval.start)
            }else{
                fatalError("<FAT>: Unable to find end time picker!")
            }
            
        }else{
            fatalError("<FAT>: Unable to find end time picker!")
        }
    }
    @objc private func unavailabilityEndDateChange(sender: UIDatePicker){
        guard let senderParentCell = sender.superview?.superview as? UITableViewCell else{
            fatalError("<FAT>: Content view's superview is not a UITableViewCell")
        }
        guard let parentCellIndex = tableView.indexPath(for: senderParentCell) else{
            fatalError("<FAT>: Parent cell is not in current tableview")
        }
        
        let originalDateInterval : DateInterval = unavailabilityDateList[parentCellIndex.row]
        if originalDateInterval.start.compare(sender.date) == ComparisonResult.orderedDescending || originalDateInterval.start.compare(sender.date) == ComparisonResult.orderedSame{
            sender.setDate(originalDateInterval.end, animated: true)
            return
        }
        
        let newDateInterval : DateInterval = DateInterval(start: originalDateInterval.start, end: sender.date)
        unavailabilityDateList[parentCellIndex.row] = newDateInterval
        
        print(newDateInterval)
        
        // Change maximums and minimums
        if let startTimePicker = senderParentCell.subviews.first?.subviews[3] as? UIDatePicker {
            startTimePicker.maximumDate = Date(timeInterval: -15.fromMinutes(), since: newDateInterval.end)
            
            if let startDatePicker = senderParentCell.subviews.first?.subviews[0] as? UIDatePicker {
                startDatePicker.maximumDate = Date(timeInterval: -15.fromMinutes(), since: newDateInterval.end)
            }else{
                fatalError("<FAT>: Unable to find end time picker!")
            }
            
        }else{
            fatalError("<FAT>: Unable to find end time picker!")
        }
    }
    @objc private func unavailabilityTimerStartChange(sender: UIDatePicker){
        print("Change start date!!")
        guard let senderParentCell = sender.superview?.superview as? UITableViewCell else{
            fatalError("<FAT>: Content view's superview is not a UITableViewCell")
        }
        guard let parentCellIndex = tableView.indexPath(for: senderParentCell) else{
            fatalError("<FAT>: Parent cell is not in current tableview")
        }
        
        let originalDateInterval : DateInterval = unavailabilityDateList[parentCellIndex.row]
        
        // AND SAMEA DESCDSFSD
        let selectedDateComponents = calendar.dateComponents([.minute, .hour], from: sender.date)
        var originalDateComponents = calendar.dateComponents([.day, .month, .year, .minute, .hour, .timeZone, .calendar], from: originalDateInterval.start)
        originalDateComponents.setValue(selectedDateComponents.minute, for: .minute)
        originalDateComponents.setValue(selectedDateComponents.hour, for: .hour)
        originalDateComponents.calendar = calendar
        originalDateComponents.timeZone = TimeZone.current
        
        guard let newDate = originalDateComponents.date else{
            fatalError("<FAT>: Date could not be created from date components!")
        }
        
        if newDate.compare(originalDateInterval.end) == ComparisonResult.orderedDescending || newDate.compare(originalDateInterval.end) == ComparisonResult.orderedSame{
            sender.setDate(originalDateInterval.start, animated: true)
            return
        }
        
        print("Dates: \(newDate) - \(originalDateInterval.end)")
        
        let newDateInterval : DateInterval = DateInterval(start: newDate, end: originalDateInterval.end)
        unavailabilityDateList[parentCellIndex.row] = newDateInterval
        
        print("Date Interval: \(newDateInterval.start) - \(newDateInterval.end)")
        
        // Change maximums and minimums
        if let endTimePicker = senderParentCell.subviews.first?.subviews[4] as? UIDatePicker {
            endTimePicker.minimumDate = Date(timeInterval: 15.fromMinutes(), since: newDateInterval.start)
            
            if let endDatePicker = senderParentCell.subviews.first?.subviews[1] as? UIDatePicker {
                endDatePicker.minimumDate = Date(timeInterval: 15.fromMinutes(), since: newDateInterval.start)
            }else{
                fatalError("<FAT>: Unable to find end time picker!")
            }
            
        }else{
            fatalError("<FAT>: Unable to find end time picker!")
        }
    }
    @objc private func unavailabilityTimerEndChange(sender: UIDatePicker){
        print("Change end date!!")
        guard let senderParentCell = sender.superview?.superview as? UITableViewCell else{
            fatalError("<FAT>: Content view's superview is not a UITableViewCell")
        }
        guard let parentCellIndex = tableView.indexPath(for: senderParentCell) else{
            fatalError("<FAT>: Parent cell is not in current tableview")
        }
        
        let originalDateInterval : DateInterval = unavailabilityDateList[parentCellIndex.row]
        
        let selectedDateComponents = calendar.dateComponents([.minute, .hour], from: sender.date)
        var originalDateComponents = calendar.dateComponents([.day, .month, .year, .minute, .timeZone, .hour, .calendar], from: originalDateInterval.end)
        originalDateComponents.setValue(selectedDateComponents.minute, for: .minute)
        originalDateComponents.setValue(selectedDateComponents.hour, for: .hour)
        originalDateComponents.calendar = calendar
        originalDateComponents.timeZone = TimeZone.current
        guard let newDate = originalDateComponents.date else{
            fatalError("<FAT>: Date could not be created from date components!")
        }
        
        if originalDateInterval.start.compare(newDate) == ComparisonResult.orderedDescending || originalDateInterval.start.compare(newDate) == ComparisonResult.orderedSame{
            sender.setDate(originalDateInterval.end, animated: true)
            return
        }
        
        let newDateInterval : DateInterval = DateInterval(start: originalDateInterval.start, end: newDate)
        unavailabilityDateList[parentCellIndex.row] = newDateInterval
        
        print("Date Interval: \(newDateInterval.start) - \(newDateInterval.end)")
        
        // Change maximums and minimums
        if let startTimePicker = senderParentCell.subviews.first?.subviews[3] as? UIDatePicker {
            startTimePicker.maximumDate = Date(timeInterval: -15.fromMinutes(), since: newDateInterval.end)
            
            if let startDatePicker = senderParentCell.subviews.first?.subviews[0] as? UIDatePicker {
                startDatePicker.maximumDate = Date(timeInterval: -15.fromMinutes(), since: newDateInterval.end)
            }else{
                fatalError("<FAT>: Unable to find end time picker!")
            }
            
        }else{
            fatalError("<FAT>: Unable to find end time picker!")
        }
    }
    @objc private func unavailabilityAllDaySwitch(sender: UISwitch){
        guard let senderParentCell = sender.superview?.superview as? UITableViewCell else{
            fatalError("<FAT>: Content view's superview is not a UITableViewCell")
        }
        guard let parentCellIndex = tableView.indexPath(for: senderParentCell) else{
            fatalError("<FAT>: Parent cell is not in current tableview")
        }
        guard let dateInterval : DateInterval = unavailabilityDateList[parentCellIndex.row] else{
            fatalError("<FAT>: Date interval not found for row")
        }
        
        if let siblings = sender.superview?.subviews {
            for timeDatePicker in siblings{
                if let timeDatePicker = timeDatePicker as? UIDatePicker{
                    if timeDatePicker.datePickerMode == .time {
                        if sender.isOn {
                            var firstDateComponents = calendar.dateComponents([.minute, .hour, .month, .day, .year, .calendar], from: dateInterval.start)
                            firstDateComponents.calendar = calendar
                            firstDateComponents.setValue(0, for: .minute)
                            firstDateComponents.setValue(0, for: .hour)
                            guard let startDate = firstDateComponents.date else{
                                return
                            }
                            var secondDateComponents = calendar.dateComponents([.minute, .hour, .month, .day, .year, .calendar], from: dateInterval.end)
                            secondDateComponents.calendar = calendar
                            secondDateComponents.setValue(0, for: .minute)
                            secondDateComponents.setValue(24, for: .hour)
                            guard let endDate = secondDateComponents.date else{
                                return
                            }
                            
                            // Change maximums and minimums
                            if let startTimePicker = senderParentCell.subviews.first?.subviews[3] as? UIDatePicker {
                                startTimePicker.maximumDate = Date(timeInterval: -15.fromMinutes(), since: endDate)
                                if let startDatePicker = senderParentCell.subviews.first?.subviews[0] as? UIDatePicker {
                                    startDatePicker.maximumDate = Date(timeInterval: -15.fromMinutes(), since: endDate)
                                }else{
                                    fatalError("<FAT>: Unable to find end time picker!")
                                }
                            }else{
                                fatalError("<FAT>: Unable to find end time picker!")
                            }
                            
                            if let endTimePicker = senderParentCell.subviews.first?.subviews[4] as? UIDatePicker {
                                endTimePicker.minimumDate = Date(timeInterval: 15.fromMinutes(), since: startDate)
                                if let endDatePicker = senderParentCell.subviews.first?.subviews[1] as? UIDatePicker {
                                    endDatePicker.minimumDate = Date(timeInterval: 15.fromMinutes(), since: startDate)
                                }else{
                                    fatalError("<FAT>: Unable to find end time picker!")
                                }
                            }else{
                                fatalError("<FAT>: Unable to find end time picker!")
                            }
                            
                            if timeDatePicker.accessibilityIdentifier == "firstTimePicker" {
                                timeDatePicker.setDate(startDate, animated: true)
                                print("TERJHAKSLENFKJADSFJKABSDLKJ \(startDate) \(timeDatePicker.date)")
                            }else{
                                print("TERJHAKSDLSADFASDFASDFSDFENFKJADSFJKABSDLKJ \(endDate)")
                                timeDatePicker.setDate(endDate, animated: true)
                            }
                            timeDatePicker.isUserInteractionEnabled = false
                            timeDatePicker.alpha = 0.5
                        }else{
                            timeDatePicker.isUserInteractionEnabled = true
                            timeDatePicker.alpha = 1
                        }
                    }
                }
            }
        }
        
    }
    @objc private func timerChange(sender : UIDatePicker){
        print("Timer Changed!!!! \(sender)")
        guard let parentCell = sender.superview?.superview as? UITableViewCell else{
            fatalError("<FAT>: Parent cell is not a table view cell!")
        }
        guard let eventCellIndex = tableView.indexPath(for: parentCell) else{
            fatalError("<FAT>: Parent cell is not a table view cell for this table view!")
        }
        let duration : Int = Int(sender.countDownDuration / 60.0)
        print("Duration: \(duration)")
        
        eventCellList[eventCellIndex.row].length = duration
    }
    @objc private func saveAction(){
        // Checks
        var errorMessage = ""
        var eventIndex = 1
        for event in eventCellList{
            if event.cost > 0 &&  event.length > 0 && !event.name.isEmpty {
                
            }else{
                errorMessage = "Event \(eventIndex) is not completed properly."
            }
            eventIndex += 1
        }
        
        var speciesIndex = 1
        for species in speciesCellList{
            if !species.isEmpty {
                
            }else{
                errorMessage = "Species \(speciesIndex) is not completed properly."
            }
            speciesIndex += 1
        }
        
        if !errorMessage.isEmpty {
            let errorAlertController = UIAlertController(title: "Saving Error", message: errorMessage, preferredStyle: .alert)
            let errorAlertCloseAction = UIAlertAction(title: "Close", style: .cancel, handler: {(alertAction) in })
            errorAlertController.addAction(errorAlertCloseAction)
            present(errorAlertController, animated: true, completion: {() in })
            
            return
        }
        
        // Save
        
        ServerData.SetEventTypes(events: eventCellList, completion: {(error) in
            print("<ERR>: \(error)")
        })
        ServerData.SetSpecies(species: speciesCellList, completion: {(error) in
            print("<ERR>: \(error)")
        })
        ServerData.SetUnavailableTimes(unavailableTimes: unavailabilityDateList, completion: {(error) in
            print("<ERR>: \(error)")
        })
    }
    
    //MARK: Methods
    private func InitialLoad(){
        ServerData.GetEventTypes(completion: {(events) in
            print("Load events! \(events)")
            var eventIndexPaths : [IndexPath] = []
            for eventArray in events {
                if let eventTable = eventArray.value as? [String:Any]{
                    if let event = eventTable.toEvent() {
                        self.eventCellList.append(event)
                        eventIndexPaths.append(IndexPath(row: eventIndexPaths.count, section: 1))
                    }else{
                        print("FAILUREEE")
                    }
                }
            }
            
            self.tableView.beginUpdates()
            self.tableView.insertRows(at: eventIndexPaths, with: .automatic)
            self.tableView.endUpdates()
        })
        
        ServerData.GetSpecies(completion: {(species) in
            var speciesIndexPaths : [IndexPath] = []
            for speciesArray in species {
                if let speciesName = speciesArray.value as? String {
                    self.speciesCellList.append(speciesName)
                    speciesIndexPaths.append(IndexPath(row: speciesIndexPaths.count, section: 0))
                }
            }
            
            self.tableView.beginUpdates()
            self.tableView.insertRows(at: speciesIndexPaths, with: .automatic)
            self.tableView.endUpdates()
        })
        
        
        ServerData.GetUnavailableTimes(completion: {(dates) in
            var timesIndexPaths : [IndexPath] = []
            for dateInterval in dates {
                if let datePeriod = dateInterval.value as? [String:Any] {
                    if let dateStart = datePeriod["start"] as? Date, let dateEnd = datePeriod["end"] as? Date{
                        let unavailableDate : DateInterval = DateInterval(start: dateStart, end: dateEnd)
                        self.unavailabilityDateList.append(unavailableDate)
                        timesIndexPaths.append(IndexPath(row: timesIndexPaths.count, section: 2))
                    }
                }
            }
            
            self.tableView.beginUpdates()
            self.tableView.insertRows(at: timesIndexPaths, with: .automatic)
            self.tableView.endUpdates()
        })
    }
    
    //MARK: TableViewController Methods
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch(section){
        case 0:
            return speciesCellList.count
        case 1:
            return eventCellList.count
        case 2:
            return unavailabilityDateList.count
        default:
            return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        var height : CGFloat = 30
        switch(indexPath.section){
        case 0:
            height = firstSectionHeight
            break
        case 1:
            height = secondSectionHeight
            break
        case 2:
            height = thirdSectionHeight
            break
        default:
            break
        }
        
        return height
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var tableViewCellID = ""
        switch(indexPath.section){
        case 0:
            tableViewCellID = "speciesCell"
            break
        case 1:
            tableViewCellID = "eventCell"
            break
        case 2:
            tableViewCellID = "unavailabilityCell"
        default:
            break
        }
        var cell : UITableViewCell = tableView.dequeueReusableCell(withIdentifier: tableViewCellID, for: indexPath)
        
        switch(indexPath.section){
        case 0: // Species Cell
            let speciesCell = speciesCellList[indexPath.row]
            
            if let speciesTextField = cell.subviews.first?.subviews.first as? UITextField {
                speciesTextField.text = speciesCell
                speciesTextField.placeholder = "Species Name"
                speciesTextField.accessibilityIdentifier = "speciesField"
                speciesTextField.delegate = self
            }
            break
        case 1: // Event Cell
            let eventCell = eventCellList[indexPath.row]

            if let eventsTitleField = cell.subviews.first?.subviews.first as? UITextField {
                eventsTitleField.text = eventCell.name
                eventsTitleField.placeholder = "Event Title"
                eventsTitleField.accessibilityIdentifier = "eventTitleField"
                eventsTitleField.delegate = self
            }
            if let eventsDurationPicker = cell.subviews.first?.subviews[1] as? UIDatePicker {
                eventsDurationPicker.addTarget(self, action: #selector(timerChange), for: UIControlEvents.valueChanged)
                let defaultCalendar = Calendar(identifier: .gregorian)
                let defaultDate = Date()
                var calendarComponents = defaultCalendar.dateComponents([.hour, .minute], from: defaultDate)
                calendarComponents.hour = 0
                calendarComponents.minute = eventCell.length
                
                eventsDurationPicker.setDate(defaultCalendar.date(from: calendarComponents)!, animated: true)
                
            }
            if let eventsDurationImage = cell.subviews.first?.subviews[2] as? UIImageView {
                eventsDurationImage.image = #imageLiteral(resourceName: "timerIcon")
            }
            if let eventsCostField = cell.subviews.first?.subviews[3] as? UITextField {
                let textRounded = String(format: "%.2f", eventCell.cost)
                eventsCostField.text = "$"+textRounded
                
                eventsCostField.placeholder = "Event Cost"
                eventsCostField.accessibilityIdentifier = "costField"
                eventsCostField.delegate = self
            }
            if let eventsCostImage = cell.subviews.first?.subviews[4] as? UIImageView {
                eventsCostImage.image = #imageLiteral(resourceName: "costIcon")
            }
            break
        case 2:
            if let startDatePicker = cell.subviews.first?.subviews.first as? UIDatePicker {
                let dateInterval : DateInterval = unavailabilityDateList[indexPath.row]
                print("Dates: \(dateInterval.start) \(dateInterval.end)")
                
                startDatePicker.minimumDate = dateInterval.start
                startDatePicker.setDate(dateInterval.start, animated: true)
                startDatePicker.timeZone = TimeZone.current
                print(startDatePicker.date)
                startDatePicker.addTarget(self, action: #selector(unavailabilityStartDateChange), for: .valueChanged)
                
                if let endDatePicker = cell.subviews.first?.subviews[1] as? UIDatePicker {
                    startDatePicker.maximumDate = endDatePicker.date
                    endDatePicker.timeZone = TimeZone.current
                    endDatePicker.minimumDate = startDatePicker.maximumDate
                    endDatePicker.setDate(dateInterval.end, animated: true)
                    endDatePicker.addTarget(self, action: #selector(unavailabilityEndDateChange), for: .valueChanged)
                }
            }
            if let dateIconView = cell.subviews.first?.subviews[2] as? UIImageView {
                dateIconView.image = #imageLiteral(resourceName: "timerIcon")
            }
            if let firstTimePicker = cell.subviews.first?.subviews[3] as? UIDatePicker {
                let dateInterval : DateInterval = unavailabilityDateList[indexPath.row]
                
                firstTimePicker.addTarget(self, action: #selector(unavailabilityTimerStartChange), for: .valueChanged)
                firstTimePicker.accessibilityIdentifier = "firstTimePicker"
                if let secondTimePicker = cell.subviews.first?.subviews[4] as? UIDatePicker{
                    firstTimePicker.setDate(dateInterval.start, animated: true)
                    secondTimePicker.setDate(dateInterval.end, animated: true)
                    secondTimePicker.minimumDate = firstTimePicker.date
                    firstTimePicker.maximumDate = secondTimePicker.date
                    secondTimePicker.addTarget(self, action: #selector(unavailabilityTimerEndChange), for: .valueChanged)
                }
            }
            if let timeIconView = cell.subviews.first?.subviews[5] as? UIImageView{
                timeIconView.image = #imageLiteral(resourceName: "timerIcon")
            }
            if let allDaySwitch = cell.subviews.first?.subviews[6] as? UISwitch{
                allDaySwitch.addTarget(self, action: #selector(unavailabilityAllDaySwitch), for: .valueChanged)
                allDaySwitch.setOn(true, animated: true)
            }
        default:
            break
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerCell = tableView.dequeueReusableCell(withIdentifier: "headerCell")
        guard let title = headerCell?.subviews.first?.subviews.first as? UILabel else {
            fatalError("ERROR: Title not found as first element!")
        }
        guard let button = headerCell?.subviews.first?.subviews.last as? UIButton else{
            fatalError("ERROR: Button not found as first element!")
        }
        
        button.alpha = 1
        
        switch(section){
        case 0: // Species Section
            title.text = "Species"
            button.addTarget(self, action: #selector(addSpecies), for: .touchUpInside)
        case 1: // Event Section
            title.text = "Events"
            button.addTarget(self, action: #selector(addEvent), for: .touchUpInside)
        case 2: // Unavailability Section
            title.text = "Unavailability"
            button.addTarget(self, action: #selector(addUnavailability), for: .touchUpInside)
        default:
            break
        }
        
        let headerView = UIView()
        headerView.addSubview(headerCell!)
        
        return headerView
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 44
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let rowAction : UITableViewRowAction = UITableViewRowAction(style: .destructive, title: "Delete", handler: {(action, cellIndexPath) in
            
            switch(cellIndexPath.section){
            case 0:
                self.speciesCellList.remove(at: cellIndexPath.row)
            case 1:
                self.eventCellList.remove(at: cellIndexPath.row)
            case 2:
                self.unavailabilityDateList.remove(at: cellIndexPath.row)
            default:
                return
            }
            
            tableView.beginUpdates()
            tableView.deleteRows(at: [cellIndexPath], with: .automatic)
            tableView.endUpdates()
        })
        
        return [rowAction]
    }
    
    //MARK: UITextField Delegate
    func textFieldDidEndEditing(_ textField: UITextField) {
        guard let parentCell = textField.superview?.superview as? UITableViewCell else{
            fatalError("<FAT>: Parent cell is not a table view cell!")
        }
        guard let text = textField.text else{
            return
        }
        let textFieldIndex = tableView.indexPath(for: parentCell)!
        
        
        if(textField.accessibilityIdentifier == "costField"){
            if let cost = Double.init(text) {
                let textRounded = String(format: "%.2f", cost)
                guard let costRounded = Double(textRounded) else {
                    textField.text = ""
                    return
                }
                eventCellList[textFieldIndex.row].cost = costRounded
                textField.text = "$\(textRounded)"
            }else{
                textField.text = ""
            }
        }else if(textField.accessibilityIdentifier == "eventTitleField"){
            eventCellList[textFieldIndex.row].name = text
        }else if(textField.accessibilityIdentifier == "speciesField"){
            speciesCellList[textFieldIndex.row] = text
            
        }
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        guard let text = textField.text else{
            return
        }
        if text.isEmpty {
            return
        }
        
        if(textField.accessibilityIdentifier == "costField"){
            let textSubstringIndex : String.Index = text.index(text.startIndex, offsetBy: 1)
            let subText : String = String(text.suffix(from: textSubstringIndex))
            textField.text = ""+subText
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
}
