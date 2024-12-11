//
//  LoginViewController.swift
//  DAM
//
//  Created by Mac-Mini-2021 on 6/11/2024.
//

import UIKit


    class LoginViewController: UIViewController {

        // IBOutlet pour le champ Password (assure-toi que cet IBOutlet est bien relié dans le storyboard)
        @IBOutlet weak var Password: UITextField!
        @IBOutlet weak var Email: UITextField!
        
        override func viewDidLoad() {
            
            // Ajouter un bouton pour basculer la visibilité du mot de passe
                   let toggleButton = UIButton(type: .system)
                   toggleButton.setImage(UIImage(systemName: "eye.slash"), for: .normal)
                   toggleButton.addTarget(self, action: #selector(togglePasswordVisibility), for: .touchUpInside)
                   Password.rightView = toggleButton
                   Password.rightViewMode = .always
                   Password.isSecureTextEntry = true // Masquer le mot de passe par défaut
        }
        
       

             
        @IBAction func Login(_ sender: Any) {
            
            guard let emailO = Email.text, !emailO.isEmpty,
                       let passwordO = Password.text, !passwordO.isEmpty else {
                     showAlert(title: "Missing Information", message: "Please fill all the fields.")
                     return
                 }

                 // Paramètres pour la requête
                 let parameters: [String: Any] = [
                     "email": emailO,
                     "password": passwordO
                 ]

                 // Lancer la requête
                 sendSignupRequest(parameters: parameters)
             }

             // Afficher une alerte
             func showAlert(title: String, message: String) {
                 let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
                 alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                 self.present(alert, animated: true, completion: nil)
             }

             // Action pour basculer la visibilité du mot de passe
             @objc private func togglePasswordVisibility() {
                 Password.isSecureTextEntry.toggle()
                 if let button = Password.rightView as? UIButton {
                     let buttonImageName = Password.isSecureTextEntry ? "eye.slash" : "eye"
                     button.setImage(UIImage(systemName: buttonImageName), for: .normal)
                 }
        }
        
       

        private func sendSignupRequest(parameters: [String: Any]) {
               guard let url = URL(string: "http://172.18.20.186:3001/auth/login") else { return }

               do {
                   let jsonData = try JSONSerialization.data(withJSONObject: parameters, options: [])
                   var request = URLRequest(url: url)
                   request.httpMethod = "POST"
                   request.httpBody = jsonData
                   request.setValue("application/json", forHTTPHeaderField: "Content-Type")

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

                   task.resume()
               } catch {
                   print("Error serializing JSON: \(error.localizedDescription)")
               }
           }

           // Gérer la réponse du serveur
        private func handleResponse(data: Data) {
            // Ensure this runs on the main thread for UI updates
            DispatchQueue.main.async {
                if let responseString = String(data: data, encoding: .utf8) {
                    print("Response: \(responseString)")

                    // Parse the response JSON
                    if let jsonData = responseString.data(using: .utf8) {
                        do {
                            if let jsonResponse = try JSONSerialization.jsonObject(with: jsonData, options: []) as? [String: Any],
                               let statusCode = jsonResponse["statusCode"] as? Int {
                                print(statusCode)
                                // Handle the status code and perform segue on success
                                if statusCode < 300 {
                                    // Login successful
                                    print("Login successful")

                                    // If the email is valid, perform segue
                                    if let email = self.Email.text {
                                        self.performSegue(withIdentifier: "logSeg", sender: email)
                                    } else {
                                        self.showAlert(title: "Error", message: "Email not found.")
                                    }
                                } else if statusCode == 400 || statusCode == 401 {
                                    self.showAlert(title: "Login Failed", message: "Invalid email or password.")
                                }
                            }
                        } catch {
                            print("Failed to parse JSON: \(error.localizedDescription)")
                        }
                    }
                }
            }
        }

           // Préparer la transition (segue)
        override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
            if segue.identifier == "logSeg",
               let destinationVC = segue.destination as? VerifLogViewController,
               let email = sender as? String {
                destinationVC.email = email // L'email est envoyé à la page suivante
            }
        }

       }
