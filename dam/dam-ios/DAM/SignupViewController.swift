//
//  SignupViewController.swift
//  DAM
//
//  Created by Mac-Mini-2021 on 6/11/2024.
//

import UIKit

class SignupViewController: UIViewController {

    @IBOutlet weak var name: UITextField!
    @IBOutlet weak var PasswordSU: UITextField!
    
    @IBOutlet weak var phoneNumber: UITextField!
    @IBOutlet weak var mail: UITextField!
    
    @IBAction func signUp(_ sender: Any) {
        // Récupérer les valeurs des champs de texte
              guard let nameS = name.text, !nameS.isEmpty,
                    let emailS = mail.text, !emailS.isEmpty,
                    let passwordSUS = PasswordSU.text, !passwordSUS.isEmpty,
                    let phoneNumberS = phoneNumber.text, !phoneNumberS.isEmpty else {
                  showAlert(title: "Missing Information", message: "Please fill all the fields.")
                  return
              }

              // Préparer les paramètres pour la requête d'inscription
              let parameters: [String: Any] = [
                  "username": nameS,
                  "email": emailS,
                  "password": passwordSUS,
                  "phone": phoneNumberS
              ]

              // Envoyer la requête d'inscription
              sendSignupRequest(parameters: parameters)
          }

          // MARK: - Lifecycle Methods
          override func viewDidLoad() {
              super.viewDidLoad()

              // Ajouter des icônes aux champs de texte
              addIconToTextField(name, iconName: "person.fill")
              addIconToTextField(mail, iconName: "envelope.fill")
              addIconToTextField(PasswordSU, iconName: "lock.fill")
              addIconToTextField(phoneNumber, iconName: "phone.fill")

              // Ajouter un bouton de visibilité pour le mot de passe
              setupPasswordToggleButton()
          }

          // MARK: - Helper Methods
          private func showAlert(title: String, message: String, completion: ((UIAlertAction) -> Void)? = nil) {
              let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
              alert.addAction(UIAlertAction(title: "OK", style: .default, handler: completion))
              self.present(alert, animated: true)
          }

          private func addIconToTextField(_ textField: UITextField, iconName: String) {
              if let icon = UIImage(systemName: iconName) {
                  let iconView = UIImageView(image: icon)
                  iconView.contentMode = .scaleAspectFit
                  iconView.tintColor = UIColor.darkGray
                  iconView.frame = CGRect(x: 0, y: 0, width: 24, height: 24)
                  textField.leftView = iconView
                  textField.leftViewMode = .always
              }
          }

          private func setupPasswordToggleButton() {
              let toggleButton = UIButton(type: .system)
              toggleButton.setImage(UIImage(systemName: "eye.slash"), for: .normal)
              toggleButton.addTarget(self, action: #selector(togglePasswordVisibility), for: .touchUpInside)
              PasswordSU.rightView = toggleButton
              PasswordSU.rightViewMode = .always
              PasswordSU.isSecureTextEntry = true
          }

          @objc private func togglePasswordVisibility() {
              PasswordSU.isSecureTextEntry.toggle()
              if let button = PasswordSU.rightView as? UIButton {
                  let buttonImageName = PasswordSU.isSecureTextEntry ? "eye.slash" : "eye"
                  button.setImage(UIImage(systemName: buttonImageName), for: .normal)
              }
          }

          // MARK: - Network Methods
          private func sendSignupRequest(parameters: [String: Any]) {
              guard let url = URL(string: "http://172.18.20.186:3001/auth/signup") else { return }

              do {
                  let jsonData = try JSONSerialization.data(withJSONObject: parameters, options: [])
                  var request = URLRequest(url: url)
                  request.httpMethod = "POST"
                  request.httpBody = jsonData
                  request.setValue("application/json", forHTTPHeaderField: "Content-Type")

                  let task = URLSession.shared.dataTask(with: request) { data, response, error in
                      if let error = error {
                          print("Error: \(error.localizedDescription)")
                          DispatchQueue.main.async {
                              self.showAlert(title: "Error", message: "Failed to sign up. Please try again.")
                          }
                          return
                      }

                      guard let data = data else {
                          DispatchQueue.main.async {
                              self.showAlert(title: "Error", message: "No response from server.")
                          }
                          return
                      }

                      self.handleResponse(data: data)
                  }

                  task.resume()
              } catch {
                  print("Error serializing JSON: \(error.localizedDescription)")
                  showAlert(title: "Error", message: "Failed to process your request.")
              }
          }

          private func handleResponse(data: Data) {
              do {
                  if let jsonResponse = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                     let statusCode = jsonResponse["statusCode"] as? Int {
                      DispatchQueue.main.async {
                          if statusCode >= 200 {
                              self.showAlert(title: "Success", message: "Signup successful.") { _ in
                                  self.performSegue(withIdentifier: "verSeg", sender: self.mail.text)
                              }
                          } else if statusCode == 400 || statusCode == 401 {
                              self.showAlert(title: "Signup Failed", message: "Email already in use or invalid data.")
                          } else {
                              self.showAlert(title: "Error", message: "Unexpected error occurred.")
                          }
                      }
                  }
              } catch {
                  print("Failed to parse JSON: \(error.localizedDescription)")
                  DispatchQueue.main.async {
                      self.showAlert(title: "Error", message: "Invalid response from server.")
                  }
              }
          }

          // MARK: - Navigation
          override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
              if segue.identifier == "verSeg",
                 let destinationVC = segue.destination as? VerifSignViewController,
                 let email = sender as? String {
                  destinationVC.email = email
              }
          }
      }
