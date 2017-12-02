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
    private var hiddenTimes : [TimePeriod] = []
    @IBInspectable private let date : Bool = true
    
    struct TimePeriod {
        var startDate : Date
        var endDate : Date
        
        func timeInterval() -> TimeInterval{
            return endDate.timeIntervalSince(startDate)
        }
    }
    
    //MARK: Inits
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
    }
    
    //MARK: PickerViewDataSource Methods
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        if date {
            
        }else{
            
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        <#code#>
    }
    
    //MARK: PickerViewDelegate Methods
    
    //MARK: Firestore Methods
    
    
}
