//
//  ForgetPSViewController.swift
//  DAM
//
//  Created by Apple Esprit on 7/11/2024.
//

import UIKit

class ForgetPSViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var otpMail: UITextField!
    
    
    var code :Int!
    var email : String!
    
 
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        // Set the text field delegates
        otpMail.delegate = self
        otpMail.keyboardType = .emailAddress

    }

    

    
    
    // Continue button action to validate fields
    @IBAction func continueAction(_ sender: Any) {
   
        guard let emailText = otpMail.text, !emailText.isEmpty else {
                    showAlert(message: "Please enter a valid email.")
                    return
                }
                
                if isValidEmail(emailText) {
                    let parameters: [String: Any] = [
                        "email": emailText
                    ]
                    email = emailText
                    sendForgotPasswordRequest(parameters: parameters)
                } else {
                    showAlert(message: "Please enter a valid email.")
                }
            }
            
            // Helper function to show alerts
    private func showAlert(message: String) {
            DispatchQueue.main.async {
                guard self.isViewLoaded && self.view.window != nil else { return }
                let alert = UIAlertController(title: "Invalid Input", message: message, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
        }
            
            // Validate email format
            private func isValidEmail(_ email: String) -> Bool {
                let emailPattern = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
                let emailPred = NSPredicate(format: "SELF MATCHES %@", emailPattern)
                return emailPred.evaluate(with: email)
            }
            
            // Send forgot password request
    private func sendForgotPasswordRequest(parameters: [String: Any]) {
            guard let url = URL(string: "http://172.18.20.186:3001/auth/forget-password") else { return }
            
            do {
                let jsonData = try JSONSerialization.data(withJSONObject: parameters, options: [])
                
                var request = URLRequest(url: url)
                request.httpMethod = "POST"
                request.httpBody = jsonData
                request.setValue("application/json", forHTTPHeaderField: "Content-Type")
                
                let task = URLSession.shared.dataTask(with: request) { data, response, error in
                    if let error = error {
                        print("Request error:", error)
                        return
                    }
                    
                    guard let data = data, !data.isEmpty else {
                        print("Response data is missing.")
                        return
                    }
                    
                    // **Print response data for debugging**
                    print("Response data:", String(data: data, encoding: .utf8) ?? "No readable data")
                    
                    // Handle the response from the server
                    self.handleResponse(data: data)
                }
                
                // Start the request task
                task.resume()
                
            } catch {
                print("Error serializing JSON:", error.localizedDescription)
            }
        }
        
        // Handles the response from the server
        private func handleResponse(data: Data) {
            // **Made `user` optional to handle missing field**
            struct ForgotPasswordData: Decodable {
                let code: Int
                let user: String? // Optional user field
            }
            
            do {
                // Decode the JSON response into the ForgotPasswordData struct
                let responseData = try JSONDecoder().decode(ForgotPasswordData.self, from: data)
                
                // Set the OTP code to the `code` variable
                self.code = responseData.code
                
                // Perform segue to the OTP view controller on the main thread
                DispatchQueue.main.async {
                    self.performSegue(withIdentifier: "otp", sender: (self.email, self.code))
                }
            } catch {
                // If there's an error in decoding, print it to the console
                print("Error decoding response:", error)
            }
        }
        
        override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
            if segue.identifier == "otp", let (email, code) = sender as? (String, Int) {
                let destination = segue.destination as! RecupCodeViewController
                destination.email = email
                destination.otp = code
            }
        }
    struct ForgotPasswordData: Decodable {
        let code: Int
        let statusCode: Int
    }
    }
