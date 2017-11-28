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

class SettingsViewController: UITableViewController, UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource, UITextViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    //MARK: Inits
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        // Call methods
        setupPetInfo()
        setupInitialData()
    }
    
    //MARK: Properties
    private let cellIDs : [String : CGFloat] = ["infoCell" : 55, "petCell" : 100]
    private var cellHeights : [IndexPath : CGFloat] = [:]
    private var petSpecies : [String] = []
    private let petDetailsPlaceholder = "Pet details."
    private var petImageSelectedLast : UIImageView?
    private var petList : [PetCell] = []
    private var profileList : [InfoCell] = []
    private var accountList : [InfoCell] = []
    
    private struct InfoCell {
        var icon : UIImage?
        var text : String?
        var title : String?
        var index : String?
    }
    
    public struct PetCell {
        var picture : UIImage?
        var name : String?
        var species : Int?
        var info : String?
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(saveProfilePage))
        self.navigationItem.rightBarButtonItem?.tintColor = UIColor.white
    }
    
    //MARK: Actions
    @objc func addPetAction(){
        print("Add pet!")
        
        // Create default pet
        petList.append(PetCell(picture: #imageLiteral(resourceName: "joey"), name: "", species: 0, info: "Pet details..."))
        
        // Create index path for new pet
        let indexPath = IndexPath.init(row: petList.count - 1, section: 1)
        
        // Set height for new cell
        cellHeights[indexPath] = cellIDs["petCell"]
        
        tableView.beginUpdates()
        tableView.insertRows(at: [indexPath], with: .automatic)
        tableView.endUpdates()
    }
    
    @objc func petImageSelect(sender : UIGestureRecognizer){
        petImageSelectedLast = sender.view as? UIImageView
        let imageSelector = UIImagePickerController()
        imageSelector.delegate = self
        imageSelector.sourceType = .photoLibrary
        
        present(imageSelector, animated: true, completion: {() in
            print("Image selected")
        })
    }
    
    @objc func saveProfilePage(){
        print("Save profile page!")
        
        // Set data field pet list to local petlist
        //dataFields["pets"] = petList
        
        UserData.ClearPetsData() {
            print("Pets Data Cleared!")
            UserData.SetPetsData(petsData: self.petList)
        }
        
        for pet in petList {
            UserData.SetPetImage(petName: pet.name ?? "ERROR", petImage: pet.picture ?? UIImage())
        }
        
        var profileInfo : [String : Any] = [:]
        for info in profileList {
            print("Info Cell: \(info)")
            if let infoText = info.text {
                profileInfo[info.index!] = infoText
            }else{
                profileInfo[info.index!] = ""
            }
        }
        
        for accountInfo in accountList {
            if let infoText = accountInfo.text {
                profileInfo[accountInfo.index!] = infoText
            }else{
                profileInfo[accountInfo.index!] = ""
            }
        }
        
        UserData.SetUserData(userData: profileInfo)
    }
    
    //MARK: Methods
    private func setupPetInfo(){
        // Pet Species
        petSpecies = ["Dog", "Cat", "Snake", "Horse"]
    }
    
    private func setupInitialData(){
        UserData.RetrieveUserData(completion: {(data) in
            // Setup User Data
            self.profileList.append(InfoCell(icon: #imageLiteral(resourceName: "nameIcon"), text: data["name"] as? String, title: "Full Name", index: "name"))
            self.profileList.append(InfoCell(icon: #imageLiteral(resourceName: "locationIcon"), text: data["location"] as? String, title: "Location", index: "location"))
            
            var cellIndexes : [IndexPath] = []
            
            for i in 0..<self.profileList.count {
                cellIndexes.append(IndexPath(row: i, section: 0))
            }
            
            self.tableView.beginUpdates()
            self.tableView.insertRows(at: cellIndexes, with: .automatic)
            self.tableView.endUpdates()
            
            // Setup Accounts Data
            /*self.accountList.append(InfoCell(icon: #imageLiteral(resourceName: "nameIcon"), text: data["email"] as? String, title: "Email", index: "email"))
            //self.accountList.append(InfoCell(icon: #imageLiteral(resourceName: "nameIcon"), text: data["password"] as? String, title: "Password", index: "password"))
            self.accountList.append(InfoCell(icon: #imageLiteral(resourceName: "nameIcon"), text: data["phone"] as? String, title: "Phone Number", index: "phone"))
            
            var accountIndexPaths : [IndexPath] = []
            
            for i in 0..<self.accountList.count {
                accountIndexPaths.append(IndexPath(row: i, section: 2))
            }
            
            self.tableView.beginUpdates()
            self.tableView.insertRows(at: accountIndexPaths, with: .automatic)
            self.tableView.endUpdates()*/
        })
        
        UserData.RetrievePetsData(completion: {(data) in
            // Setup Pet Data
            for pet in data! {
                UserData.RetrievePetImage(petName: pet["name"] as! String, completion: {(petImage) in
                    print("Get Pet: \(pet["name"]!)")
                    let petData = PetCell(picture: petImage, name: pet["name"]! as? String, species: pet["species"]! as? Int, info: pet["info"]! as? String)
                    self.petList.append(petData)
                    
                    print("PET DATA: \(petData.name)")
                    
                    let cellIndexPath = IndexPath(row: self.petList.count - 1, section: 1)
                    
                    self.tableView.beginUpdates()
                    self.tableView.insertRows(at: [cellIndexPath], with: .automatic)
                    self.tableView.endUpdates()
                    
                })
            }
        })
    }
    
    //MARK: UITableViewController Methods
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        // Row Actions for cells
        let petDeleteAction = UITableViewRowAction(style: .destructive, title: "Delete", handler: {(rowAction, indexPath) in
            self.petList.remove(at: indexPath.row)
            tableView.beginUpdates()
            tableView.deleteRows(at: [indexPath], with: .automatic)
            tableView.endUpdates()
        })
        
        if(indexPath.section == 1){
            return [petDeleteAction]
        }
        return nil
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0: // Profile
            return profileList.count
        case 1: // Pets
            return petList.count
        case 2: // Accounts
            return accountList.count
        default:
            return 0
        }
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        print("GET CELL!")
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
            print("Animal cell!")
            
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
            
            let petInfo = petList[indexPath.row]
            
            // Customize Text Field
            petNameTextField.autocorrectionType = .yes
            petNameTextField.textContentType = UITextContentType.name
            petNameTextField.delegate = self
            petNameTextField.text = petInfo.name
            
            // Customize Picker View
            petSpeciesPicker.delegate = self
            petSpeciesPicker.dataSource = self
            petSpeciesPicker.selectRow(petInfo.species!, inComponent: 0, animated: true)
            
            // Customize Text View
            petDetailTextField.delegate = self
            petDetailTextField.textColor = UIColor.lightGray
            petDetailTextField.text = petInfo.info
            
            // Customize Image View
            let imageViewSelectGesture = UITapGestureRecognizer(target: self, action: #selector(petImageSelect(sender:)))
            imageViewSelectGesture.numberOfTapsRequired = 1
            petImage.addGestureRecognizer(imageViewSelectGesture)
            petImage.image = petInfo.picture
            
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
            cellTextField.enablesReturnKeyAutomatically = true
            
            var cellInfo : InfoCell
            switch(indexPath.section){
            case 2:
                cellInfo = accountList[indexPath.item]
                
                // Account Indexes
                switch(accountList[indexPath.item].index!){
                case "email":
                    cellTextField.textContentType = UITextContentType.emailAddress
                    cellTextField.restorationIdentifier = "emailText"
                    break
                case "password":
                    cellTextField.textContentType = UITextContentType.password
                    break
                case "phone":
                    cellTextField.textContentType = UITextContentType.telephoneNumber
                    cellTextField.keyboardType = .numbersAndPunctuation
                    cellTextField.restorationIdentifier = "phoneText"
                    break
                default:
                    break
                }
                
                break
            default:
                cellInfo = profileList[indexPath.item]
                
                // Profile Titles
                switch(profileList[indexPath.item].title!){
                case nil:
                    break
                case "Full Name":
                    cellTextField.textContentType = UITextContentType.name
                    break
                case "Location":
                    cellTextField.textContentType = UITextContentType.fullStreetAddress
                    break
                default:
                    break
                }
                
                break
            }
            cellTextField.text = cellInfo.text
            cellTextField.placeholder = cellInfo.title
            cellImage.image = cellInfo.icon
            cellTextField.delegate = self
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
        
        let headerView = UIView()
        headerView.addSubview(headerCell!)
        
        return headerView
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if let height = cellHeights[indexPath] {
            return height
        }else{
            return cellIDs["infoCell"]!
        }
    }
    
    //MARK: UITextField Delegate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        guard let text = textField.text else{
            return
        }
        
        if(textField.restorationIdentifier == "petName"){
            if let parentCell = textField.superview?.superview as? UITableViewCell {
                print("ADD PET NAME!")
                let parentCellIndex = tableView.indexPath(for: parentCell)
                petList[parentCellIndex!.row].name = textField.text
            }
        }else if(textField.restorationIdentifier == "infoCell"){
            if let parentCell = textField.superview?.superview as? UITableViewCell {
                let parentCellIndex = tableView.indexPath(for: parentCell)
                if(parentCellIndex?.section == 0){
                    profileList[parentCellIndex!.row].text = textField.text
                }
            }
        }else if(textField.restorationIdentifier == "phoneText"){
            // Phone Number
            
            if let parentCell = textField.superview?.superview as? UITableViewCell {
                let parentCellIndex = tableView.indexPath(for: parentCell)
                if(accountList[parentCellIndex!.row].text != nil){
                    return
                }
                
                var phoneNumber = text
                if (text.count == 10){
                    phoneNumber = "+1\(text)"
                }
                
                UserLogin.VerifyPhone(phoneNumber: phoneNumber, completion: {(id, code, error) in
                    if let error = error {
                        let phoneErrorAlert = UIAlertController(title: "Phone Verification Error", message: "", preferredStyle: .alert)
                        
                        switch(error){
                        case AuthErrorCode.invalidPhoneNumber.rawValue:
                            phoneErrorAlert.message = "Invalid phone number was entered! The correct format for phone numbers include area code such as: (555)632-4567"
                            break
                        case AuthErrorCode.missingPhoneNumber.rawValue:
                            phoneErrorAlert.message = "Phone number was never given! The correct format for phone numbers include area code such as: (555)632-4567"
                            break
                        case AuthErrorCode.captchaCheckFailed.rawValue:
                            phoneErrorAlert.message = "ReCaptcha verification has failed! Please try again."
                            break
                        case AuthErrorCode.quotaExceeded.rawValue:
                            phoneErrorAlert.message = "Internal failure occured, please contact support with given key: <K01> "
                            break
                        default:
                            break
                        }
                        
                        phoneErrorAlert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: {(alert) in
                            
                        }))
                        
                        self.present(phoneErrorAlert, animated: true, completion: {() in })
                        return
                    }
                    
                    // NO ERRORS
                    UserLogin.LoginPhone(verificationID: id!, verificationCode: code!){(exists) in
                        print("Do you exists? \(exists)")
                    }
                    
                    
                })
                accountList[parentCellIndex!.row].text = phoneNumber
            }
        }else if(textField.restorationIdentifier == "emailText"){
            // Email
            
            if let parentCell = textField.superview?.superview as? UITableViewCell {
                let parentCellIndex = tableView.indexPath(for: parentCell)
                
                if(accountList[parentCellIndex!.row].text != nil){
                    return
                }
                
                // TO DO: Add Email Verification and Login here! This is where the pop up will show for creating a password as well.
                
                accountList[parentCellIndex!.row].text = text
            }
        }
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
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if(pickerView.restorationIdentifier == "petSpecies"){
            if let parentCell = pickerView.superview?.superview as? UITableViewCell {
                print("ADD PET SPECIES!")
                let parentCellIndex = tableView.indexPath(for: parentCell)
                petList[parentCellIndex!.row].species = row
            }
        }
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
        if (textView.textColor == UIColor.lightGray && textView.text == "Pet details..."){
            // If the text is light gray, remove the text
            textView.text = nil
            textView.textColor = UIColor.darkGray
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if(textView.restorationIdentifier == "petDetails"){
            if (textView.text.isEmpty){
                // If the text is light gray, remove the text
                textView.text = "Pet details..."
                textView.textColor = UIColor.lightGray
            }
            
            if let parentCell = textView.superview?.superview as? UITableViewCell {
                print("ADD PET DETAILS!")
                let parentCellIndex = tableView.indexPath(for: parentCell)
                petList[parentCellIndex!.row].info = textView.text
            }
        }
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if (text == "\n"){
            textView.resignFirstResponder()
            return false
        }
        return true
    }
    
    //MARK: UIImagePickerViewController Methods
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        guard let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage else {
            fatalError("ERROR: Image selected can't be found.")
        }
        if let imageView = petImageSelectedLast {
            imageView.image = pickedImage
            picker.dismiss(animated: true, completion: {() in })
            
            if(imageView.restorationIdentifier == "petImage"){
                if let parentCell = imageView.superview?.superview as? UITableViewCell {
                    print("Res ID: \(imageView.restorationIdentifier!)")
                    let parentCellIndex = tableView.indexPath(for: parentCell)
                    petList[parentCellIndex!.row].picture = pickedImage
                    print("PETTTT: \(petList[parentCellIndex!.row])")
                }else{
                    fatalError("SHIHVOISDANFOAHSDOF \(imageView.superview)")
                }
            }
            
            return
        }
        
        fatalError("ERROR: Last image view is nil!")
        
    }
    
}
