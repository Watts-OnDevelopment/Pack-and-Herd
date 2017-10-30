//
//  ViewControllerExtension.swift
//  Pack and Herd
//
//  Created by Cameron Watson on 10/30/17.
//  Copyright © 2017 Watts-On Development. All rights reserved.
//

import UIKit

extension UIViewController {
    func HideKeyboardOnTouchAway(){
        let tapCheck = UITapGestureRecognizer(target: self, action: #selector(UIViewController.hideKeyboard(sender:)))
        
        view.addGestureRecognizer(tapCheck)
    }
    
    @objc func hideKeyboard(sender : UITapGestureRecognizer){
        UIApplication.shared.keyWindow?.endEditing(true)
    }
}
