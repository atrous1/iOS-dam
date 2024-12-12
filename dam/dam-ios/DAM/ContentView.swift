import SwiftUI
import WebKit

struct ContentView: View {
    @State private var selectedImage: UIImage?
    @State private var resultText: String = "Résultat : Aucun"
    @State private var showImagePicker = false
    @State private var isLoading = false
    @State private var gemCount: Int = 10 // Nombre de gems

    var body: some View {
        VStack {
            // Afficher les gems
            Text("\(gemCount)💎")
                .font(.headline)
                .padding()
           
            // WebView pour afficher l'interface de l'IA
            WebView(resultText: $resultText, gemCount: $gemCount)
                .cornerRadius(10)
                .padding()

            if let selectedImage = selectedImage {
                Image(uiImage: selectedImage)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 200, height: 200)
                    .padding()

                // Bouton pour envoyer l'image et le résultat au backend
                Button("Sauvegarder le résultat") {
                    sendHistoryToBackend(image: selectedImage, result: resultText)
                }
                .padding()
            }

            // Bouton pour ouvrir le sélecteur d'image
            Button("Choisir une image") {
                showImagePicker = true
            }
            .padding()
        }
        .sheet(isPresented: $showImagePicker) {
            ImagePicker(selectedImage: $selectedImage)
        }
        .padding()
        .onAppear {
            fetchGemBalance() // Charger le nombre de gems au démarrage
        }
    }
   
    // Fonction pour récupérer le solde des gems depuis le backend
    func fetchGemBalance() {
        guard let accessToken = UserDefaults.standard.string(forKey: "accessToken") else {
            print("Aucun token d'accès trouvé dans UserDefaults.")
            return
        }

        guard let url = URL(string: "http://192.168.1.161:3001/profile/gems") else { return }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Erreur lors de la récupération des gems : \(error.localizedDescription)")
                return
            }

            if let data = data {
                do {
                    if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                       let gems = json["gems"] as? Int {
                        DispatchQueue.main.async {
                            gemCount = gems
                        }
                    }
                } catch {
                    print("Erreur lors du décodage de la réponse des gems : \(error.localizedDescription)")
                }
            }
        }
        task.resume()
    }

    // Fonction pour convertir l'image en base64
    func convertImageToBase64(image: UIImage) -> String? {
        guard let imageData = image.jpegData(compressionQuality: 0.8) else { return nil }
        return imageData.base64EncodedString(options: .lineLength64Characters)
    }

    // Fonction pour envoyer l'image et le résultat au backend
    func sendHistoryToBackend(image: UIImage, result: String) {
        guard let base64Image = convertImageToBase64(image: image) else {
            print("Erreur lors de la conversion de l'image en base64")
            return
        }

        // Récupérer le token d'accès depuis UserDefaults
        guard let accessToken = UserDefaults.standard.string(forKey: "accessToken") else {
            print("Aucun token d'accès trouvé dans UserDefaults.")
            return
        }

        // Créer un objet JSON avec l'image et la description
        let woundHistory: [String: Any] = [
            "image": base64Image,
            "description": result,
            "createdAt": ISO8601DateFormatter().string(from: Date())
        ]

        // Effectuer la requête POST à votre backend
        guard let url = URL(string: "http://172.18.20.186:3001/history") else { return }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")  // Ajouter le token à l'en-tête

        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: woundHistory, options: .prettyPrinted)

            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                if let error = error {
                    print("Erreur lors de l'envoi de l'historique : \(error.localizedDescription)")
                    return
                }

                if let data = data {
                    if let responseString = String(data: data, encoding: .utf8) {
                        print("Réponse du serveur : \(responseString)")
                    }
                }
            }
            task.resume()
        } catch {
            print("Erreur lors de la préparation des données : \(error.localizedDescription)")
        }
    }
}

// WebView pour afficher l'interface Gradio
struct WebView: UIViewRepresentable {
    @Binding var resultText: String
    @Binding var gemCount: Int

    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.navigationDelegate = context.coordinator
        webView.configuration.userContentController.add(context.coordinator, name: "AndroidBridge")

        // Charger l'application Gradio
        if let url = URL(string: "https://mirai310-wound-identifier-2.hf.space") {
            let request = URLRequest(url: url)
            webView.load(request)
        }
        return webView
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {}

    func makeCoordinator() -> Coordinator {
        return Coordinator(self)
    }

    class Coordinator: NSObject, WKNavigationDelegate, WKScriptMessageHandler {
        var parent: WebView

        init(_ parent: WebView) {
            self.parent = parent
        }

        // Réception des messages depuis le JavaScript
        func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
            if message.name == "AndroidBridge", let result = message.body as? String {
                DispatchQueue.main.async {
                    self.parent.resultText = "Résultat : \(result)"
                    self.decrementGemsIfPossible()
                }
            }
        }

        // Décrémenter le nombre de gems
        func decrementGemsIfPossible() {
            guard let accessToken = UserDefaults.standard.string(forKey: "accessToken") else {
                print("Aucun token d'accès trouvé pour décrémenter les gems")
                return
            }

            // Vérifier que le solde des gems est suffisant
            if self.parent.gemCount <= 0 {
                print("Solde de gems insuffisant.")
                return
            }

            // Décrémenter les gems
            let newGemCount = self.parent.gemCount - 1
            let url = URL(string: "http://172.18.20.186:3001/profile/gems")!
            var request = URLRequest(url: url)
            request.httpMethod = "PUT"
            request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")

            // S'assurer que le corps de la requête inclut le champ gemsBalance
            let jsonBody: [String: Any] = [
                "gemsBalance": newGemCount
            ]

            do {
                request.httpBody = try JSONSerialization.data(withJSONObject: jsonBody)

                let task = URLSession.shared.dataTask(with: request) { data, response, error in
                    if let error = error {
                        print("Erreur lors de la mise à jour des gems : \(error.localizedDescription)")
                        return
                    }

                    // Mettre à jour l'état local du solde des gems
                    DispatchQueue.main.async {
                        self.parent.gemCount = newGemCount
                    }
                }
                task.resume()
            } catch {
                print("Erreur lors de la préparation des données : \(error.localizedDescription)")
            }
        }

        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            let script = """
            (function() {
                const observer = new MutationObserver(() => {
                    const resultElement = document.querySelector('.output-class.svelte-1pq4gst');
                    if (resultElement) {
                        const result = resultElement.innerText || resultElement.textContent;
                        window.webkit.messageHandlers.AndroidBridge.postMessage(result);
                    }
                });
                observer.observe(document.body, { childList: true, subtree: true });
            })();
            """
            webView.evaluateJavaScript(script, completionHandler: nil)
        }
    }
}

// ImagePicker pour choisir une image depuis la galerie
struct ImagePicker: UIViewControllerRepresentable {
    @Binding var selectedImage: UIImage?

    func makeCoordinator() -> Coordinator {
        return Coordinator(self)
    }

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = .photoLibrary
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}

    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        var parent: ImagePicker

        init(_ parent: ImagePicker) {
            self.parent = parent
        }

        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
            if let image = info[.originalImage] as? UIImage {
                parent.selectedImage = image
            }
            picker.dismiss(animated: true, completion: nil)
        }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            picker.dismiss(animated: true, completion: nil)
        }
    }
}
