//
//  AuthService.swift
//  isletmenum-ios
//
//  Created by Ozan Çiçek on 15.06.2025.
//

import Foundation

class AuthService: ObservableObject {
    static let shared = AuthService()
    
    @Published var isAuthenticated = false
    @Published var currentUser: User?
    @Published var token: String?
    
    private let baseURL = "https://api.isletmenum.com"
    
    private init() {
        // Kayıtlı token varsa yükle
        loadToken()
    }
    
    func login(email: String, password: String) async throws -> LoginResponse {
        guard let url = URL(string: "\(baseURL)/auth/login") else {
            throw URLError(.badURL)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let loginRequest = LoginRequest(email: email, password: password)
        request.httpBody = try JSONEncoder().encode(loginRequest)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        // HTTP response kodunu kontrol et
        if let httpResponse = response as? HTTPURLResponse {
            if httpResponse.statusCode == 401 {
                throw AuthError.unauthorized
            }
        }
        
        let loginResponse = try JSONDecoder().decode(LoginResponse.self, from: data)
        
        // Başarılı login sonrası token ve user bilgilerini kaydet
        await MainActor.run {
            self.token = loginResponse.token
            self.currentUser = loginResponse.user
            self.isAuthenticated = true
        }
        
        // Token'ı UserDefaults'a kaydet
        UserDefaults.standard.set(loginResponse.token, forKey: "auth_token")
        
        return loginResponse
    }
    
    func logout() {
        token = nil
        currentUser = nil
        isAuthenticated = false
        UserDefaults.standard.removeObject(forKey: "auth_token")
        
        // İşletme servisini de sıfırla
        BusinessService.shared.userBusinesses = []
        BusinessService.shared.allBusinesses = []
        BusinessService.shared.hasActiveBusiness = false
        
        // Menü servisini de sıfırla
        MenuService.shared.clearData()
    }
    
    func handleUnauthorized() {
        DispatchQueue.main.async {
            self.logout()
        }
    }
    
    private func loadToken() {
        if let savedToken = UserDefaults.standard.string(forKey: "auth_token") {
            token = savedToken
            // Token geçerliliğini kontrol etmeden önce authenticated olarak işaretle
            // Eğer token geçersizse API çağrıları 401 döndürür ve otomatik logout olur
            isAuthenticated = true
        }
    }
}

enum AuthError: Error {
    case unauthorized
    case invalidCredentials
    case networkError
}
