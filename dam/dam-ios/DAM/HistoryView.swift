import SwiftUI
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

        guard let url = URL(string: "http://172.18.20.186:3001/history") else {
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
             // .navigationTitle("Historique")
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
       // .navigationTitle("Détails de l'historique")
        .navigationBarTitleDisplayMode(.inline)
    }
}

//struct HistoryListView_Previews: PreviewProvider {
    //static var previews: some View {
       // HistoryListView()
   // }
//}
