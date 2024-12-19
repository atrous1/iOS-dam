import SwiftUI

struct CustomTabBarView: View {
    @State private var isLoggedOut = false
    @State private var selectedTab = "Accueil"
    
    var body: some View {
        TabView {
            NavigationView {
                DoctorAIView()
            }
            .tabItem {
                Image(systemName: "house")
                Text("Home")
            }
          /*  Text("Accueil")
                .tabItem {
                    Image(systemName: "house")
                    Text("Home")
                }*/
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
            
            // Navigation view for the Historique tab
            NavigationView {
                HistoryListView()
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
    @State private var showSettings = false // New state to control settings view
    
    var body: some View {
      
                ZStack {
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
                            .background(Color.green)
                            
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
                        }
                    }

                    // Settings button in bottom left corner
                    VStack {
                        Spacer()
                        HStack {
                            Spacer()
                            Button(action: {
                                showSettings.toggle()
                            }) {
                                Image(systemName: "gearshape.fill")
                                    .font(.title)
                                    .foregroundColor(.green)
                                    .padding()
                                    .background(Color.white)
                                    .clipShape(Circle())
                                    .shadow(radius: 5)
                            }
                            .padding(.bottom, 30)
                            .padding(.trailing, 30)
                        }
                    }

                    // Settings modal
                    if showSettings {
                        VStack {
                            Spacer()
                            VStack(spacing: 20) {
                                // Navigate to Edit Profile
                                if let userProfile = userProfile {
                                    NavigationLink(destination: EditProfileView(user: userProfile)) {
                                        VStack {
                                            Text("Edit profil")
                                                .fontWeight(.bold)
                                                .foregroundColor(.green)
                                                .padding()
                                                .frame(maxWidth: .infinity)
                                        }
                                        .background(Color.white)
                                        .cornerRadius(12)
                                        .shadow(color: .gray, radius: 5, x: 0, y: 5)
                                    }
                                }

                                // Dark Mode toggle button
                                Button(action: {
                                    isDarkMode.toggle()
                                    if isDarkMode {
                                        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
                                            windowScene.windows.first?.overrideUserInterfaceStyle = .dark
                                        }
                                    } else {
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

                                // Log Out button
                                Button(action: {
                                    UserDefaults.standard.removeObject(forKey: "accessToken")
                                    UserDefaults.standard.removeObject(forKey: "refreshToken")
                                    isLoggedOut = true
                                    presentationMode.wrappedValue.dismiss()
                                }) {
                                    VStack {
                                        Text("LOG OUT")
                                            .fontWeight(.bold)
                                            .foregroundColor(.red)
                                            .padding()
                                            .frame(maxWidth: .infinity)
                                    }
                                    .background(Color.white)
                                    .cornerRadius(12)
                                    .shadow(color: .gray, radius: 5, x: 0, y: 5)
                                }

                                // Terms and Conditions link
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
                            .padding()
                            .background(Color(UIColor.systemGray6))
                            .cornerRadius(12)
                            .shadow(radius: 5)
                            .padding(.horizontal)
                            .transition(.move(edge: .leading)) // Slide in from the left
                            .animation(.spring(), value: showSettings)
                        }
                        .background(Color.black.opacity(0.5).onTapGesture {
                            showSettings = false
                        })
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
                .foregroundColor(.green)
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

struct SettingsView: View {
    var body: some View {
        VStack {
            Text("Settings View")
                .font(.largeTitle)
                .padding()
            Spacer()
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(radius: 10)
    }
}
/*
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
                .background(Color.green)
                
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
                                    .foregroundColor(.green)
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
                            Text("LOG OUT")
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
                .foregroundColor(.green)
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
 */
/*
struct PaymentFormView: View {
    let product: Product
    @Binding var isPresented: Bool // Pour contrôler l'affichage de la feuille
    @State private var cardNumber: String = ""
       @State private var expirationDate: String = ""
       @State private var cvc: String = ""
       @State private var country: String = ""
       @State private var zipCode: String = ""
    @State private var isLoading = false
        @State private var showAlert = false
        @State private var alertMessage = ""
    
    let productId = "product_id_example" // Remplace par l'ID du produit
    @State private var userId: String? // Remplace par l'ID de l'utilisateur

    
    var body: some View {
        ZStack {
            Color.white
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                // Bouton pour fermer
                HStack {
                    Spacer()
                    Button(action: {
                        isPresented = false
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .resizable()
                            .frame(width: 30, height: 30)
                            .foregroundColor(.gray)
                    }
                    .padding()
                }

                // Titre
                Text("Buy \(product.name)")
                    .font(.largeTitle)
                                        .fontWeight(.bold)
                                        .padding(.top, 10)


                // Image
                if let imageData = Data(base64Encoded: product.image),
                   let uiImage = UIImage(data: imageData) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFit()
                        .frame(height:120)
                        .cornerRadius(10)
                } else if let imageUrl = URL(string: "http://172.18.20.186:3001" + product.image) {
                    AsyncImage(url: imageUrl) { image in
                        image
                            .resizable()
                            .scaledToFit()
                            .frame(height: 120)
                            .cornerRadius(10)
                    } placeholder: {
                        ProgressView()
                    }
                } else {
                    Rectangle()
                        .fill(Color.gray.opacity(0.3))
                        .frame(height: 120)
                        .cornerRadius(10)
                        .overlay(Text("Image indisponible"))
                }

                // Formulaire de paiement
                Form {
                    Section(header: Text("order details")) {
                        Text("Product: \(product.name)")
                        Text("Price: \(product.price, specifier: "%.2f") TND")
                    }

                    Section(header: Text(" Payment information")) {
                        
                        TextField("Card Number", text: $cardNumber)
                                                   .keyboardType(.numberPad)
                        TextField("Expiration Date (DD/MM)", text: $expirationDate)
                                                   .keyboardType(.numbersAndPunctuation)
                                                   .onChange(of: expirationDate) { newValue in
                                                       expirationDate = formatDateInput(newValue)
                                                   }
                       
                        SecureField("CVC", text: $cvc)
                                                    .keyboardType(.numberPad)
                        TextField("Country", text: $country)
                        TextField("ZIP", text: $zipCode)
                                                    .keyboardType(.numberPad)
                    }

                    Button(action: {
                                           // Récupérer l'ID de l'utilisateur avant de créer la commande
                                           getUserId { userId, error in
                                               if let error = error {
                                                   alertMessage = "Erreur lors de la récupération de l'ID de l'utilisateur: \(error.localizedDescription)"
                                                   showAlert = true
                                               } else if let userId = userId {
                                                   self.userId = userId // Sauvegarde de l'ID utilisateur
                                                   createOrder(userId: userId) // Appel de la fonction pour créer la commande
                                               }
                                           }
                                       }) {
                        if isLoading {
                            ProgressView()
                        }else {
                            Text("Pay now")
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.green)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                       
                    }
                    .disabled(isLoading)
                }
                .padding(.horizontal)
                .alert(isPresented: $showAlert) {
                            Alert(title: Text("Payment Status"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
                        }
            }
           
        }
     
    }
    /// Fonction pour formater l'entrée de la date en "DD/MM"
        private func formatDateInput(_ input: String) -> String {
            // Supprime tous les caractères non numériques
            let digits = input.filter { $0.isNumber }
            
            var result = ""
            
            // Ajoute les séparateurs `/` au bon endroit
            for (index, digit) in digits.enumerated() {
                if index == 2 || index == 4 { // Ajoute un `/` après le jour et le mois
                    result.append("/")
                }
                result.append(digit)
                
                // Limite la longueur à 10 caractères (DD/MM/YYYY)
                if result.count == 10 {
                    break
                }
            }
            
            return result
        }
    private func createOrder(userid: String) {
            isLoading = true

            let paymentData = CreatePaymentData(
                cardNumber: cardNumber,
                expiryDate: expirationDate,  // Corrected variable name
                cvc: cvc,
                country: country,
                zip: zipCode  // Use 'zipCode' instead of 'zip'
            )

            let orderService = OrderService()
            orderService.createOrder(userId: userId, productId: productId, paymentData: paymentData) { result in
                DispatchQueue.main.async {
                    isLoading = false
                    switch result {
                    case .success(let response):
                        alertMessage = "Order created successfully: \(response.id)"
                    case .failure(let error):
                        alertMessage = "Error: \(error.localizedDescription)"
                    }
                    showAlert = true
                }
            }
        }
    // Fonction pour récupérer l'ID de l'utilisateur via une API
        private func getUserId(completion: @escaping (String?, Error?) -> Void) {
            // Remplacez cette partie par un appel réel à votre API pour récupérer l'ID de l'utilisateur
            let apiUrl = "http://votre-api.com/profile/id"
            guard let url = URL(string: apiUrl) else { return }
            
            var request = URLRequest(url: url)
            request.httpMethod = "GET"
            request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization") // Ajoutez un token d'authentification si nécessaire
            
            }
            
            URLSession.shared.dataTask(with: request) { data, response, error in
                if let error = error {
                    completion(nil, error)
                    return
                }
                
                if let data = data, let userId = try? JSONDecoder().decode(UserIdResponse.self, from: data) {
                    completion(userId.userId, nil)
                } else {
                    completion(nil, NSError(domain: "API Error", code: 0, userInfo: [NSLocalizedDescriptionKey: "Failed to decode response"]))
                }
            }.resume()
        }
    }

    struct UserIdResponse: Decodable {
        let userId: String
    }
    }
    */

struct PaymentFormView: View {
    let product: Product
    @Binding var isPresented: Bool // Pour contrôler l'affichage de la feuille
    @State private var cardNumber: String = ""
    @State private var expirationDate: String = ""
    @State private var cvc: String = ""
    @State private var country: String = ""
    @State private var zipCode: String = ""
    @State private var isLoading = false
    @State private var showAlert = false
    @State private var alertMessage = ""
    
    let productId = "product_id_example" // Remplace par l'ID du produit
    @State private var userId: String? // Remplace par l'ID de l'utilisateur

    var body: some View {
        ZStack {
            Color.white
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                // Bouton pour fermer
                HStack {
                    Spacer()
                    Button(action: {
                        isPresented = false
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .resizable()
                            .frame(width: 30, height: 30)
                            .foregroundColor(.gray)
                    }
                    .padding()
                }

                // Titre
                Text("Buy \(product.name)")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.top, 10)

                // Image du produit
                if let imageData = Data(base64Encoded: product.image),
                   let uiImage = UIImage(data: imageData) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFit()
                        .frame(height: 120)
                        .cornerRadius(10)
                } else if let imageUrl = URL(string: "http://172.18.20.186:3001" + product.image) {
                    AsyncImage(url: imageUrl) { image in
                        image
                            .resizable()
                            .scaledToFit()
                            .frame(height: 120)
                            .cornerRadius(10)
                    } placeholder: {
                        ProgressView()
                    }
                } else {
                    Rectangle()
                        .fill(Color.gray.opacity(0.3))
                        .frame(height: 120)
                        .cornerRadius(10)
                        .overlay(Text("Image indisponible"))
                }

                // Formulaire de paiement
                Form {
                    Section(header: Text("Order details")) {
                        Text("Product: \(product.name)")
                        Text("Price: \(product.price, specifier: "%.2f") TND")
                    }

                    Section(header: Text("Payment information")) {
                        TextField("Card Number", text: $cardNumber)
                            .keyboardType(.numberPad)
                        TextField("Expiration Date (DD/MM)", text: $expirationDate)
                            .keyboardType(.numbersAndPunctuation)
                            .onChange(of: expirationDate) { newValue in
                                expirationDate = formatDateInput(newValue)
                            }
                        SecureField("CVC", text: $cvc)
                            .keyboardType(.numberPad)
                        TextField("Country", text: $country)
                        TextField("ZIP", text: $zipCode)
                            .keyboardType(.numberPad)
                    }

                    Button(action: {
                        // Récupérer l'ID de l'utilisateur avant de créer la commande
                        getUserId { userId, error in
                            if let error = error {
                                alertMessage = "Erreur lors de la récupération de l'ID de l'utilisateur: \(error.localizedDescription)"
                                showAlert = true
                            } else if let userId = userId {
                                self.userId = userId // Sauvegarde de l'ID utilisateur
                                createOrder(userId: userId) // Appel de la fonction pour créer la commande
                            }
                        }
                    }) {
                        if isLoading {
                            ProgressView()
                        } else {
                            Text("Pay now")
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.green)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                    }
                    .disabled(isLoading)
                }
                .padding(.horizontal)
                .alert(isPresented: $showAlert) {
                    Alert(title: Text("Payment Status"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
                }
            }
        }
    }

    // Fonction pour formater l'entrée de la date en "DD/MM"
    private func formatDateInput(_ input: String) -> String {
        // Supprime tous les caractères non numériques
        let digits = input.filter { $0.isNumber }
        
        var result = ""
        
        // Ajoute les séparateurs `/` au bon endroit
        for (index, digit) in digits.enumerated() {
            if index == 2 || index == 4 { // Ajoute un `/` après le jour et le mois
                result.append("/")
            }
            result.append(digit)
            
            // Limite la longueur à 5 caractères (DD/MM)
            if result.count == 5 {
                break
            }
        }
        
        return result
    }

    // Fonction pour créer la commande
    private func createOrder(userId: String) {
        isLoading = true

        let paymentData = CreatePaymentData(
            cardNumber: cardNumber,
            expiryDate: expirationDate,
            cvc: cvc,
            country: country,
            zip: zipCode
        )

        let orderService = OrderService()
        orderService.createOrder(userId: userId, productId: productId, paymentData: paymentData) { result in
            DispatchQueue.main.async {
                isLoading = false
                switch result {
                case .success(let response):
                    alertMessage = "Order created successfully: \(response.id)"
                case .failure(let error):
                    alertMessage = "Error: \(error.localizedDescription)"
                }
                showAlert = true
            }
        }
    }

    // Fonction pour récupérer l'ID de l'utilisateur via une API
    private func getUserId(completion: @escaping (String?, Error?) -> Void) {
        // Remplacez cette partie par un appel réel à votre API pour récupérer l'ID de l'utilisateur
        let apiUrl = "http://172.18.20.186:3001/profile/id"
        guard let url = URL(string: apiUrl) else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
      //request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization") // Ajoutez un token d'authentification si nécessaire
        if let token = UserDefaults.standard.string(forKey: "accessToken") {
            print("Token récupéré: \(token)")
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        } else {
            //errorMessage = "Token d'authentification non trouvé."
           // isLoading = false
            print("erreur")
            return
        }
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(nil, error)
                return
            }
            
            if let data = data, let userId = try? JSONDecoder().decode(UserIdResponse.self, from: data) {
                completion(userId.userId, nil)
            } else {
                completion(nil, NSError(domain: "API Error", code: 0, userInfo: [NSLocalizedDescriptionKey: "Failed to decode response"]))
            }
        }.resume()
    }
}

struct UserIdResponse: Decodable {
    let userId: String
}


/*
struct PaymentFormView: View {
    let product: Product
    @Binding var isPresented: Bool // Pour contrôler l'affichage de la feuille
    @State private var cardNumber: String = ""
    @State private var expirationDate: String = ""
    @State private var cvc: String = ""
    @State private var country: String = ""
    @State private var zipCode: String = ""
    @State private var isLoading = false
    @State private var showAlert = false
    @State private var alertMessage = ""
    
    @State private var userId: String? // Remplace par l'ID de l'utilisateur
    
    var body: some View {
        ZStack {
            Color.white
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                // Bouton pour fermer
                HStack {
                    Spacer()
                    Button(action: {
                        isPresented = false
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .resizable()
                            .frame(width: 30, height: 30)
                            .foregroundColor(.gray)
                    }
                    .padding()
                }

                // Titre
                Text("Buy \(product.name)")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.top, 10)

                // Image du produit
                if let imageData = Data(base64Encoded: product.image),
                   let uiImage = UIImage(data: imageData) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFit()
                        .frame(height: 120)
                        .cornerRadius(10)
                } else if let imageUrl = URL(string: "http://172.18.20.186:3001" + product.image) {
                    AsyncImage(url: imageUrl) { image in
                        image
                            .resizable()
                            .scaledToFit()
                            .frame(height: 120)
                            .cornerRadius(10)
                    } placeholder: {
                        ProgressView()
                    }
                } else {
                    Rectangle()
                        .fill(Color.gray.opacity(0.3))
                        .frame(height: 120)
                        .cornerRadius(10)
                        .overlay(Text("Image indisponible"))
                }

                // Formulaire de paiement
                Form {
                    Section(header: Text("Order details")) {
                        Text("Product: \(product.name)")
                        Text("Price: \(product.price, specifier: "%.2f") TND")
                    }

                    Section(header: Text("Payment information")) {
                        TextField("Card Number", text: $cardNumber)
                            .keyboardType(.numberPad)
                        TextField("Expiration Date (DD/MM)", text: $expirationDate)
                            .keyboardType(.numbersAndPunctuation)
                            .onChange(of: expirationDate) { newValue in
                                expirationDate = formatDateInput(newValue)
                            }
                        SecureField("CVC", text: $cvc)
                            .keyboardType(.numberPad)
                        TextField("Country", text: $country)
                        TextField("ZIP", text: $zipCode)
                            .keyboardType(.numberPad)
                    }

                    Button(action: {
                        // Récupérer l'ID de l'utilisateur avant de créer la commande
                        getUserId { userId, error in
                            if let error = error {
                                alertMessage = "Erreur lors de la récupération de l'ID de l'utilisateur: \(error.localizedDescription)"
                                showAlert = true
                            } else if let userId = userId {
                                self.userId = userId // Sauvegarde de l'ID utilisateur
                                createOrder(userId: userId
                                            , productId: product.id) // Appel de la fonction pour créer la commande avec l'ID du produit
                            }
                        }
                    }) {
                        if isLoading {
                            ProgressView()
                        } else {
                            Text("Pay now")
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.green)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                    }
                    .disabled(isLoading)
                }
                .padding(.horizontal)
                .alert(isPresented: $showAlert) {
                    Alert(title: Text("Payment Status"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
                }
            }
        }
    }

    // Fonction pour formater l'entrée de la date en "DD/MM"
    private func formatDateInput(_ input: String) -> String {
        // Supprime tous les caractères non numériques
        let digits = input.filter { $0.isNumber }
        
        var result = ""
        
        // Ajoute les séparateurs `/` au bon endroit
        for (index, digit) in digits.enumerated() {
            if index == 2 || index == 4 { // Ajoute un `/` après le jour et le mois
                result.append("/")
            }
            result.append(digit)
            
            // Limite la longueur à 5 caractères (DD/MM)
            if result.count == 5 {
                break
            }
        }
        
        return result
    }

    // Fonction pour créer la commande
    private func createOrder(userId: String, productId: String) {
        isLoading = true

        let paymentData = CreatePaymentData(
            cardNumber: cardNumber,
            expiryDate: expirationDate,
            cvc: cvc,
            country: country,
            zip: zipCode
        )

        let orderService = OrderService()
        orderService.createOrder(userId: userId, productId: productId, paymentData: paymentData) { result in
            DispatchQueue.main.async {
                isLoading = false
                switch result {
                case .success(let response):
                    alertMessage = "Order created successfully: \(response.id)"
                case .failure(let error):
                    alertMessage = "Error: \(error.localizedDescription)"
                }
                showAlert = true
            }
        }
    }

    // Fonction pour récupérer l'ID de l'utilisateur via une API
    private func getUserId(completion: @escaping (String?, Error?) -> Void) {
        let apiUrl = "http://172.18.20.186:3001/profile/id"
        guard let url = URL(string: apiUrl) else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        if let token = UserDefaults.standard.string(forKey: "accessToken") {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        } else {
            return
        }
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(nil, error)
                return
            }
            
            if let data = data, let userId = try? JSONDecoder().decode(UserIdResponse.self, from: data) {
                completion(userId.userId, nil)
            } else {
                completion(nil, NSError(domain: "API Error", code: 0, userInfo: [NSLocalizedDescriptionKey: "Failed to decode response"]))
            }
        }.resume()
    }
}

struct UserIdResponse: Decodable {
    let userId: String
}
*/
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
    @State private var selectedProduct: Product? // Produit sélectionné pour le paiement
    @State private var isPaymentSheetPresented = false // Contrôle de l'affichage de la feuille

    let columns = [
        GridItem(.flexible(), spacing: 15),
        GridItem(.flexible(), spacing: 15)
    ]
   
    let cardHeight: CGFloat = 230 // Hauteur fixe des cartes
    let cardWidth: CGFloat = 140   // Largeur fixe des cartes
    let spacing: CGFloat = 15     // Espacement entre les cartes

    var body: some View {
        NavigationView {
            ScrollView {
                LazyVGrid(columns: columns, spacing: spacing) {
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
                                    .frame(width: cardWidth, height: 130) // Limiter la hauteur
                                    .clipped()
                            } else if let imageUrl = URL(string: baseURL + product.image) {
                                // URL relative complétée
                                AsyncImage(url: imageUrl) { image in
                                    image
                                        .resizable()
                                        .scaledToFit() // Maintenir le ratio d'aspect
                                        .frame(width: cardWidth, height: 90) // Limiter la hauteur
                                        .clipped()
                                } placeholder: {
                                    ProgressView()
                                }
                            } else {
                                // Placeholder si l'image n'est pas valide
                                Rectangle()
                                    .fill(Color.gray.opacity(0.3))
                                    .frame(width: cardWidth, height: 130) // Fixer la taille
                                    .overlay(Text("Image indisponible"))
                            }
                           
                            // Nom du produit
                            Text(product.name)
                                .font(.headline)
                                .lineLimit(2)
                                .frame(width: cardWidth, alignment: .leading)
                           
                            // Prix
                            Text("Prix : \(product.price, specifier: "%.2f") TND")
                                .font(.body)
                                .foregroundColor(.green)
                                .frame(width: cardWidth, alignment: .leading)
                            
                            Button(action: {
                                selectedProduct = product
                                isPaymentSheetPresented = true
                            }) {
                                Text("Buy")
                                    .frame(width: cardWidth - 20, height: 40)
                                    .background(Color.green)
                                    .foregroundColor(.white)
                                    .cornerRadius(8)
                                    .padding(.top, 5)
                            }
                        }
                        .padding([.leading, .trailing], spacing) // Espacement horizontal sur chaque carte
                        .padding([.top, .bottom], spacing) // Espacement vertical sur chaque carte
                        .background(Color.white)
                        .cornerRadius(10)
                        .shadow(radius: 5)
                        .frame(width: cardWidth, height: cardHeight) // Fixer la taille des cartes
                    }
                }
                .padding(.horizontal, spacing) // Espacement horizontal autour de la grille
                .padding(.top, spacing) // Espacement en haut de la grille
                .padding(.bottom, spacing) // Espacement en bas de la grille
            }
            .onAppear {
                viewModel.fetchProducts()
            }
            .sheet(isPresented: $isPaymentSheetPresented) {
                if let product = selectedProduct {
                    PaymentFormView(product: product, isPresented: $isPaymentSheetPresented)
                }
            }
        }
    }
}
