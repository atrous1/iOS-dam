import SwiftUI

struct EditProfileView: View {
    @State var user: User
    @State private var name = ""
    @State private var email = ""
    @State private var phone = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var errorMessage: String?
    @State private var isLoading = false
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("EDIT PROFIL")
                    .font(.title)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                    .padding(.top)
                
                VStack(spacing: 15) {
                    // Nom
                    TextField("Name", text: $name)
                        .padding()
                        .background(RoundedRectangle(cornerRadius: 10).strokeBorder(Color.gray, lineWidth: 1))
                        .padding(.horizontal)
                        .onAppear { name = user.name ?? "" }
                    
                    // Email
                    TextField("Email", text: $email)
                        .padding()
                        .background(RoundedRectangle(cornerRadius: 10).strokeBorder(Color.gray, lineWidth: 1))
                        .padding(.horizontal)
                        .onAppear { email = user.email ?? "" }
                    
                    // Téléphone
                    TextField("Phone Number", text: $phone)
                        .padding()
                        .background(RoundedRectangle(cornerRadius: 10).strokeBorder(Color.gray, lineWidth: 1))
                        .padding(.horizontal)
                        .onAppear { phone = user.phone ?? "" }
                    
                    // Mot de passe
                    SecureField("New password", text: $password)
                        .padding()
                        .background(RoundedRectangle(cornerRadius: 10).strokeBorder(Color.gray, lineWidth: 1))
                        .padding(.horizontal)
                    
                    SecureField("Confirm new password", text: $confirmPassword)
                        .padding()
                        .background(RoundedRectangle(cornerRadius: 10).strokeBorder(Color.gray, lineWidth: 1))
                        .padding(.horizontal)
                    
                    // Error message
                    if let errorMessage = errorMessage {
                        Text(errorMessage)
                            .foregroundColor(.red)
                            .font(.caption)
                            .padding(.horizontal)
                    }
                    
                    // Bouton de sauvegarde
                    Button(action: saveProfile) {
                        HStack {
                            if isLoading {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle())
                                    .frame(width: 20, height: 20)
                            } else {
                                Text("Save")
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                                    .padding()
                                    .frame(maxWidth: .infinity)
                                    .background(Capsule().fill(Color.blue))
                                    .padding(.horizontal)
                            }
                        }
                    }
                    .disabled(isLoading)  // Disable the button during loading
                    
                }
                .padding(.top)
            }
            .padding(.bottom)
        }
        .background(Color(UIColor.systemBackground))
        //.navigationTitle("Modifier le profil")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            name = user.name ?? ""
            email = user.email ?? ""
            phone = user.phone ?? ""
        }
    }
    
    private func saveProfile() {
        isLoading = true
        errorMessage = nil
        
        // Vérification des champs
        guard !name.isEmpty, !email.isEmpty, !phone.isEmpty else {
            errorMessage = "Tous les champs doivent être remplis."
            isLoading = false
            return
        }
        
        if password != confirmPassword {
            errorMessage = "Les mots de passe ne correspondent pas."
            isLoading = false
            return
        }
        
        // Créer le dictionnaire des données à envoyer
        var profileData = [
            "name": name,
            "email": email,
            "phone": phone
        ]
        
        if !password.isEmpty {
            profileData["password"] = password
        }
        
        updateProfile(with: profileData)
    }
    
    private func updateProfile(with data: [String: String]) {
        guard let url = URL(string: "http://172.18.20.186:3001/profile") else {
            errorMessage = "URL invalide."
            isLoading = false
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Vérifier si le token est dans UserDefaults
        if let token = UserDefaults.standard.string(forKey: "accessToken") {
            print("Token récupéré: \(token)")
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        } else {
            errorMessage = "Token d'authentification non trouvé."
            isLoading = false
            return
        }

        // Encoder les données en JSON
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: data, options: .prettyPrinted)
            request.httpBody = jsonData
        } catch {
            DispatchQueue.main.async {
                errorMessage = "Erreur lors de l'encodage des données : \(error.localizedDescription)"
                isLoading = false
            }
            return
        }
        
        // Effectuer la requête
        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                isLoading = false
            }
            
            if let error = error {
                DispatchQueue.main.async {
                    errorMessage = "Erreur lors de la mise à jour du profil : \(error.localizedDescription)"
                }
                return
            }
            
            guard let data = data else {
                DispatchQueue.main.async {
                    errorMessage = "Aucune donnée reçue."
                }
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse {
                DispatchQueue.main.async {
                    print("Réponse HTTP : \(httpResponse.statusCode)")
                    if let responseBody = String(data: data, encoding: .utf8) {
                        print("Réponse brute : \(responseBody)")
                    }
                    
                    switch httpResponse.statusCode {
                    case 200...299:
                        user.name = name
                        user.phone = phone
                        presentationMode.wrappedValue.dismiss()
                    case 400:
                        errorMessage = "Données invalides. Vérifiez votre entrée."
                    case 500:
                        errorMessage = "Erreur serveur. Réessayez plus tard."
                    default:
                        errorMessage = "Erreur inconnue (code : \(httpResponse.statusCode))"
                    }
                }
            }
        }.resume()
    }
}
