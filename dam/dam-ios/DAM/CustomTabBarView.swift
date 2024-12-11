import SwiftUI

struct CustomTabBarView: View {
    @State private var isLoggedOut = false
    @State private var selectedTab = "Accueil"
    
    var body: some View {
        TabView {
            Text("Accueil")
                .tabItem {
                    Image(systemName: "house")
                    Text("Home")
                }
            ProductListView()
                .tabItem {
                    Image(systemName: "cart")
                    Text("Shop")
                }
            ContentView()
                .tabItem {
                    Image(systemName: "plus.circle.fill")
                    Text("Add")
                }
            
           // use a Navigation view for theHistorique tab
          
           NavigationView {
               HistoryView()
             
           }
            
            .tabItem {
        
                Image(systemName: "clock")
                Text("History")
            }

            ProfileControllerView(isLoggedOut: $isLoggedOut)
                .tabItem {
                    Image(systemName: "person")
                    Text("Profil")
                }
        }
        .navigationTitle(selectedTab)
        .navigationBarTitleDisplayMode(.inline)
        .accentColor(.blue)
    }
}

struct ProfileControllerView: View {
    @State private var userProfile: User?
    @State private var isLoading = true
    @State private var hasError = false
    @Binding var isLoggedOut: Bool
    @State private var isDarkMode = false
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode> // Fix for dismissal
    @Environment(\.colorScheme) var colorScheme // Environment to detect current mode
    
    var body: some View {
        VStack {
            if isLoading {
                ProgressView("Chargement...")
                    .progressViewStyle(CircularProgressViewStyle(tint: .blue))
                    .padding()
            } else if hasError {
                Text("Impossible de charger le profil utilisateur.")
                    .foregroundColor(.red)
                    .padding()
            } else if let profile = userProfile {
                VStack {
                    Image("user") // Replace with your asset
                        .resizable()
                        .scaledToFill()
                        .frame(width: 100, height: 100)
                        .clipShape(Circle())
                        .overlay(Circle().stroke(Color.white, lineWidth: 4))
                        .shadow(radius: 5)

                    Text(profile.name ?? "Nom d'utilisateur")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .padding(.top, 8)
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.blue)
                
                VStack(alignment: .center, spacing: 10) {
                    ProfileDetailRow(icon: "envelope", text: profile.email ?? "Email non disponible")
                    ProfileDetailRow(icon: "phone", text: profile.phone ?? "Téléphone non disponible")
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.white)
                .cornerRadius(12)
                .shadow(radius: 5)
                .padding(.horizontal)
                
                Spacer()

                VStack(spacing: 20) {
                    if let userProfile = userProfile {
                        NavigationLink(destination: EditProfileView(user: userProfile)) {
                            VStack {
                                Text("Edit profil")
                                    .fontWeight(.bold)
                                    .foregroundColor(.blue)
                                    .padding()
                                    .frame(maxWidth: .infinity)
                            }
                            .background(Color.white)
                            .cornerRadius(12)
                            .shadow(color: .gray, radius: 5, x: 0, y: 5)
                        }
                    }
                    
                    Button(action: {
                        isDarkMode.toggle()
                        if isDarkMode {
                            // Get the current window scene and set the interface style to dark mode
                            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
                                windowScene.windows.first?.overrideUserInterfaceStyle = .dark
                            }
                        } else {
                            // Set the interface style to light mode
                            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
                                windowScene.windows.first?.overrideUserInterfaceStyle = .light
                            }
                        }
                    }) {
                        VStack {
                            Text(isDarkMode ? "Switch to Light Mode" : "Switch to Dark Mode")
                                .fontWeight(.bold)
                                .foregroundColor(isDarkMode ? .green : .black)
                                .padding()
                                .frame(maxWidth: .infinity)
                        }
                        .background(Color.white)
                        .cornerRadius(12)
                        .shadow(color: .gray, radius: 5, x: 0, y: 5)
                    }


                    Button(action: {
                        UserDefaults.standard.removeObject(forKey: "accessToken")
                        UserDefaults.standard.removeObject(forKey: "refreshToken")
                        isLoggedOut = true
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        VStack {
                            Text("Déconnexion")
                                .fontWeight(.bold)
                                .foregroundColor(.red)
                                .padding()
                                .frame(maxWidth: .infinity)
                        }
                        .background(Color.white)
                        .cornerRadius(12)
                        .shadow(color: .gray, radius: 5, x: 0, y: 5)
                    }

                    Text("Terms and Conditions")
                        .foregroundColor(.blue)
                        .underline()
                        .onTapGesture {
                            if let url = URL(string: "https://www.freeprivacypolicy.com/live/6bcf6418-363a-4e43-9e76-2a51080fb704") {
                                UIApplication.shared.open(url, options: [:], completionHandler: nil)
                            }
                        }
                        .padding(.top, 20)
                }
            }
        }
        .onAppear {
            fetchUserProfile()
        }
    }

    private func fetchUserProfile() {
        isLoading = true
        hasError = false
        
        guard let url = URL(string: "http://172.18.20.186:3001/profile") else {
            print("URL invalide.")
            hasError = true
            isLoading = false
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        if let token = UserDefaults.standard.string(forKey: "accessToken") {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                isLoading = false
            }
            
            if let error = error {
                print("Erreur lors de la requête : \(error.localizedDescription)")
                DispatchQueue.main.async {
                    hasError = true
                }
                return
            }
            
            guard let data = data else {
                print("Aucune donnée reçue.")
                DispatchQueue.main.async {
                    hasError = true
                }
                return
            }
            
            if let responseString = String(data: data, encoding: .utf8) {
                print("Réponse brute de l'API : \(responseString)")
            }
            
            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode != 200 {
                print("Erreur: Statut HTTP non 200. Code : \(httpResponse.statusCode)")
                DispatchQueue.main.async {
                    hasError = true
                }
                return
            }
            
            do {
                let decodedProfile = try JSONDecoder().decode(User.self, from: data)
                DispatchQueue.main.async {
                    self.userProfile = decodedProfile
                }
            } catch {
                print("Erreur de déchiffrement JSON : \(error.localizedDescription)")
                DispatchQueue.main.async {
                    hasError = true
                }
            }
        }.resume()
    }
}

