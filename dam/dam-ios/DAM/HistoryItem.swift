//
//  HistoryItem.swift
//  DAM
//
//  Created by Apple Esprit on 1/12/2024.
import Foundation

struct HistoryItem: Codable {
    let image: String?  // Peut être nil si l'image n'est pas présente
    let description: String
    let createdAt: String
}
