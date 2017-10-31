//
//  PhoneVerifyController.swift
//  Pack and Herd
//
//  Created by Cameron Watson on 10/31/17.
//  Copyright © 2017 Watts-On Development. All rights reserved.
//

import UIKit
import Firebase

class PhoneVerificationController : UIViewController {
    //MARK: Outlets
    @IBOutlet weak var VerificationCodeField: DefaultTextField!
    @IBOutlet weak var verificationCodeMessageLabel: UILabel!
    @IBOutlet weak var emailField : UILabel!
    @IBOutlet weak var passwordField : UILabel!
    
    //MARK: Methods
    private func AuthLogin(verifCode : String){
        guard let verificationID = UserDefaults.standard.string(forKey: LoginPageController.dataKey) else{
            fatalError("ERROR: Phone verification ID not found in user data!")
        }
        let credential : PhoneAuthCredential = PhoneAuthProvider.provider().credential(withVerificationID: verificationID, verificationCode: verifCode)
        
        Auth.auth().signIn(with: credential, completion: PhoneAuthResult as AuthResultCallback)
    }
    
    private func PhoneAuthResult(user:User?, error:Error?){
        if let error = error {
            //fatalError("ERROR: PhoneAuthResult - "+error.localizedDescription)
            UIView.animate(withDuration: 1, animations: {()in
                self.verificationCodeMessageLabel.alpha = 1
            }, completion: {(didComplete) in
                // Delay time
                let delayTime = DispatchTime.now() + 1
                // Create dispatch queue
                DispatchQueue.main.asyncAfter(deadline: delayTime, execute: {() in
                    UIView.animate(withDuration: 1, animations: {() in
                        self.verificationCodeMessageLabel.alpha = 0
                    })
                })
            })
            print("ERROR: "+error.localizedDescription)
            return
        }
        print("User signed in!")
        // CHANGE TO SEGUE TO HOME PAGE!!
        dismiss(animated: true, completion: nil)
    }
    
    //MARK: UIViewController Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Hide keyboard on tap away
        self.HideKeyboardOnTouchAway()
        
        // Hide verification code invalid message
        verificationCodeMessageLabel.alpha = 0
        
        // Change adjust font size for width
        verificationCodeMessageLabel.adjustsFontSizeToFitWidth = true
    }
    
    //MARK: Actions
    @IBAction func CancelPhoneVerification(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    @IBAction func VerifyPhoneButton(_ sender: UIButton) {
        guard let verifCodeText = VerificationCodeField.text else{
            fatalError("ERROR: Couldn't get text from field!")
        }
        AuthLogin(verifCode: verifCodeText)
    }
    
    
}
