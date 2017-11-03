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
    let cellIDs : [String] = ["eventsCollectionCell", "locationCollectionCell", "datetimeCollectionCell"]
    enum collectionCellIDs : Int{
        case LocationCell = 1
    }
    var openedCell : IndexPath?
    
    //MARK: Outlets
    
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
                print("Set delegate of: \(subview)")
                subview.delegate = self
                
            }else{
                print("Extra subview: \(subview)")
            }
        }
        
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 1
    }
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 10
    }

    //MARK: UIPickerView Delegate
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        let eventTitle : String = "Test row \(row) for component \(component)"
        
        return eventTitle
    }
    
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 30
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let lastPickerViewChoice = pickerView.numberOfRows(inComponent: component) - 1
        
        // Open map for location set
        if(pickerView.tag == 1000){
            let cellPath = IndexPath(item: 0, section: collectionCellIDs.LocationCell.rawValue)
            //let locationCell = collectionView?.cellForItem(at: cellPath)
            
            if (row == lastPickerViewChoice) {
                openedCell = cellPath
                collectionView?.reloadData()
            }else{
                openedCell = nil
                collectionView?.reloadData()
                
            }
        }
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
        
        let defaultCellSize = CGSize(width: 414, height: 110)
        
        if (openedCell != nil && openedCell == indexPath) {
            let openedCellSize = CGSize(width: defaultCellSize.width,height: 300)
            return openedCellSize
        }
        
        return defaultCellSize
    }
    
    
    //MARK: Actions
}
