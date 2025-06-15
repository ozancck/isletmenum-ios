//
//  Business.swift
//  isletmenum-ios
//
//  Created by Ozan Çiçek on 15.06.2025.
//

import Foundation

struct Business: Codable, Identifiable, Equatable, Hashable {
    let id: Int?
    let name: String
    let description: String
    let type: String
    let logo: String?
    let userId: Int?
    let UserId: Int? // API response'da bu field var
    let createdAt: String?
    let updatedAt: String?
    
    // Equatable için
    static func == (lhs: Business, rhs: Business) -> Bool {
        return lhs.id == rhs.id
    }
    
    // Hashable için
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
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
