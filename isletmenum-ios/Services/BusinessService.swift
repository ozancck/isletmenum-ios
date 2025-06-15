//
//  BusinessService.swift
//  isletmenum-ios
//
//  Created by Ozan Çiçek on 15.06.2025.
//

import Foundation
import UIKit

class BusinessService: ObservableObject {
    static let shared = BusinessService()
    
    @Published var userBusinesses: [Business] = []
    @Published var allBusinesses: [Business] = []
    @Published var hasActiveBusiness = false
    
    private let baseURL = "https://api.isletmenum.com"
    
    private init() {}
    
    func createBusiness(name: String, description: String, type: String, logoImage: UIImage?) async throws -> CreateBusinessResponse {
        guard let token = AuthService.shared.token else {
            throw AuthError.unauthorized
        }
        
        guard let url = URL(string: "\(baseURL)/business/create") else {
            throw URLError(.badURL)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        // Multipart form data oluştur
        let boundary = UUID().uuidString
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        var body = Data()
        
        // Text alanları ekle
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"name\"\r\n\r\n".data(using: .utf8)!)
        body.append("\(name)\r\n".data(using: .utf8)!)
        
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"description\"\r\n\r\n".data(using: .utf8)!)
        body.append("\(description)\r\n".data(using: .utf8)!)
        
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"type\"\r\n\r\n".data(using: .utf8)!)
        body.append("\(type)\r\n".data(using: .utf8)!)
        
        // Logo dosyası ekle
        if let logoImage = logoImage,
           let imageData = logoImage.jpegData(compressionQuality: 0.7) {
            body.append("--\(boundary)\r\n".data(using: .utf8)!)
            body.append("Content-Disposition: form-data; name=\"logo\"; filename=\"logo.jpg\"\r\n".data(using: .utf8)!)
            body.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
            body.append(imageData)
            body.append("\r\n".data(using: .utf8)!)
        }
        
        body.append("--\(boundary)--\r\n".data(using: .utf8)!)
        
        request.httpBody = body
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        // 401 Unauthorized kontrolü
        if let httpResponse = response as? HTTPURLResponse {
            if httpResponse.statusCode == 401 {
                AuthService.shared.handleUnauthorized()
                throw AuthError.unauthorized
            }
        }
        
        let apiResponse = try JSONDecoder().decode(CreateBusinessResponse.self, from: data)
        
        // Başarılı oluşturma sonrası listeyi güncelle
        await MainActor.run {
            self.userBusinesses.append(apiResponse.business)
            self.hasActiveBusiness = true
        }
        
        return apiResponse
    }
    
    func getAllBusinesses() async throws -> [Business] {
        guard let token = AuthService.shared.token else {
            throw AuthError.unauthorized
        }
        
        guard let url = URL(string: "\(baseURL)/business/all") else {
            throw URLError(.badURL)
        }
        
        var request = URLRequest(url: url)
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        // 401 Unauthorized kontrolü
        if let httpResponse = response as? HTTPURLResponse {
            if httpResponse.statusCode == 401 {
                AuthService.shared.handleUnauthorized()
                throw AuthError.unauthorized
            }
        }
        
        let apiResponse = try JSONDecoder().decode(AllBusinessesResponse.self, from: data)
        
        await MainActor.run {
            self.allBusinesses = apiResponse.businesses
        }
        
        return apiResponse.businesses
    }
    
    func getUserBusinesses() async throws -> [Business] {
        guard let token = AuthService.shared.token else {
            throw AuthError.unauthorized
        }
        
        guard let url = URL(string: "\(baseURL)/api/business/user") else {
            throw URLError(.badURL)
        }
        
        var request = URLRequest(url: url)
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        // 401 Unauthorized kontrolü
        if let httpResponse = response as? HTTPURLResponse {
            if httpResponse.statusCode == 401 {
                AuthService.shared.handleUnauthorized()
                throw AuthError.unauthorized
            }
        }
        
        let apiResponse = try JSONDecoder().decode(AllBusinessesResponse.self, from: data)
        
        await MainActor.run {
            self.userBusinesses = apiResponse.businesses
            self.hasActiveBusiness = !apiResponse.businesses.isEmpty
        }
        
        return apiResponse.businesses
    }
    
    func checkUserHasBusiness() async {
        do {
            _ = try await getUserBusinesses()
        } catch {
            await MainActor.run {
                self.hasActiveBusiness = false
            }
        }
    }
}
