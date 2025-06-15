//
//  Business.swift
//  isletmenum-ios
//
//  Created by Ozan Çiçek on 15.06.2025.
//

import Foundation

struct Business: Codable {
    let id: Int?
    let name: String
    let description: String
    let type: String
    let logo: String?
    let userId: Int?
    let UserId: Int? // API response'da bu field var
    let createdAt: String?
    let updatedAt: String?
}

struct CreateBusinessRequest: Codable {
    let name: String
    let description: String
    let type: String
    let logo: String?
}

struct CreateBusinessResponse: Codable {
    let message: String
    let business: Business
}

struct AllBusinessesResponse: Codable {
    let message: String
    let businesses: [Business]
}
