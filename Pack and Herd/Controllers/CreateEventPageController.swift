//
//  CreateEventPageController.swift
//  Pack and Herd
//
//  Created by Cameron Watson on 11/2/17.
//  Copyright © 2017 Watts-On Development. All rights reserved.
//

import UIKit

@IBDesignable class CreateEventPageController : UICollectionViewController, UICollectionViewDelegateFlowLayout, UIPickerViewDelegate, UIPickerViewDataSource {
    
    //MARK: Properties
    let cellIDs : [String] = ["eventsCollectionCell", "locationCollectionCell", "dateCollectionCell", "timeCollectionCell", "confirmCollectionCell"]
    var eventTypes : [Event] = []
    
    //MARK: UIViewController Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initialSetup()
    }
    
     //MARK: Methods
    private func initialSetup(){
        ServerData.GetEventTypes(completion: {(events) in
            for event in events {
                if let event = event.value as? [String : Any] {
                    if let event = event.toEvent(){
                        self.eventTypes.append(event)
                    }
                }
            }
            let eventsCell = self.collectionView?.cellForItem(at: IndexPath(row: 0, section: 0))
            if let eventsPicker = eventsCell?.contentView.subviews.last as? UIPickerView {
                eventsPicker.reloadAllComponents()
                print("RELOAD IT ALL!")
            }
        })
        
        UserData.RetrieveUserData(completion: {(data) in
            if let location = data["location"] as? String {
                let locationCell = self.collectionView?.cellForItem(at: IndexPath(row: 0, section: 1))
                if let locationField = locationCell?.contentView.subviews.last as? UITextField {
                    locationField.text = location
                }
            }
        })
    }
    
    //MARK: UICollectionViewController Methods
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        var cellID = ""
        
        if cellIDs.count <= indexPath.section {
            cellID = cellIDs[0]
        }else{
            cellID = cellIDs[indexPath.section]
        }
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellID, for: indexPath)
        // Set delegates
        for subview in cell.contentView.subviews {
            print("Subview: \(subview)")
            if let availabilityDatePicker = subview as? AvailabilityDatePicker{
                print(cellID)
                if cellID == "dateCollectionCell"{
                    print("Call the damn delegate stiff")
                    //availabilityDatePicker.dataSource = self
                    print(availabilityDatePicker.numberOfComponents(in: availabilityDatePicker) )
                    print(availabilityDatePicker.pickerView(availabilityDatePicker, attributedTitleForRow: 0, forComponent: 0) ?? "NULL")
                    print(availabilityDatePicker.pickerView(availabilityDatePicker, numberOfRowsInComponent: 0) )
                    print(availabilityDatePicker.pickerView(availabilityDatePicker, widthForComponent: 0) )
                    availabilityDatePicker.delegate = availabilityDatePicker
                    availabilityDatePicker.dataSource = availabilityDatePicker
                    
                    let day = Calendar.current.component(.day, from: availabilityDatePicker.minimumDate)
                    let month = Calendar.current.component(.month, from: availabilityDatePicker.minimumDate) - 1
                    print("Month: \(month) Day: \(day)")
                    availabilityDatePicker.selectRow(month, inComponent: 0, animated: true)
                    availabilityDatePicker.pickerView(availabilityDatePicker, didSelectRow: month, inComponent: 0)
                    availabilityDatePicker.selectRow(day, inComponent: 1, animated: true)
                    availabilityDatePicker.pickerView(availabilityDatePicker, didSelectRow: day, inComponent: 1)
                }
            }else if let subview = subview as? UIPickerView {
                print("Set picker view delegate of: \(subview)")
                if(subview.restorationIdentifier != "location"){
                    subview.delegate = self
                }else{
                    print("NOIOOOOO")
                }
            }else if let subview = subview as? UITextField {
                subview.textColor = UIColor.gray
            }
        }
        
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 1
    }
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 5
    }

    //MARK: UIPickerView Delegate
    
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 30
    }
    
    func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        var text = ""
        if eventTypes.count <= row {
            text = "Event"
        }else{
            text = eventTypes[row].name
        }
        
        let attributedText = NSAttributedString(string: text, attributes: [NSAttributedStringKey.foregroundColor:UIColor.darkGray])
        
        return attributedText
    }
    
    //MARK: UIPickerView Data Source
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return eventTypes.count
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        guard eventTypes.count > row else{
            return "Event"
        }
        
        return eventTypes[row].name
    }
    
    //MARK: UICollectionViewDelegateFlowLayout
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let defaultCellSize = CGSize(width: 414, height: 125)

        print("Collection Cell ID: \(indexPath.section)")
        if (indexPath.section == 4){
            return CGSize(width: defaultCellSize.width, height: 150)
        }
        
        return defaultCellSize
    }
    
    //MARK: Actions
    
    @IBAction func confirmButtonAction(_ sender: UIButton) {
        
    }
}
