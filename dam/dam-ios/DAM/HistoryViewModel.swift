//
//  HistoryViewModel.swift
//  DAM
//
//  Created by Apple Esprit on 11/12/2024.
//


import Foundation
import Combine

class HistoryViewModel: ObservableObject {
    
    @Published var historyList: [AddToHistoryResponse] = []
    private var cancellables = Set<AnyCancellable>()
   
    // Fetch token from UserDefaults (or Keychain)
    private func getAccessToken() -> String? {
        let token = UserDefaults.standard.string(forKey: "accessToken")
        print("Access token: \(token ?? "None")")
        return token
    }
   
    // Fetch history from API (GET)
    func getHistory() {
        guard let token = getAccessToken() else {
            print("No access token found")
            return
        }
       
        let url = URL(string: "http://172.18.20.186:3001/history")!
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
       
        URLSession.shared.dataTaskPublisher(for: request)
            .map(\.data)
            .decode(type: [AddToHistoryResponse].self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .failure(let error):
                    print("Failed to fetch history: \(error.localizedDescription)")
                case .finished:
                    print("Successfully fetched history")
                }
            }, receiveValue: { [weak self] history in
                self?.historyList = history
            })
            .store(in: &cancellables)
    }
   
    // Add history item to API (POST)
    func addToHistory(image: String, description: String) {
        guard let token = getAccessToken() else {
            print("No access token found")
            return
        }
       
        let url = URL(string: "http://172.18.20.186:3001/history")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
       
        let historyItem = AddToHistory(image: image, description: description)
       
        do {
            let jsonData = try JSONEncoder().encode(historyItem)
            request.httpBody = jsonData
        } catch {
            print("Error encoding history item: \(error)")
            return
        }
       
        URLSession.shared.dataTaskPublisher(for: request)
            .map(\.data)
            .decode(type: AddToHistoryResponse.self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .failure(let error):
                    print("Failed to add history: \(error.localizedDescription)")
                case .finished:
                    print("Successfully added history item")
                }
            }, receiveValue: { [weak self] newItem in
                self?.historyList.append(newItem)
            })
            .store(in: &cancellables)
    }
}
