//
//  DoctorAIView.swift
//  DAM
//
//  Created by Apple Esprit on 18/12/2024.
//



import SwiftUI
import Speech
import AVFoundation

struct DoctorAIView: View {
    @StateObject private var viewModel = DoctorAIViewModel()

    var body: some View {
        VStack(spacing: 20) {
            // Titre principal
            Text("Docteur IA")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(.teal)
            
            // Zone d'affichage des messages
            ScrollView {
                Text(viewModel.message)
                    .font(.body)
                    .padding()
                    .frame(maxWidth: .infinity, minHeight: 200)
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                    .shadow(radius: 3)
            }
            .frame(maxHeight: 300)
            
            if viewModel.isLoading {
                ProgressView("Analyse en cours...")
                    .progressViewStyle(CircularProgressViewStyle())
            }
            
            Spacer()
            
            // Bouton pour activer la reconnaissance vocale
            Button(action: {
                viewModel.toggleSpeechRecognition()
            }) {
                Image(systemName: viewModel.isListening ? "waveform.circle.fill" : "mic.circle.fill")
                    .resizable()
                    .frame(width: 80, height: 80)
                    .padding()
                    .foregroundColor(viewModel.isListening ? .red : .blue)
                    .shadow(radius: 5)
            }
            
            // Texte indicatif
            Text(viewModel.isListening ? "Parlez, je vous écoute..." : "Appuyez pour poser une question")
                .font(.footnote)
                .foregroundColor(.gray)
        }
        .padding()
        .onAppear {
            viewModel.requestSpeechAuthorization(from: UIApplication.shared.windows.first!.rootViewController!)
        }

    }
}




