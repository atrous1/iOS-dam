/*import SwiftUI
import Foundation

// ViewModel pour gérer l'historique
class HistoryViewModel: ObservableObject {
    @Published var historyItems: [HistoryItem] = []
    @Published var isLoading: Bool = true  // Ajout d'un indicateur de chargement

    // Fonction pour récupérer les éléments de l'historique
    func fetchHistory() {
        guard let accessToken = UserDefaults.standard.string(forKey: "accessToken") else {
            print("Aucun jeton d'accès trouvé.")
            return
        }

        guard let url = URL(string: "http:/172.18.20.186:3001/history") else {
            print("URL invalide.")
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let data = data {
                DispatchQueue.main.async {
                    do {
                        let decoder = JSONDecoder()
                        self.historyItems = try decoder.decode([HistoryItem].self, from: data)
                        self.isLoading = false  // Stopper l'indicateur de chargement
                    } catch {
                        print("Erreur lors du décodage : \(error)")
                        self.isLoading = false
                    }
                }
            } else if let error = error {
                print("Erreur réseau : \(error)")
                self.isLoading = false
            }
        }.resume()
    }
}

// Vue de la liste d'historique
struct HistoryListView: View {
    @StateObject private var viewModel = HistoryViewModel()

    func decodeBase64ToImage(base64String: String) -> Image? {
        guard !base64String.isEmpty else {
            return nil
        }
        
        // Nettoyage de la chaîne Base64
        let cleanedBase64String = base64String.replacingOccurrences(of: "\n", with: "").replacingOccurrences(of: "\r", with: "")
        
        if let data = Data(base64Encoded: cleanedBase64String),
           let uiImage = UIImage(data: data) {
            return Image(uiImage: uiImage)
        }
        
        return nil
    }

    var body: some View {
          NavigationView {
              VStack {
                  if viewModel.isLoading {
                      // Affichage de l'indicateur de chargement
                      ProgressView("Chargement...")
                          .progressViewStyle(CircularProgressViewStyle(tint: .blue))
                          .scaleEffect(1.5)
                          .padding()
                  } else {
                      ScrollView {
                          LazyVStack(spacing: 15) {
                              ForEach(viewModel.historyItems.indices, id: \.self) { index in
                                  let historyItem = viewModel.historyItems[index]
                                  
                                  NavigationLink(destination: HistoryDetailView(historyItem: historyItem)) {
                                      HStack(alignment: .top, spacing: 15) {
                                          // Affichage de l'image
                                          if let imageBase64 = historyItem.image,
                                             let image = decodeBase64ToImage(base64String: imageBase64) {
                                              image
                                                  .resizable()
                                                  .scaledToFit()
                                                  .frame(width: 100, height: 100)
                                                  .clipShape(Circle())
                                                  .shadow(radius: 10)
                                                  .overlay(Circle().stroke(Color.blue, lineWidth: 2))
                                          } else {
                                              Rectangle()
                                                  .fill(Color.gray.opacity(0.3))
                                                  .frame(width: 100, height: 100)
                                                  .overlay(Text("Image indisponible").foregroundColor(.white))
                                          }

                                          // Description de l'historique à droite de l'image
                                          VStack(alignment: .leading, spacing: 10) {
                                              Text(historyItem.description)
                                                  .font(.headline)
                                                  .lineLimit(2)
                                                  .foregroundColor(.primary)

                                              // Date de l'historique
                                              Text("Date : \(historyItem.createdAt)")
                                                  .font(.subheadline)
                                                  .foregroundColor(.gray)
                                          }
                                          .padding(.leading, 10)
                                      }
                                      .padding()
                                      .background(Color.white)
                                      .cornerRadius(12)
                                      .shadow(radius: 5)
                                      .padding(.horizontal)
                                  }
                              }
                          }
                          .padding(.top)
                      }
                  }
              }
              //.navigationTitle("Historique")
              .navigationBarTitleDisplayMode(.inline)
              .onAppear {
                  viewModel.fetchHistory()
              }
          }
      }
  }

struct HistoryDetailView: View {
    let historyItem: HistoryItem

    func decodeBase64ToImage(base64String: String) -> Image? {
        guard !base64String.isEmpty else {
            return nil
        }
        
        // Nettoyage de la chaîne Base64
        let cleanedBase64String = base64String.replacingOccurrences(of: "\n", with: "").replacingOccurrences(of: "\r", with: "")
        
        if let data = Data(base64Encoded: cleanedBase64String),
           let uiImage = UIImage(data: data) {
            return Image(uiImage: uiImage)
        }
        
        return nil
    }

    var body: some View {
        ScrollView { // Utilisation de ScrollView pour faire défiler le contenu si nécessaire
            VStack(spacing: 20) {
                // Affichage de l'image
                if let imageBase64 = historyItem.image,
                   let image = decodeBase64ToImage(base64String: imageBase64) {
                    image
                        .resizable()
                        .scaledToFit()
                        .frame(width: 300, height: 300)
                        .clipShape(Circle())
                        .shadow(radius: 10)
                } else {
                    Rectangle()
                        .fill(Color.gray.opacity(0.3))
                        .frame(width: 300, height: 300)
                        .overlay(Text("Image indisponible").foregroundColor(.white))
                }

                // Description complète de l'historique
                Text(historyItem.description) // Affiche la description complète
                    .font(.title2)
                    .foregroundColor(.primary)
                    .padding(.horizontal) // Ajout de padding horizontal pour une meilleure lisibilité
                    .fixedSize(horizontal: false, vertical: true) // Permet de laisser la description occuper plusieurs lignes

                // Date de l'historique
                Text("Date : \(historyItem.createdAt)")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .padding(.horizontal)

                Spacer()
            }
            .padding() // Ajout de padding autour de tout le contenu
        }
        .navigationTitle("Détails de l'historique")
        .navigationBarTitleDisplayMode(.inline)
    }
}

*/
/*
import SwiftUI
import Foundation
import Combine

// Modèle pour représenter une entrée de l'historique
struct WoundHistory: Decodable, Identifiable {
    let id: String
    let result: String
    let date: String
}

// ViewModel pour gérer l'affichage de l'historique
class HistoryViewModel: ObservableObject {
    @Published var histories: [WoundHistory] = [] // Liste des entrées d'historique
    @Published var isLoading = false // Indicateur de chargement
    @Published var errorMessage: String? // Message d'erreur
   
    private let apiURL = "http://172.18.20.186:3001/history"
    private var cancellables = Set<AnyCancellable>() // Pour gérer les abonnements Combine
   
    // Méthode pour charger les données d'historique
    func fetchHistory() {
        guard let url = URL(string: apiURL) else {
            self.errorMessage = "URL invalide"
            return
        }
       
        isLoading = true
        errorMessage = nil
       
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
       
        // Ajout d'un token d'authentification si nécessaire
        if let token = UserDefaults.standard.string(forKey: "authToken") {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }else {
            self.errorMessage = "Token d'authentification Manquant"
            return
        }
       
        URLSession.shared.dataTaskPublisher(for: request)
            .tryMap { output in
                guard let response = output.response as? HTTPURLResponse, response.statusCode == 200 else {
                    throw URLError(.badServerResponse)
                }
                return output.data
            }
            .decode(type: [WoundHistory].self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                self.isLoading = false
                switch completion {
                case .failure(let error):
                    self.errorMessage = "Erreur : \(error.localizedDescription)"
                case .finished:
                    break
                }
            }, receiveValue: { [weak self] histories in
                self?.histories = histories
            })
            .store(in: &cancellables)
    }
}

struct HistoryView: View {
    @StateObject private var viewModel = HistoryViewModel()
   
    var body: some View {
        NavigationView {
            Group {
               // if viewModel.isLoading {
                   // ProgressView("Chargement...")
               // } else if let errorMessage = viewModel.errorMessage {
                    //Text("Erreur : \(errorMessage)")
                     //   .foregroundColor(.red)
              //  } else
            if viewModel.histories.isEmpty {
                    Text("Aucun historique disponible")
                        .foregroundColor(.gray)
                } else {
                    List(viewModel.histories) { history in
                        VStack(alignment: .leading) {
                            Text(history.result)
                                .font(.headline)
                            Text(history.date)
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                    }
                }
            }
          
            .onAppear {
                viewModel.fetchHistory()
            }
        }
    }
}

*/

import SwiftUI

struct HistoryView: View {
    @StateObject private var viewModel = HistoryViewModel()
    @State private var image: String = ""
    @State private var description: String = ""
   
    var body: some View {
        NavigationView {
            VStack {
                List(viewModel.historyList, id: \.createdAt) { item in
                    VStack(alignment: .leading) {
                        Text(item.description)
                            .font(.headline)
                        Text("User: \(item.user)")
                            .font(.subheadline)
                        Text("Date: \(item.createdAt)")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                }
               
                // Form to add new history item
               
                .padding()
            }
            .navigationTitle("History")
            .onAppear {
                viewModel.getHistory()
            }
        }
    }
}
