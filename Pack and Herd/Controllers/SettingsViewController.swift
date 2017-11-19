//
//  SettingsViewController.swift
//  Pack and Herd
//
//  Created by Cameron Watson on 11/13/17.
//  Copyright © 2017 Watts-On Development. All rights reserved.
//

import UIKit
import Foundation
import Firebase

class SettingsViewController: UITableViewController, UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource, UITextViewDelegate {
    //MARK: Properties
    private let cellIDs : [String : CGFloat] = ["infoCell" : 55, "petCell" : 100]
    private var cellHeights : [IndexPath : CGFloat] = [:]
    private var cellInfo : [Int : InfoCell] = [:]
    private var accountList : [Int : InfoCell] = [:]
    private var petList : [PetCell] = []
    private var petSpecies : [String] = []
    private let petDetailsPlaceholder = "Pet details."
    
    private struct InfoCell {
        var icon : UIImage?
        var text : String?
        var title : String?
    }
    
    private struct PetCell {
        var picture : UIImage?
        var name : String?
        var species : Int?
        var info : String?
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        setupCellInfo()
        setupPetInfo()
    }
    
    //MARK: Outlets
    
    //MARK: Actions
    @objc func addPetAction(){
        print("Add pet!")
        
        // Create default pet
        petList.append(PetCell(picture: #imageLiteral(resourceName: "joey"), name: "Max", species: 0, info: "Pet details..."))
        
        // Create index path for new pet
        let indexPath = IndexPath.init(row: petList.count - 1, section: 1)
        
        // Set height for new cell
        cellHeights[indexPath] = cellIDs["petCell"]
        
        tableView.beginUpdates()
        tableView.insertRows(at: [IndexPath.init(row: petList.count - 1, section: 1)], with: .automatic)
        tableView.endUpdates()
    }
    
    //MARK: Methods
    private func setupCellInfo(){
        cellInfo[0] = InfoCell(icon: #imageLiteral(resourceName: "nameIcon"), text: UserData.userData["name"] as? String, title: "Full Name")
        cellInfo[1] = InfoCell(icon: #imageLiteral(resourceName: "locationIcon"), text: UserData.userData["location"] as? String, title: "Location")
    }
    private func setupPetInfo(){
        // Pet Species
        petSpecies = ["Dog", "Cat", "Snake", "Horse"]
    }
    
    //MARK: UITableViewController Methods
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0: // Profile
            return cellInfo.count
        case 1: // Pets
            return petList.count
        case 2: // Acconts
            return accountList.count
        default:
            return 0
        }
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cellID = ""
        switch(indexPath.section){
        case 0: // Profile
            cellID = "infoCell"
        case 1: // Pets
            cellID = "petCell"
        case 2: // Accounts
            cellID = "infoCell"
        default:
            cellID = "infoCell"
            break
        }
        cellHeights[indexPath] = cellIDs[cellID]
        let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath)
        
        switch(cellID){
        case "petCell": // PET CELL
            var cellSubIndex = 0
            /*for cell in cell.contentView.subviews {
                print("\(cellSubIndex) : \(cell)")
                cellSubIndex += 1
            } */
            
            // Allow selection of cell
            cell.selectionStyle = .default
            
            guard let petDetailTextField = cell.contentView.subviews[2] as? UITextView else {
                fatalError("ERROR: Pet details text field not found")
            }
            guard let petNameTextField = cell.contentView.subviews[1] as? UITextField else {
                fatalError("ERROR: Pet name field not found")
            }
            guard let petSpeciesPicker = cell.contentView.subviews[4] as? UIPickerView else {
                print("PICKER: \(cell.contentView.subviews[4])")
                fatalError("ERROR: Pet species selector view not found")
            }
            guard let petImage = cell.contentView.subviews[0] as? UIImageView else {
                fatalError("ERROR: Pet image view not found")
            }
            
            // Customize Text Field
            petNameTextField.autocorrectionType = .yes
            petNameTextField.textContentType = UITextContentType.name
            petNameTextField.delegate = self
            
            // Customize Picker View
            petSpeciesPicker.delegate = self
            petSpeciesPicker.dataSource = self
            
            // Cuustomize Text View
            petDetailTextField.delegate = self
            petDetailTextField.textColor = UIColor.lightGray
            
            let petInfo = petList[indexPath.item]
            /*cellTextField.placeholder = info?.title
            if info?.text != "" {
                cellTextField.text = info?.text
            }
            cellImage.image = info?.icon*/
            break
        default: // INFO CELL
            guard let cellTextField = cell.contentView.subviews[0] as? UITextField else {
                fatalError("ERROR: Text field not found in the cell")
            }
            guard let cellImage = cell.contentView.subviews[1] as? UIImageView else {
                fatalError("ERROR: Cell image view not found")
            }
            
            // Customize Text Field
            cellTextField.autocorrectionType = .yes
            switch(cellInfo[indexPath.item]?.title){
            case nil:
                break
            case "Full Name"?:
                // Name
                cellTextField.textContentType = UITextContentType.name
                break
            case "Location"?:
                // Location
                cellTextField.textContentType = UITextContentType.location
                break
            default:
                break
            }
            cellTextField.delegate = self
            
            let info = cellInfo[indexPath.item]
            cellTextField.placeholder = info?.title
            if info?.text != "" {
                cellTextField.text = info?.text
            }
            cellImage.image = info?.icon
            break
        }
        
        return cell
        
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 44
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerCell = tableView.dequeueReusableCell(withIdentifier: "headerCell")
        guard let title = headerCell?.subviews.first?.subviews.first as? UILabel else {
            fatalError("ERROR: Title not found as first element!")
        }
        guard let button = headerCell?.subviews.first?.subviews.last as? UIButton else{
            fatalError("ERROR: Button not found as first element!")
        }
        
        button.alpha = 0
        
        switch(section){
        case 0:
            title.text = "Personal"
            break;
        case 1:
            title.text = "Pets"
            button.alpha = 1
            button.addTarget(self, action: #selector(addPetAction), for: UIControlEvents.touchUpInside)
            break;
        case 2:
            title.text = "Accounts"
            break;
        default:
            title.text = "Extra"
            break;
        }
        
        
        
        return headerCell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return cellHeights[indexPath]!
    }
    
    //MARK: UITextField Delegate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    //MARK: UIPickerView Delegate
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        // CAMERON! Ok so we are leaving off here, you need to first create a UILabel, customize it, and then return it!
        // You can set the content to the left here and change the color, font, and such here as well! Good luck!
        let speciesLabel = UILabel(frame: CGRect(x: 0, y: 0, width: pickerView.frame.width, height: 50))
        speciesLabel.textColor = UIColor.darkGray
        speciesLabel.contentMode = .left
        speciesLabel.text = petSpecies[row]
        speciesLabel.font = UIFont.systemFont(ofSize: 20)
        
        return speciesLabel
    }
    
    //MARK: UIPickerView Data Source
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return petSpecies.count
    }
    
    //MARK: UITextView Delegate
    func textViewDidBeginEditing(_ textView: UITextView) {
        print("CHECKKK? \(textView.textColor) \(UIColor.lightGray)")
        if (textView.textColor == UIColor.lightGray){
            // If the text is light gray, remove the text
            textView.text = nil
            textView.textColor = UIColor.darkGray
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if (textView.text.isEmpty){
            // If the text is light gray, remove the text
            textView.text = "Pet details..."
            textView.textColor = UIColor.lightGray
        }
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if (text == "\n"){
            textView.resignFirstResponder()
            return false
        }
        return true
    }
    
}
