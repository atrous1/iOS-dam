//
//  User.swift
//  DAM
//
//  Created by Apple Esprit on 27/11/2024.
//

import Foundation
struct User: Identifiable, Codable {
    var id: String
    var name: String
    var email: String
    var phone: String
    var password: String?
   

    // Initialiseur optionnel pour le décodage
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case name
        case email
        case phone
    }
    
    init(id: String, name: String, email: String, phone: String) {
        self.id = id
        self.name = name
        self.email = email
        self.phone = phone
        
    }
}

func getUserId(completion: @escaping (String?, Error?) -> Void) {
    // Remplacez par l'URL de votre backend
    let url = URL(string: "http://172.18.20.186:3001/profile/id")!
    
    // Créez la requête
    var request = URLRequest(url: url)
    request.httpMethod = "GET"
    
    // Ajoutez le token d'authentification dans l'en-tête
    if let token = UserDefaults.standard.string(forKey: "accessToken") {
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
    }
    
    // Effectuez l'appel réseau
    URLSession.shared.dataTask(with: request) { data, response, error in
        if let error = error {
            completion(nil, error)
            return
        }
        
        guard let data = data else {
            completion(nil, NSError(domain: "Invalid response", code: -1, userInfo: nil))
            return
        }
        
        do {
            let responseJson = try JSONDecoder().decode([String: String].self, from: data)
            if let userId = responseJson["userId"] {
                completion(userId, nil)
            } else {
                completion(nil, NSError(domain: "User ID not found", code: -1, userInfo: nil))
            }
        } catch {
            completion(nil, error)
        }
    }.resume()
}

