//
//  LoginPageController.swift
//  Pack and Herd
//
//  Created by Cameron Watson on 10/26/17.
//  Copyright © 2017 Watts-On Development. All rights reserved.
//

import UIKit
import Firebase
import GoogleSignIn

class LoginPageController : UIViewController, UITextFieldDelegate, GIDSignInUIDelegate{
   
    //MARK: Properties
    public static let dataKey : String = "authVerificationID"
    @IBInspectable private let developer : Bool = false
    private var selectedTextField : UITextField?
    
    //MARK: Outlets
    @IBOutlet weak var phoneConButton: UIButton!
    @IBOutlet weak var googleConButton: GIDSignInButton!
    @IBOutlet weak var phoneCodeSendButton: UIButton!
    @IBOutlet weak var phoneNumberField: DefaultTextField!
    @IBOutlet weak var emailConnectButton: UIButton!
    @IBOutlet weak var emaIlField: DefaultTextField!
    @IBOutlet weak var passwordTextField: DefaultTextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        AppDelegate.developer = developer
        
        Auth.auth().addStateDidChangeListener({(auth, user) in
            if user != nil {
                self.FinishLogin()
            }
        })
        
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
        NotificationCenter.default.addObserver(self, selector: #selector(KeyboardWillShow) , name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        
        // Enable closing of keyboard when touched away
        self.HideKeyboardOnTouchAway()
        
        // Set autoshrink
        emailConnectButton.titleLabel?.adjustsFontSizeToFitWidth = true
        
        // Customize Google Signin Delegate
         GIDSignIn.sharedInstance().uiDelegate = self
        
    }
    
    //MARK: Oberserver Methods
    @objc private func KeyboardWillShow(notification : NSNotification){
    
    }
    @objc private func KeyboardDidShow(notification : NSNotification){
        guard let scrollView = view as? UIScrollView else{
            fatalError("<FAT>: View can not be converted to a scrollview!")
        }
        guard let userInfo = notification.userInfo else{
            fatalError("ERROR: Can't retreive information from the user device!")
        }
        guard let keyboardRect : CGRect = userInfo["UIKeyboardFrameEndUserInfoKey"] as? CGRect else {
            fatalError("ERROR: Frame begin user info is not found!")
        }
        
        guard let selectedField = selectedTextField else{
            print("<ERR>: No text field is selected!")
            return
        }
        
        if scrollView.contentInset.top != 0 {
            return
        }
        
        let maskedRegion = CGRect(x: 0, y: (view.frame.height - keyboardRect.height), width: view.frame.width, height: keyboardRect.height)
        
        print("Keyboard Rect: \(maskedRegion)")
        print("View Rect: \(view.frame)")
        print("Phone Field Origin: \(selectedField.frame.origin)")
        
        if (maskedRegion.contains(selectedField.frame.origin)){
            let bottomInset : CGFloat = {
                var inset : CGFloat = 0
                inset = keyboardRect.maxY - selectedField.frame.minY
                inset += 250
                return inset
            }()
            AnimateScrollView(topInset: bottomInset)
        }

    }
    @objc private func KeyboardDidHide(notification : NSNotification){
        AnimateScrollView(topInset: 0)
    }
    
    //MARK: Animation Methods
    private func AnimateScrollView(topInset : CGFloat){
        guard let scrollView = view as? UIScrollView else{
            fatalError("<FAT>: View can not be converted to a scrollview!")
        }
        
        print("Animate it!! \(topInset)")
        scrollView.contentInset.top = -topInset
        
        //UIView.animate(withDuration: 0, animations: {()
        //    scrollView.contentInset.top = -topInset
        //})
    }
    
    //MARK: Methods
    /*
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
    } */
    
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
    
    
    public func FinishLogin(){
        performSegue(withIdentifier: "segueHome", sender: self)
        
    }
    
