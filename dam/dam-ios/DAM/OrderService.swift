// OrderService.swift

import Foundation

class OrderService {
    private let baseURL = "http://172.18.20.186:3001" // Remplace par l'URL de ton backend
    var isLoading: Bool = false  // Ajout de la variable isLoading
       var errorMessage: String?  // Ajout de la variable errorMessage

    
    // Fonction pour créer une commande
    func createOrder(userId: String, productId: String, paymentData: CreatePaymentData, completion: @escaping (Result<OrderResponse, Error>) -> Void) {
        let url = URL(string: "\(baseURL)/orders")!
        
        // Prépare la requête
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Récupérer le token d'authentification depuis UserDefaults
        // Vérifier si le token est dans UserDefaults
        if let token = UserDefaults.standard.string(forKey: "accessToken") {
            print("Token récupéré: \(token)")
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        } else {
            errorMessage = "Token d'authentification non trouvé."
            isLoading = false
            return
        }
        
        // Corps de la requête
        let createOrderRequest = CreateOrderRequest(user: userId, product: productId, paymentData: paymentData)
        
        do {
            request.httpBody = try JSONEncoder().encode(createOrderRequest)
        } catch {
            completion(.failure(error))
            return
        }
        
        // Effectue l'appel réseau
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data, let httpResponse = response as? HTTPURLResponse else {
                completion(.failure(NSError(domain: "Invalid response", code: -1, userInfo: nil)))
                return
            }

            print("HTTP Status Code: \(httpResponse.statusCode)")  // Affichez le code de statut pour déboguer


            // Considérez le succès si le code de statut est supérieur à 200
            guard httpResponse.statusCode > 200 else {
                completion(.failure(NSError(domain: "Invalid response", code: httpResponse.statusCode, userInfo: nil)))
                return
            }

            // Si le code de statut est supérieur à 200, il est considéré comme un succès.
          //  completion(.success(response))  // Assurez-vous que 'response' est bien défini dans votre contexte
            
            do {
                let orderResponse = try JSONDecoder().decode(OrderResponse.self, from: data)
                completion(.success(orderResponse))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
}
