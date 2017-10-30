//
//  DefaultTextField.swift
//  Pack and Herd
//
//  Created by Cameron Watson on 10/26/17.
//  Copyright © 2017 Watts-On Development. All rights reserved.
//

import UIKit

class DefaultTextField : UITextField{
    //MARK: Properties
    let placeholderColor : UIColor = .white
    
    //MARK: UITextField Overrides
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
   
    override func textRect(forBounds bounds: CGRect) -> CGRect {
        let textFieldRect : CGRect = {
            let cgRect = bounds.insetBy(dx: 10, dy: 0)
            
            return cgRect
        }()
        
        return textFieldRect
    }
    
    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        let editFieldRect : CGRect = {
            let cgRect = bounds.insetBy(dx: 10, dy: 0)
            
            return cgRect
        }()
        
        return editFieldRect
    }
    
}
