//
//  payment.swift
//  DAM
//
//  Created by Apple Esprit on 17/12/2024.
//

import Foundation

struct CreatePaymentData: Codable {
    let cardNumber: String
    let expiryDate: String
    let cvc: String
    let country: String
    let zip: String
}

struct CreateOrderRequest: Codable {
    let user: String // ID de l'utilisateur
    let product: String // ID du produit
    let paymentData: CreatePaymentData
}

struct OrderResponse: Codable {
    let id: String
    let user: String
    let product: String
    let paymentData: CreatePaymentData
    let orderDate: String
    let status: String
}
