//
//  Manager.swift
//  DAM
//
//  Created by Apple Esprit on 11/12/2024.
//

import Foundation

import Foundation

// Modèle pour l'ajout à l'historique
struct AddToHistory: Codable {
    var image: String
    var description: String
}

// Modèle pour la réponse de l'ajout à l'historique
struct AddToHistoryResponse: Codable {
    var image: String
    var description: String
    var createdAt: String
    var user: String
}

// Modèle pour la réponse d'erreur
struct ErrorResponse: Codable {
    var message: String
    var error: String
    var statusCode: Int
}

// Modèle pour la réponse des points de gemmes
struct GemBalanceResponse: Codable {
    var gemsBalance: Int
}