    private func CheckEmailUser(email : String, pass : String, completion : @escaping (_ success : Bool, _ email : String, _ password : String) -> Void){
        Auth.auth().fetchProviders(forEmail: email, completion: {(ids, error) in
            if let error = error as NSError? {
                print("ERROR: \(error.localizedDescription)")
                return
            }
            guard let ids = ids else{
                print("There are no ids for this email!")
                
                let createEmailAlert = UIAlertController(title: "Create Account", message: "The given email was not found. Would you like to create a new account?", preferredStyle: .alert )
                let createEmailAlert_Close = UIAlertAction(title: "Close", style: .cancel, handler: {(alertAction) in
                    print("Create email account alert closed")
                })
                createEmailAlert.addAction(createEmailAlert_Close)
                let createEmailAlert_Create = UIAlertAction(title: "Create", style: .default, handler: {(alertAction) in
                    print("Create email account created")
                    self.CreateEmailUser(email: email, pass: pass)
                })
                createEmailAlert.addAction(createEmailAlert_Create)
                self.present(createEmailAlert, animated: true, completion: {() in })
                
                return
            }
            for id in ids {
                print("ID: \(id)")
                if (id == "password"){
                    // Account exists!
                    completion(true, email, pass)
                }else if(id == "google.com"){
                    GIDSignIn.sharedInstance().signIn()
                    /*let googleErrorAlertController = UIAlertController(title: "Email Login Error", message: "Your email is locked into your google account, please connect through google instead.", preferredStyle: .alert)
                    let googleErrorAlertCloseButton = UIAlertAction(title: "Close", style: .cancel, handler: {(alertAction) in })
                    googleErrorAlertController.addAction(googleErrorAlertCloseButton)
                    let googleErrorAlertLoginButton = UIAlertAction(title: "Connect", style: .default, handler: {(alertAction) in
                        GIDSignIn.sharedInstance().signIn()
                    })
                    googleErrorAlertController.addAction(googleErrorAlertCloseButton)
                    googleErrorAlertController.addAction(googleErrorAlertLoginButton)
                    self.present(googleErrorAlertController, animated: true, completion: {() in }) */
                }else{
                    print("<ERR>: Password not found in account!")
                    return
                }
            }
            
        })
    }
    
    private func CreateEmailUser(email : String, pass : String){
        Auth.auth().createUser(withEmail: email, password: pass, completion: {(user, error) in
            if let error = error as NSError?{
                print("ERROR: Create User - \(error.localizedDescription)")
                guard let errorName : String = error.userInfo["error_name"] as? String else{
                    fatalError("ERROR: User data not error_name not found in error!")
                }
                
                if(errorName == "ERROR_EMAIL_ALREADY_IN_USE"){
                    // Account already made
                    self.LoginEmailUser(email: email, pass: pass)
                }
                return
            }
            print("Email creation successful!")
            self.LoginEmailUser(email: email, pass: pass)
        })
    }
    
    private func LoginEmailUser(email : String, pass : String){
        Auth.auth().signIn(withEmail: email, password: pass, completion:{(user, error) in
            if let error = error as NSError?{
                print("ERROR: \(error.localizedDescription)")
                guard let errorName = error.userInfo["error_name"] as? String else{
                    fatalError("ERROR: User data not error_name not found in error!")
                }
                print("ERROR: \(errorName)")
                
                if(errorName == "ERROR_WRONG_PASSWORD"){
                    let wrongPasswordAlert = UIAlertController(title: "Password Incorrect", message: "The given password is incorrect. Would you like to reset it?", preferredStyle: .alert )
                    let wrongPasswordAlert_Close = UIAlertAction(title: "Close", style: .cancel, handler: {(alertAction) in
                        print("Reset password alert closed")
                    })
                    wrongPasswordAlert.addAction(wrongPasswordAlert_Close)
                    let wrongPasswordAlert_Reset = UIAlertAction(title: "Reset", style: .default, handler: {(alertAction) in
                        print("Reset password alert reset")
                        Auth.auth().sendPasswordReset(withEmail: email, completion: {(error) in
                            print("Password reset sent!")
                        })
                    })
                    wrongPasswordAlert.addAction(wrongPasswordAlert_Reset)
                    self.present(wrongPasswordAlert, animated: true, completion: {() in })
                }
                
                return
            }
            print("Email login successful!")
            
            self.FinishLogin()
            
            
        })
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
        GIDSignIn.sharedInstance().signIn()
    }
    
