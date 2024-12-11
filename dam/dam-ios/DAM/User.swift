//
//  User.swift
//  DAM
//
//  Created by Apple Esprit on 27/11/2024.
//

import Foundation
struct User: Identifiable, Codable {
    var id: String
    var name: String
    var email: String
    var phone: String
    var password: String?

    // Initialiseur optionnel pour le décodage
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case name
        case email
        case phone
    }
    
    init(id: String, name: String, email: String, phone: String) {
        self.id = id
        self.name = name
        self.email = email
        self.phone = phone
        
    }
}

