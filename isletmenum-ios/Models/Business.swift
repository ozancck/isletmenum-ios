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

struct BusinessListResponse: Codable {
    let businesses: [Business]
}
