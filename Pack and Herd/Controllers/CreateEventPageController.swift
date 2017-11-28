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
    
    //MARK: Methods
    public func pageCheck(){
        
    }
    
    //MARK: UIViewController Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
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
            if let subview = subview as? UIPickerView {
                print("Set picker view delegate of: \(subview)")
                if(subview.restorationIdentifier != "location"){
                    subview.delegate = self
                }else{
                    print("NOIOOOOO")
                }
            }else if let subview = subview as? UIDatePicker {
                let subviews = subview.subviews
                for subv in subviews {
                    subv.subviews[1].alpha = 0
                    subv.subviews[2].alpha = 0
                }
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
//    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
//        let eventTitle : String = "Test row \(row) for component \(component)"
//
//        return eventTitle
//    }
    
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 30
    }
    
    func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        let text = "Test row \(row) for component \(component)"
        let attributedText = NSAttributedString(string: text, attributes: [NSAttributedStringKey.foregroundColor:UIColor.darkGray])
        
        return attributedText
    }
    
    //MARK: UIPickerView Data Source
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return 5
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
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
