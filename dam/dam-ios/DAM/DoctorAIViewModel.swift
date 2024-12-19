import Foundation
import Speech
import AVFoundation
import UIKit

class DoctorAIViewModel: ObservableObject {
    @Published var message: String = "Appuyez sur le micro pour poser une question médicale."
    @Published var isListening: Bool = false
    @Published var isLoading: Bool = false

    private let speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "fr-FR"))
    private let audioEngine = AVAudioEngine()
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private let synthesizer = AVSpeechSynthesizer()

    private let doctorAIService = DoctorAIService()

    // Demander l'autorisation pour la reconnaissance vocale
    func requestSpeechAuthorization(from viewController: UIViewController) {
        SFSpeechRecognizer.requestAuthorization { status in
            DispatchQueue.main.async {
                switch status {
                case .authorized:
                    print("Autorisation accordée pour la reconnaissance vocale.")
                case .denied:
                    self.message = "Autorisation refusée. Activez la reconnaissance vocale dans les réglages."
                    self.showAuthorizationAlert(from: viewController, message: "L'autorisation a été refusée. Vous devez activer la reconnaissance vocale dans les réglages de l'appareil.")
                case .restricted:
                    self.message = "La reconnaissance vocale est restreinte sur cet appareil."
                    self.showAuthorizationAlert(from: viewController, message: "La reconnaissance vocale est restreinte sur cet appareil.")
                case .notDetermined:
                    self.message = "Autorisation non déterminée."
                    self.showAuthorizationAlert(from: viewController, message: "L'autorisation pour la reconnaissance vocale n'a pas encore été demandée.")
                @unknown default:
                    self.message = "Erreur inconnue d'autorisation."
                    self.showAuthorizationAlert(from: viewController, message: "Une erreur inconnue est survenue.")
                }
            }
        }
    }

    // Afficher une alerte pour l'autorisation vocale
    private func showAuthorizationAlert(from viewController: UIViewController, message: String) {
        let alertController = UIAlertController(title: "Permission Requise", message: message, preferredStyle: .alert)
        
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        
        // Ajout d'un bouton pour ouvrir les réglages si l'autorisation a été refusée
        if !message.contains("n'a pas encore été demandée") {
            alertController.addAction(UIAlertAction(title: "Ouvrir Réglages", style: .default, handler: { _ in
                if let settingsURL = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(settingsURL, options: [:], completionHandler: nil)
                }
            }))
        }

        viewController.present(alertController, animated: true, completion: nil)
    }

    // Démarrer ou arrêter l'écoute
    func toggleSpeechRecognition() {
        if isListening {
            stopSpeechRecognition()
        } else {
            startSpeechRecognition()
        }
    }

    private func startSpeechRecognition() {
        isListening = true
        message = "Écoute en cours..."

        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        let node = audioEngine.inputNode
        let recordingFormat = node.outputFormat(forBus: 0)
        
        // Vérification du format audio
        guard recordingFormat.sampleRate > 0 && recordingFormat.channelCount > 0 else {
            print("Format audio invalide : SampleRate ou ChannelCount incorrect.")
            message = "Erreur audio. Veuillez réessayer."
            stopSpeechRecognition()
            return
        }
        
        // Si sur le simulateur, on peut essayer de forcer un format compatible
        if TARGET_OS_SIMULATOR != 0 {
            let modifiedFormat = AVAudioFormat(standardFormatWithSampleRate: 44100, channels: 1)
            node.installTap(onBus: 0, bufferSize: 1024, format: modifiedFormat) { buffer, _ in
                self.recognitionRequest?.append(buffer)
            }
        } else {
            // Utilisation du format audio standard sur un appareil réel
            node.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { buffer, _ in
                self.recognitionRequest?.append(buffer)
            }
        }

        audioEngine.prepare()
        do {
            try audioEngine.start()
        } catch {
            print("Erreur de démarrage de l'audio : \(error.localizedDescription)")
            message = "Erreur audio. Veuillez réessayer."
            stopSpeechRecognition()
            return
        }

        recognitionTask = speechRecognizer?.recognitionTask(with: recognitionRequest!) { result, error in
            if let result = result {
                let text = result.bestTranscription.formattedString
                self.message = "Vous : \(text)"
                
                if result.isFinal {
                    self.stopSpeechRecognition()
                    self.handleEmergencyCall(for: text)
                    self.fetchDoctorAIResponse(for: text)
                }
            } else if let error = error {
                print("Erreur de reconnaissance : \(error.localizedDescription)")
                self.message = "Erreur d'écoute. Réessayez."
                self.stopSpeechRecognition()
            }
        }
    }

    private func stopSpeechRecognition() {
        audioEngine.stop()
        audioEngine.inputNode.removeTap(onBus: 0)
        recognitionRequest = nil
        recognitionTask?.cancel()
        isListening = false
    }

    // Détection de la commande d'urgence
    private func handleEmergencyCall(for input: String) {
        let normalizedInput = input.lowercased()
        if normalizedInput.contains("appeler secours") || normalizedInput.contains("appel secours") {
            callEmergencyNumber()
        }
    }

    private func callEmergencyNumber() {
        guard let url = URL(string: "tel://190") else { return }
        DispatchQueue.main.async {
            if UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            } else {
                self.message = "Erreur : Impossible d'appeler le 190."
            }
        }
    }

    // Appel à l'API pour obtenir une réponse
    private func fetchDoctorAIResponse(for input: String) {
        isLoading = true
        doctorAIService.fetchResponse(for: input) { [weak self] response in
            DispatchQueue.main.async {
                self?.isLoading = false
                guard let reply = response else {
                    self?.message = "Erreur du Docteur IA. Réessayez."
                    return
                }
                self?.message = "Docteur IA : \(reply)"
                self?.speak(reply)
            }
        }
    }

    private func speak(_ text: String) {
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(language: "fr-FR")
        synthesizer.speak(utterance)
    }
}
