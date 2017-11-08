//
//  DatePickerViewq.swift
//  Pack and Herd
//
//  Created by Cameron Watson on 11/5/17.
//  Copyright © 2017 Watts-On Development. All rights reserved.
//

import UIKit

class DatePickerView : UIDatePicker {
    
    //MARK: Inits
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // Customize
        setValue(UIColor.darkGray, forKey: "textColor")
    }
    
}
