//
//  User.swift
//  isletmenum-ios
//
//  Created by Ozan Çiçek on 15.06.2025.
//

import Foundation

struct User: Codable {
    let id: Int
    let email: String
    let firstName: String
    let lastName: String
}

struct LoginResponse: Codable {
    let message: String
    let user: User
    let token: String
}

struct LoginRequest: Codable {
    let email: String
    let password: String
}
