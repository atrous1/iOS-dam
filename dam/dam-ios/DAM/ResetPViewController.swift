//
//  ResetPViewController.swift
//  DAM
//
//  Created by Mac-Mini-2021 on 6/11/2024.
//


import UIKit

class ResetPViewController: UIViewController,UITextFieldDelegate {
    
    
    @IBOutlet weak var newpasswordTF: UITextField!
    
    @IBOutlet weak var confirmNewpasswordTF: UITextField!
    var emailSeg : String = ""

    
    override func viewDidLoad() {
        super.viewDidLoad()
               
               
                newpasswordTF.delegate = self
               confirmNewpasswordTF.delegate = self
               
               
           }
           
    @IBAction func saveButton(_ sender: Any) {
        print(emailSeg)

              let parameters: [String: Any] = [
                  "email": emailSeg,
                  "newPassword": newpasswordTF.text!,
              ]
              sendSignupRequest(parameters: parameters)
          }

          // Sends the signup request to the server
          private func sendSignupRequest(parameters: [String: Any]) {
              guard let url = URL(string: "http://172.18.20.186:3001/auth/reset-password") else { return }

              do {
                  let jsonData = try JSONSerialization.data(withJSONObject: parameters, options: [])
                  print("sendSignup", jsonData)

                  var request = URLRequest(url: url)
                  request.httpMethod = "PUT"
                  request.httpBody = jsonData
                  request.setValue("application/json", forHTTPHeaderField: "Content-Type")
                  print(jsonData)
                  let task = URLSession.shared.dataTask(with: request) { data, response, error in
                      if let error = error {
                          print("Error: \(error.localizedDescription)")
                          return
                      }

                      guard let data = data else {
                          print("No data received")
                          return
                      }

                      self.handleResponse(data: data)
                  }

                  // Start the request task
                  task.resume()

              } catch {
                  print("Error serializing JSON: \(error.localizedDescription)")
              }
          }

          // Handles the response from the server
          private func handleResponse(data: Data) {
              if let responseString = String(data: data, encoding: .utf8) {
                  print("Response: \(responseString)")

                  // Attempt to parse the response as JSON
                  if let jsonData = responseString.data(using: .utf8) {
                      do {
                          if let jsonResponse = try JSONSerialization.jsonObject(with: jsonData, options: []) as? [String: Any] {
                              // Check the status code
                              if let statusCode = jsonResponse["statusCode"] as? Int {
                                  // If status code is 200, perform the segue to "home"
                                  print(statusCode)
                                  if statusCode == 200 {
                                      print("Password reset successful")
                                      if let userId = jsonResponse["userId"] as? String {
                                          // Save userId to pass it to the next screen
                                          DispatchQueue.main.async {
                                              self.performSegue(withIdentifier: "home", sender: userId)
                                          }
                                      }
                                  } else if statusCode == 400 || statusCode == 401 {
                                      // Handle invalid input
                                      print("Please enter a valid email.")
                                  } else {
                                      print("Unexpected error: \(statusCode)")
                                  }
                              }
                          }
                      } catch {
                          print("Failed to parse JSON: \(error.localizedDescription)")
                      }
                  }
              }
          }
      }
