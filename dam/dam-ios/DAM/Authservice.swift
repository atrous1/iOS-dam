//
//  Authservice.swift
//  DAM
//
//  Created by Apple Esprit on 11/12/2024.
//

import Foundation

import Foundation

class AuthService {
   
    private let baseURL = "http://172.18.20.186:3001/auth" // Remplacez par l'URL de votre API d'authentification
   
    // Fonction pour se connecter et récupérer le token
    func login(username: String, password: String, completion: @escaping (Result<String, Error>) -> Void) {
        let url = URL(string: "\(baseURL)/login")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
       
        // Ajout des paramètres de connexion (exemple)
        let body: [String: Any] = ["username": username, "password": password]
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: body)
            request.httpBody = jsonData
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        } catch {
            completion(.failure(error))
            return
        }
       
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
           
            guard let data = data else {
                completion(.failure(NSError(domain: "No data", code: 0, userInfo: nil)))
                return
            }
           
            do {
                // Supposons que la réponse de l'API contient un champ `token`
                let responseObject = try JSONDecoder().decode([String: String].self, from: data)
                if let token = responseObject["token"] {
                    completion(.success(token))
                } else {
                    completion(.failure(NSError(domain: "Invalid response", code: 0, userInfo: nil)))
                }
            } catch {
                completion(.failure(error))
            }
        }
       
        task.resume()
    }
}
