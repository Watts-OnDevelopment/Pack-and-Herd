//
//  LoginPageController.swift
//  Pack and Herd
//
//  Created by Cameron Watson on 10/26/17.
//  Copyright © 2017 Watts-On Development. All rights reserved.
//

import UIKit
import Firebase

@IBDesignable class LoginPageController : UIViewController, UITextFieldDelegate{
   
    //MARK: Properties
    public static let dataKey : String = "authVerificationID"
    
    //MARK: Outlets
    @IBOutlet weak var phoneConButton: UIButton!
    @IBOutlet weak var googleConButton: UIButton!
    @IBOutlet weak var phoneCodeSendButton: UIButton!
    @IBOutlet weak var phoneNumberField: DefaultTextField!
    @IBOutlet weak var emailConnectButton: UIButton!
    @IBOutlet weak var emaIlField: DefaultTextField!
    @IBOutlet weak var passwordTextField: DefaultTextField!
    
    
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
        
        // Set autoshrink
        emailConnectButton.titleLabel?.adjustsFontSizeToFitWidth = true
        
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
    private func CheckEmail(emailText : String) -> Bool{
        // Create string whitelist
        let emailArgs : [String] = ["a-z", "A-Z"]
        let emailReqs : NSPredicate = NSPredicate(format: "SELF MATCHES %@", argumentArray: emailArgs)

        print("Email: \(emailText)")
        print(emailReqs.evaluate(with: emailText))
        
        return emailReqs.evaluate(with: emailText)
    }
    
    private func CheckPassword(passwordText : String) -> String?{
        // Checks
        if(passwordText.characters.count < 8){
            return "there are less than 8 characters!"
        }
        print(passwordText)
        
        return nil
    }
    
    private func PhoneConnectButtonAnimComplete(didComplete: Bool) -> Void{
        if didComplete {
            phoneConButton.isEnabled = false
            phoneNumberField.isEnabled = true
            phoneCodeSendButton.isEnabled = true
        }else{
            fatalError("PhoneConnectButton animation failed!")
        }
    }
    
    private func PresentSMSAlert(){
        // Constructors
        let alertController = UIAlertController(title: "SMS Charge", message: "By using the phone sign-in method you may be SMS texted a code for verifcation. Standard rates do apply.", preferredStyle: .alert)
        let alertCloseButton = UIAlertAction(title: "Close", style: .cancel, handler: {(UIAlertAction) in
            print("Cancelled!")
        })
        let alertSendButton = UIAlertAction(title: "Send", style: .default, handler: {(UIAlertAction) in
            self.SendPhoneCode()
        })
        
        alertController.addAction(alertCloseButton)
        alertController.addAction(alertSendButton)
        
        present(alertController, animated: true, completion: nil)
    }
    
    private func SendPhoneCode(){
        let phoneNumber : String = {
            var phoneNum : String = ""
            guard let phoneNumberText = phoneNumberField.text else{
                fatalError("ERROR: Unable to get text for phone number!")
            }
            for i in 0 ..< phoneNumberText.characters.count{
                let currentChar = phoneNumberText.index(phoneNumberText.startIndex,offsetBy: i)
                let currentString = String(phoneNumberText[currentChar])
                if Int(currentString) != nil {
                    phoneNum += currentString
                }
            }
            phoneNum = "+1"+phoneNum
            return phoneNum
        }()
        PhoneAuthProvider.provider().verifyPhoneNumber(phoneNumber, uiDelegate: nil, completion: PhoneAuthCompletion as VerificationResultCallback)
    }
    
    private func PhoneAuthCompletion(verificationID:String?, error:Error?){
        if let error = error{
            print("Localized Description: "+error.localizedDescription)
            return
        }
        UserDefaults.standard.set(verificationID, forKey: LoginPageController.dataKey)
        
        let phoneVerifyID : String = "loginPhoneVerification"
        performSegue(withIdentifier: phoneVerifyID, sender: self)
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
        UIView.animate(withDuration: 0.5, animations: PhoneClickAnimation, completion: PhoneConnectButtonAnimComplete)
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
            PresentSMSAlert()
        }
    }
    @IBAction func EmailConnectButton(_ sender: UIButton) {
        guard let emailText = emaIlField.text, let passwordText = passwordTextField.text else{
            print("ERROR: No text entered!")
            return
        }
        
        guard let emailValidatedText = TextFieldValidations.CheckEmailValid(emailText: emailText)else{
            // Email is invalid
            print("Email is invalid!")
            let emailErrorAlert : UIAlertController = UIAlertController(title: "Email Error", message: "The given email is invalid! \nExample: michael@packandherd.com", preferredStyle: .alert)
            let emailErrorAlertClose : UIAlertAction = UIAlertAction(title: "Close", style: .cancel, handler: {(alertAction) in print("Closed email alert menu.")})
            
            emailErrorAlert.addAction(emailErrorAlertClose)
            present(emailErrorAlert, animated: true, completion: {() in })
            return
        }
        if let passwordError = TextFieldValidations.CheckPasswordValid(passwordText: passwordText) {
            // Password is invalid
            print("Password is invalid!")
            let passErrorAlert : UIAlertController = UIAlertController(title: "Password Error", message: "The given password is invalid because \(passwordError)", preferredStyle: .alert)
            let passErrorAlertClose : UIAlertAction = UIAlertAction(title: "Close", style: .cancel, handler: {(alertAction) in print("Closed password alert menu.")})
            
            passErrorAlert.addAction(passErrorAlertClose)
            present(passErrorAlert, animated: true, completion: {() in })
            return
        }
        
        print("Email and Password are valid!")
        print(emailValidatedText)
        
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
}
