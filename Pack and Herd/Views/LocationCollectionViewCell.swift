//
//  LocationCollectionViewCell.swift
//  Pack and Herd
//
//  Created by Cameron Watson on 11/9/17.
//  Copyright © 2017 Watts-On Development. All rights reserved.
//

import UIKit
import MapKit

class LocationCollectionViewCell: UICollectionViewCell, UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource {
    //MARK: Outlets
    @IBOutlet weak var locationField: DefaultTextField!
    
    //MARK: Properties
    
    //MARK: Inits
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func awakeFromNib() {
        // Customization
        
        locationField.delegate = self
    }
    
    //MARK: Methods
    
    //MARK: Text Field Delegates
    func textFieldDidEndEditing(_ textField: UITextField) {
        guard let address = textField.text else {
            return
        }
        
//        let addressGeocoder = CLGeocoder()
//        addressGeocoder.geocodeAddressString(address, completionHandler: {(placeMark, error) in
//            if let error = error {
//                print("ERROR: \(error.localizedDescription)")
//                return
//            }
//
//            guard let firstPlacemark = placeMark?.first  else {
//                print("ERROR: First placemark not found!")
//                return
//            }
//
//
//            let locationMark = MKPlacemark(placemark: firstPlacemark)
//
//            var region : MKCoordinateRegion = self.locationMap.region
//            region.center = locationMark.coordinate
//            region.span.latitudeDelta /= 120
//            region.span.longitudeDelta /= 120
//
//            self.locationMap.setRegion(region, animated: true)
//            self.locationMap.addAnnotation(locationMark)
//
//        })
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    //MARK: Picker View Delegate
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
    }
    
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 30
    }
    
    func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        let text = "Test row \(row) for component \(component)"
        let attributedText = NSAttributedString(string: text, attributes: [NSAttributedStringKey.foregroundColor:UIColor.darkGray])
        
        return attributedText
    }
    
    //MARK: Picker View Datasource
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return 5
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
}
