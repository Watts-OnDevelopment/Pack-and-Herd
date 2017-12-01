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
    @IBInspectable var firstSectionHeight : CGFloat = 400
    @IBInspectable var secondSectionHeight : CGFloat = 400
    
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
        
        // Preperation
        
        
        // Save
        ServerData.SetEventTypes(events: eventCellList, completion: {(error) in
            print("<ERR>: \(error)")
        })
        ServerData.SetSpecies(species: speciesCellList, completion: {(error) in
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
    }
    
    //MARK: TableViewController Methods
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch(section){
        case 0:
            return speciesCellList.count
        case 1:
            return eventCellList.count
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
