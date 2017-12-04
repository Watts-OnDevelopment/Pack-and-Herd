//
//  DatePickerExtension.swift
//  Pack and Herd
//
//  Created by Cameron Watson on 12/3/17.
//  Copyright © 2017 Watts-On Development. All rights reserved.
//

import Foundation

extension DateInterval{
    public func toDictionary() -> [String:Any]{
        var dictionary : [String:Any] = [:]
        dictionary["start"] = self.start
        dictionary["end"] = self.end
        
        return dictionary
    }
}