    @IBAction func PhoneSendCodeButton(_ sender: UIButton) {
        guard let phoneNumber = phoneNumberField.text else{
            fatalError("ERROR: Unable to get text for phone number!")
        }
        
        // Verify phone number
        UserLogin.VerifyPhone(phoneNumber: phoneNumber, completion: {(id, code, error) in
            if let error = error {
                let phoneErrorAlert = UIAlertController(title: "Phone Verification Error", message: "", preferredStyle: .alert)
                
                switch(error){
                case AuthErrorCode.invalidPhoneNumber.rawValue:
                    phoneErrorAlert.message = "Invalid phone number was entered! The correct format for phone numbers include area code such as: (555)632-4567"
                    break
                case AuthErrorCode.missingPhoneNumber.rawValue:
                    phoneErrorAlert.message = "Phone number was never given! The correct format for phone numbers include area code such as: (555)632-4567"
                    break
                case AuthErrorCode.captchaCheckFailed.rawValue:
                    phoneErrorAlert.message = "ReCaptcha verification has failed! Please try again."
                    break
                case AuthErrorCode.quotaExceeded.rawValue:
                    phoneErrorAlert.message = "Internal failure occured, please contact support with given key: <K01> "
                    break
                default:
                    break
                }
                
                phoneErrorAlert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: {(alert) in
                    
                }))
                
                self.present(phoneErrorAlert, animated: true, completion: {() in })
                return
            }
            
            // NO ERRORS
            UserLogin.LoginPhone(verificationID: id!, verificationCode: code!){(exists) in
                print("Do you exists? \(exists)")
                
                self.FinishLogin()
            }
        })
        
        
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
        
        var userExists = false
        // Run check user to see whether or not the email already exists, if they do then log them in and stop this.
        CheckEmailUser(email: emailValidatedText, pass: passwordText){(success, email, password) in
            // Completion closure
            if success {
                // If email is in use.
                self.LoginEmailUser(email: email, pass: password)
                userExists = true
            }
        }
        
        if userExists {
            // If the user exists return out of the button action
            return
        }
        
        if let passwordSecurityLevel = TextFieldValidations.CheckPasswordStrength(passwordText: passwordText) {
            print("Password Strength: \(passwordSecurityLevel)")
            let passErrorAlert : UIAlertController = UIAlertController(title: "Password Error", message: "The given password is invalid because ", preferredStyle: .alert)
            let passErrorAlertClose : UIAlertAction = UIAlertAction(title: "Close", style: .cancel, handler: {(alertAction) in print("Closed password alert menu.")})
            passErrorAlert.addAction(passErrorAlertClose)
            if (passwordSecurityLevel == TextFieldValidations.SecurityLevels.invalid){
                // Password Strength: Invalid
                passErrorAlert.title = "Password Error"
                passErrorAlert.message = "The given password is invalid because it is not strong enough. Make sure to have: \n1. at least 8 characters. \n2. at least 1 capital letter. \n3. at least 1 number. "
                present(passErrorAlert, animated: true, completion: {() in })
                return
            }else if (passwordSecurityLevel == TextFieldValidations.SecurityLevels.weak){
                // Password Strength: Weak
                let passErrorAlertConfirm : UIAlertAction = UIAlertAction(title: "Confirm", style: .default, handler: {(alertAction) in print("Confirmed password alert menu.")
                    self.CreateEmailUser(email: emailValidatedText, pass: passwordText)
                })
                passErrorAlert.addAction(passErrorAlertConfirm)
                passErrorAlert.title = "Password Warning"
                passErrorAlert.message = "The given password is insecure. To gurantee your security you should have: \n1. at least 8 characters. \n2. at least 1 capital letter. \n3. at least 1 number. \nAre you sure you want an insecure password?"
                present(passErrorAlert, animated: true, completion: {() in })
            }else if(passwordSecurityLevel == TextFieldValidations.SecurityLevels.strong){
                // Password Strength: Strong
                
            }
        }
        print("Email and Password are valid!")
        print(emailValidatedText)
    }
    
    //MARK: Google Signin Delegates
    
    
    //MARK: TextField Delegates
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        selectedTextField = textField
        return true
    }
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
