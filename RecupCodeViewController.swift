//
//  RecupCodeViewController.swift
//  DAM
//
//  Created by Apple Esprit on 11/11/2024.
//

import UIKit

class RecupCodeViewController: UIViewController,UITextFieldDelegate {
   

    
    @IBOutlet weak var otpTextField: UITextField!
    
    
    var otp : Int?
        var email : String?

    override func viewDidLoad() {
        super.viewDidLoad()
    
              
              // Set delegate and keyboard type for the OTP text field
              otpTextField.delegate = self
              otpTextField.keyboardType = .numberPad
          }
          
          // Restrict input to numeric characters and limit to 6 digits
          func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
              // Only allow numbers
              let characterSet = CharacterSet(charactersIn: "0123456789")
              let filtered = string.rangeOfCharacter(from: characterSet.inverted)
              
              // Prevent non-numeric input
              if filtered != nil {
                  return false
              }
              
              // Limit input to 6 characters
              let currentText = textField.text ?? ""
              return currentText.count + string.count - range.length <= 6
          }
          
          // Action for Continue button
    @IBAction func continueAction(_ sender: Any) {
    
              // Validate OTP input
              guard let codeOtpEnter = otpTextField.text, codeOtpEnter.count == 6 else {
                  showAlert(message: "OTP must be exactly 6 digits.")
                  return
              }

              // Check if the entered OTP matches the correct OTP
              if let enteredOtp = Int(codeOtpEnter), enteredOtp == otp {
                  // Successfully matched OTP, navigate to reset password screen
                  print("OTP is correct")
                  DispatchQueue.main.async {
                      self.performSegue(withIdentifier: "newPassword", sender: self.email)
                  }
              } else {
                  // OTP is incorrect
                  //print("Incorrect OTP")
                  //showAlert(message: "Invalid OTP input")
              }
          }
          
          // Prepare for segue to the next screen
          override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
              if segue.identifier == "otpSeg", let email = sender as? String {
                  let destination = segue.destination as! ResetPViewController
                  destination.emailSeg = email
              }
          }
          
          // Show alert for validation errors
          func showAlert(message: String) {
              let alert = UIAlertController(title: "Validation Error", message: message, preferredStyle: .alert)
              alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
              present(alert, animated: true, completion: nil)
          }
      }
        
        

    
    

    


