//
//  UserDefaults.swift
//  DAM
//
//  Created by Apple Esprit on 11/12/2024.
//

import Foundation


class TokenManager {
    static let shared = TokenManager()
   
    func saveToken(_ token: String) {
        UserDefaults.standard.set(token, forKey: "accessToken")
    }
   
    func getToken() -> String? {
        return UserDefaults.standard.string(forKey: "accessToken")
    }
}
