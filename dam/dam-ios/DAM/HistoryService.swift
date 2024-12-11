//
//  HistoryService.swift
//  DAM
//
//  Created by Apple Esprit on 11/12/2024.
//

import Foundation


import Foundation

class HistoryService {
   
    private let baseURL = "http://172.18.20.186:3001/history"
   
    // Fonction pour ajouter à l'historique
    func addToHistory(image: String, description: String, accessToken: String, completion: @escaping (Result<AddToHistoryResponse, Error>) -> Void) {
        let url = URL(string: "\(baseURL)/history")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
       
        let body = AddToHistory(image: image, description: description)
        do {
            let jsonData = try JSONEncoder().encode(body)
            request.httpBody = jsonData
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
                let response = try JSONDecoder().decode(AddToHistoryResponse.self, from: data)
                completion(.success(response))
            } catch {
                completion(.failure(error))
            }
        }
        task.resume()
    }
   
    // Fonction pour obtenir l'historique
    func getHistory(accessToken: String, completion: @escaping (Result<[AddToHistoryResponse], Error>) -> Void) {
        let url = URL(string: "\(baseURL)/history")!
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
       
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
                let response = try JSONDecoder().decode([AddToHistoryResponse].self, from: data)
                completion(.success(response))
            } catch {
                completion(.failure(error))
            }
        }
        task.resume()
    }
   
    // Fonction pour obtenir le solde de gemmes
    func getGemBalance(accessToken: String, completion: @escaping (Result<GemBalanceResponse, Error>) -> Void) {
        let url = URL(string: "\(baseURL)/gems")!
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
       
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
                let response = try JSONDecoder().decode(GemBalanceResponse.self, from: data)
                completion(.success(response))
            } catch {
                completion(.failure(error))
            }
        }
        task.resume()
    }
}
