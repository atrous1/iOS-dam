import Foundation

class DoctorAIService {
    func fetchResponse(for query: String, completion: @escaping (String?) -> Void) {
        let apiKey =  "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" // Remplace par ta clé API
        let url = URL(string: "https://api.openai.com/v1/completions")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        let prompt = "Je suis un docteur IA. Répondez précisément à la question suivante : \(query)"
        let body: [String: Any] = [
            "model": "text-davinci-003",
            "prompt": prompt,
            "max_tokens": 150
        ]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)

        URLSession.shared.dataTask(with: request) { data, _, error in
            guard let data = data, error == nil else {
                print("Erreur API : \(error?.localizedDescription ?? "Inconnue")")
                completion(nil)
                return
            }

            let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any]
            let reply = (json?["choices"] as? [[String: Any]])?.first?["text"] as? String
            completion(reply?.trimmingCharacters(in: .whitespacesAndNewlines))
        }.resume()
    }
}
