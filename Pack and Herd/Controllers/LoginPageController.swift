//
//  LoginPageController.swift
//  Pack and Herd
//
//  Created by Cameron Watson on 10/26/17.
//  Copyright © 2017 Watts-On Development. All rights reserved.
//

import UIKit

class LoginPageController : UIViewController, UITextFieldDelegate{
   
    //MARK: Properties
    
    //MARK: Outlets
    @IBOutlet weak var phoneConButton: UIButton!
    @IBOutlet weak var googleConButton: UIButton!
    @IBOutlet weak var phoneCodeSendButton: UIButton!
    @IBOutlet weak var phoneNumberField: DefaultTextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set phoneNumberField delegate to the custom PhoneNumberTextField class
        phoneNumberField.delegate = self
        
        // Set phoneNumberField and phoneCodeSendButton to disabled at start
        phoneNumberField.isEnabled = false
        phoneCodeSendButton.isEnabled = false
        phoneNumberField.alpha = 0
        phoneCodeSendButton.alpha = 0
        
        // Add observers
        NotificationCenter.default.addObserver(self, selector: #selector(KeyboardDidShow), name: NSNotification.Name.UIKeyboardDidShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(KeyboardDidHide) , name: NSNotification.Name.UIKeyboardDidHide, object: nil)
        
        // Enable closing of keyboard when touched away
        self.HideKeyboardOnTouchAway()
    }
    
    
    //MARK: Oberserver Methods
    @objc private func KeyboardDidShow(notification : NSNotification){
        guard let userInfo = notification.userInfo else{
            fatalError("ERROR: Can't retreive information from the user device!")
        }
        guard let keyboardRect : CGRect = userInfo["UIKeyboardFrameBeginUserInfoKey"] as? CGRect else {
            fatalError("ERROR: Frame begin user info is not found!")
        }
        print(keyboardRect.height)
        
        let maskedArea : CGRect = {
            let areaY : CGFloat = view.bounds.height - keyboardRect.height
            let areaSize : CGRect = view.bounds
            let area = CGRect(x: 0.0, y: areaY, width: areaSize.maxX, height: areaSize.maxY)
            
            return area
        }()
        
        if !maskedArea.contains(phoneNumberField.frame.origin){
            guard let scrollView : UIScrollView = view as? UIScrollView else{
                fatalError("ERROR: Main view is not a scroll view!")
            }
            scrollView.scrollRectToVisible(phoneNumberField.bounds, animated: true)
            
            print("The point is hidden!")
        }else{
            print("The point is shown!")
        }
        
        /*for info in userInfo {
            if let val = info.value as? CGRect , let key = info.key as? String {
                print(key)
                print(val)
            }
        }*/
        
        print("Keyboard shown!")
    }
    @objc private func KeyboardDidHide(notification : NSNotification){
        
        
        print("Keyboard hidden!")
    }
    
    //MARK: Methods
    private func PhoneConnectButtonAnimComplete(didComplete: Bool) -> Void{
        if didComplete {
            phoneConButton.isEnabled = false
            phoneNumberField.isEnabled = true
            phoneCodeSendButton.isEnabled = true
        }else{
            fatalError("PhoneConnectButton animation failed!")
        }
    }
    
    private func SendPhoneCode(){
        print("Phone code sent!")
    }
    
    //MARK: Animation Methods
    private func PhoneClickAnimation() -> Void{
        phoneConButton.alpha = 0
        phoneNumberField.alpha = 1
        phoneCodeSendButton.alpha = 1
    }
    
    //MARK: Actions
    @IBAction func PhoneConnectButton(_ sender: UIButton) {
        print("Connect with Phone.")
        UIView.animate(withDuration: 1, animations: PhoneClickAnimation, completion: PhoneConnectButtonAnimComplete)
    }
    
    @IBAction func GoogleConnectButton(_ sender: UIButton) {
        print("Connect with Google.")
    }
    
    @IBAction func PhoneSendCodeButton(_ sender: UIButton) {
        guard let phoneNumber = phoneNumberField.text else{
            fatalError("ERROR: Unable to get text for phone number!")
        }
        if phoneNumber.characters.count < 13 {
            print("Invalid phone number!")
        }else{
            SendPhoneCode()
        }
    }
    
    //MARK: TextField Delegates
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        // Switch to determine which textfield is being changed
        switch(textField.tag){
        case 1000:
            // Phone number text field
            guard let curPhoneStr = textField.text else {return false}
            let charIndex = range.location
            if string.isEmpty {
                // Backspace
                if charIndex == 4{
                    let lowTextBound = curPhoneStr.index(curPhoneStr.startIndex, offsetBy: 1)
                    let upperTextBound = curPhoneStr.index(curPhoneStr.startIndex, offsetBy: 3)
                    let nextText = String(curPhoneStr[lowTextBound..<upperTextBound])
                    //Range
                    textField.text = nextText
                    return false
                }
            }else{
                if Int(string) == nil {
                    return false
                }
                if charIndex > 12 {
                    return false
                }else if charIndex == 2{
                    let nextText = "("+curPhoneStr+string+")"
                    textField.text = nextText
                    return false
                }
                else if charIndex == 8{
                    let nextText = curPhoneStr+"-"+string
                    textField.text = nextText
                    return false
                }
            }
            print(string.isEmpty)
            break;
        default:
            fatalError("TextField has tag that is uncased in switch!")
            break;
        }
        return true
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        return true
    }
    
    
}
