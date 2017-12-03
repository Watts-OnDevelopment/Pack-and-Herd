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
                break;
            case 1: // Day
                return 31
                return 7
                break;
            case 2: // Year
                return 2
                break;
            default:
                return 0
                break;
            }
        }else{
            return 2
        }
    }
    
    //MARK: PickerViewDelegate Methods
    
    //MARK: Firestore Methods
    private func getEventTimes(){
        
    }
    
}
