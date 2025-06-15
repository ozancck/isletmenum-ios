//
//  MenuService.swift
//  isletmenum-ios
//
//  Created by Ozan Çiçek on 15.06.2025.
//

import Foundation
import UIKit

class MenuService: ObservableObject {
    static let shared = MenuService()
    
    @Published var categories: [MenuCategory] = []
    @Published var menuItems: [MenuItem] = []
    @Published var selectedMenuId: Int = 1
    
    private let baseURL = "https://api.isletmenum.com"
    
    private init() {}
    
    // MARK: - Category Operations
    func createCategory(name: String, menuId: Int) async throws -> MenuCategory {
        guard let token = AuthService.shared.token else {
            throw AuthError.unauthorized
        }
        
        guard let url = URL(string: "\(baseURL)/menu/category") else {
            throw URLError(.badURL)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        let createRequest = CreateCategoryRequest(name: name, menuId: menuId)
        request.httpBody = try JSONEncoder().encode(createRequest)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        // 401 Unauthorized kontrolü
        if let httpResponse = response as? HTTPURLResponse {
            if httpResponse.statusCode == 401 {
                AuthService.shared.handleUnauthorized()
                throw AuthError.unauthorized
            }
        }
        
        // API'den tek kategori döndüğünü varsayıyoruz
        let categoryData = try JSONDecoder().decode(MenuCategory.self, from: data)
        
        await MainActor.run {
            self.categories.append(categoryData)
        }
        
        return categoryData
    }
    
    func getCategories(menuId: Int) async throws -> [MenuCategory] {
        guard let token = AuthService.shared.token else {
            throw AuthError.unauthorized
        }
        
        guard let url = URL(string: "\(baseURL)/menu/categories") else {
            throw URLError(.badURL)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        let requestBody = GetCategoriesRequest(menuId: menuId)
        request.httpBody = try JSONEncoder().encode(requestBody)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        // 401 Unauthorized kontrolü
        if let httpResponse = response as? HTTPURLResponse {
            if httpResponse.statusCode == 401 {
                AuthService.shared.handleUnauthorized()
                throw AuthError.unauthorized
            }
        }
        
        let apiResponse = try JSONDecoder().decode(CategoryResponse.self, from: data)
        
        await MainActor.run {
            self.categories = apiResponse.categories
        }
        
        return apiResponse.categories
    }
    
    // MARK: - Menu Item Operations
    func createMenuItem(name: String, description: String, price: Double, volume: String, ingredients: String, menuId: Int, categoryId: Int, image: UIImage?) async throws -> MenuItem {
        guard let token = AuthService.shared.token else {
            throw AuthError.unauthorized
        }
        
        guard let url = URL(string: "\(baseURL)/menu/item") else {
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
        let fields = [
            "name": name,
            "description": description,
            "price": "\(price)",
            "volume": volume,
            "ingredients": ingredients,
            "menuId": "\(menuId)",
            "categoryId": "\(categoryId)"
        ]
        
        for (key, value) in fields {
            body.append("--\(boundary)\r\n".data(using: .utf8)!)
            body.append("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n".data(using: .utf8)!)
            body.append("\(value)\r\n".data(using: .utf8)!)
        }
        
        // Görsel dosyası ekle
        if let image = image,
           let imageData = image.jpegData(compressionQuality: 0.7) {
            body.append("--\(boundary)\r\n".data(using: .utf8)!)
            body.append("Content-Disposition: form-data; name=\"image\"; filename=\"menu_item.jpg\"\r\n".data(using: .utf8)!)
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
        
        // API'den tek item döndüğünü varsayıyoruz
        let menuItem = try JSONDecoder().decode(MenuItem.self, from: data)
        
        await MainActor.run {
            self.menuItems.append(menuItem)
        }
        
        return menuItem
    }
    
    func getMenuItems(menuId: Int) async throws -> (items: [MenuItem], categories: [MenuCategory]) {
        guard let token = AuthService.shared.token else {
            throw AuthError.unauthorized
        }
        
        guard let url = URL(string: "\(baseURL)/menu/\(menuId)/items") else {
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
        
        let apiResponse = try JSONDecoder().decode(MenuItemsResponse.self, from: data)
        
        await MainActor.run {
            self.menuItems = apiResponse.menuItems
            self.categories = apiResponse.categories
        }
        
        return (apiResponse.menuItems, apiResponse.categories)
    }
    
    // MARK: - Helper Methods
    func getItemsForCategory(_ categoryId: Int) -> [MenuItem] {
        return menuItems.filter { $0.MenuCategoryId == categoryId }
    }
    
    func clearData() {
        categories = []
        menuItems = []
    }
}