struct ProfileDetailRow: View {
    let icon: String
    let text: String

    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.blue)
                .frame(width: 24, height: 24)
            Text(text)
                .foregroundColor(.black)
                .padding(.leading, 5)
            Spacer()
        }
        .frame(maxWidth: .infinity, alignment: .center)
        .padding(.vertical, 5)
    }
}


class ProductViewModel: ObservableObject {
    @Published var products: [Product] = []
    func fetchProducts() {
        guard let url = URL(string: "http://172.18.20.186:3001/product") else { return }
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let data = data {
                DispatchQueue.main.async {
                    do {
                        self.products = try JSONDecoder().decode([Product].self, from: data)
                        
                    } catch {
                        print("Erreur de décodage : \(error)")
                        
                    } } }
            else if let error = error {
                print("Erreur réseau : \(error)")
                
            } }.resume()
        
    } }

struct ProductListView: View {
    @StateObject private var viewModel = ProductViewModel()
    private let baseURL = "http://172.18.20.186:3001"

    let columns = [
        GridItem(.flexible(), spacing: 10),
        GridItem(.flexible(), spacing: 10)
    ]

    var body: some View {
        NavigationView {
            ScrollView {
                LazyVGrid(columns: columns, spacing: 15) {
                    ForEach(viewModel.products.indices, id: \.self) { index in
                        let product = viewModel.products[index]
                        VStack(alignment: .leading, spacing: 10) {
                            // Gestion de l'image
                            if let imageData = Data(base64Encoded: product.image),
                               let uiImage = UIImage(data: imageData) {
                                // Image encodée en Base64
                                Image(uiImage: uiImage)
                                    .resizable()
                                    .scaledToFit() // Maintenir le ratio d'aspect
                                    .frame(height: 150) // Limiter la hauteur
                                    .clipped()
                            } else if let imageUrl = URL(string: baseURL + product.image) {
                                // URL relative complétée
                                AsyncImage(url: imageUrl) { image in
                                    image
                                        .resizable()
                                        .scaledToFit() // Maintenir le ratio d'aspect
                                        .frame(height: 150) // Limiter la hauteur
                                        .clipped()
                                } placeholder: {
                                    ProgressView()
                                }
                            } else {
                                // Placeholder si l'image n'est pas valide
                                Rectangle()
                                    .fill(Color.gray.opacity(0.3))
                                    .frame(height: 150)
                                    .overlay(Text("Image indisponible"))
                            }
                            // Nom du produit
                            Text(product.name)
                                .font(.headline)
                                .lineLimit(2)
                            // Prix
                            Text("Prix : \(product.price, specifier: "%.2f") €")
                                .font(.body)
                                .foregroundColor(.green)
                        }
                        .padding()
                        .background(Color.white)
                        .cornerRadius(10)
                        .shadow(radius: 5)
                    }
                }
                .padding()
            }
            //.navigationTitle("Produits")
            .onAppear {
                viewModel.fetchProducts()
            }
        }
    }
}
