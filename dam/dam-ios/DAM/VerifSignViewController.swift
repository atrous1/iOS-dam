//
//  VerifSignViewController.swift
//  DAM
//
//  Created by Apple Esprit on 28/11/2024.
//

import UIKit

class VerifSignViewController: UIViewController {
    var email:String?
    
    @IBOutlet weak var verif: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    @IBAction func continueAction(_ sender: Any) {
        
        // Vérifier si le champ du code de vérification n'est pas vide
        guard let verificationCode = verif.text, !verificationCode.isEmpty else {
            showAlert(title: "Erreur", message: "Veuillez entrer le code de vérification.")
            return
        }
        
        // Vérifier si l'email est présent
        guard let email = email else {
            showAlert(title: "Erreur", message: "Email manquant.")
            return
        }
        
        // Préparer les paramètres pour la requête API
        let parameters: [String: Any] = [
            "email": email,
            "recoveryCode": verificationCode
        ]
        
        // Envoyer la requête au backend pour vérifier le code
        verifyCode(parameters: parameters)
    }
    
    // Fonction pour afficher une alerte
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    // Fonction pour envoyer la requête API de vérification
    private func verifyCode(parameters: [String: Any]) {
        guard let url = URL(string: "http://172.18.20.186:3001/auth/verify-signup") else { return }
        
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: parameters, options: [])
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.httpBody = jsonData
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            
            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                if let error = error {
                    print("Erreur: \(error.localizedDescription)")
                    return
                }
                
                guard let data = data else {
                    print("Pas de données reçues")
                    return
                }
                
                self.handleVerificationResponse(data: data)
            }
            
            task.resume()
        } catch {
            print("Erreur lors de la sérialisation JSON: \(error.localizedDescription)")
        }
    }
    
    // Gérer la réponse de l'API après la vérification du code
    private func handleVerificationResponse(data: Data) {
        if let responseString = String(data: data, encoding: .utf8) {
            print("Réponse brute : \(responseString)") // Affiche la réponse brute
            
            if let jsonData = responseString.data(using: .utf8) {
                do {
                    if let jsonResponse = try JSONSerialization.jsonObject(with: jsonData, options: []) as? [String: Any] {
                        print("Réponse JSON : \(jsonResponse)") // Affiche la réponse JSON complète
                        
                        // Vérifiez si la réponse contient un message de succès
                        if let message = jsonResponse["message"] as? String {
                            DispatchQueue.main.async {
                                if message.contains("Compte vérifié avec succès") {
                                    print("Code de vérification correct")
                                    self.performSegue(withIdentifier: "homeSeg", sender: self)
                                } else {
                                    self.showAlert(title: "Échec", message: message)
                                }
                            }
                        } else {
                            print("Message manquant dans la réponse.")
                            DispatchQueue.main.async {
                                self.showAlert(title: "Erreur", message: "Réponse inattendue du serveur.")
                            }
                        }
                    }
                } catch {
                    print("Erreur lors de la lecture des données JSON: \(error.localizedDescription)")
                    DispatchQueue.main.async {
                        self.showAlert(title: "Erreur", message: "Impossible de lire la réponse du serveur.")
                    }
                }
            }
        }
    }
}
