//
//  Menu.swift
//  isletmenum-ios
//
//  Created by Ozan Çiçek on 15.06.2025.
//

import Foundation

// MARK: - Category Models
struct MenuCategory: Codable, Identifiable, Equatable, Hashable {
    let id: Int
    let name: String
    let createdAt: String?
    let updatedAt: String?
    let MenuId: Int
    
    // Equatable için
    static func == (lhs: MenuCategory, rhs: MenuCategory) -> Bool {
        return lhs.id == rhs.id
    }
    
    // Hashable için
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

struct CreateCategoryRequest: Codable {
    let name: String
    let menuId: Int
}

struct CategoryResponse: Codable {
    let message: String
    let categories: [MenuCategory]
}

// MARK: - Menu Item Models
struct MenuItem: Codable, Identifiable, Equatable, Hashable {
    let id: Int
    let name: String
    let description: String
    let price: Double
    let imageUrl: String?
    let volume: String?
    let ingredients: String?
    let createdAt: String?
    let updatedAt: String?
    let MenuId: Int
    let MenuCategoryId: Int
    
    // Equatable için
    static func == (lhs: MenuItem, rhs: MenuItem) -> Bool {
        return lhs.id == rhs.id
    }
    
    // Hashable için
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

struct CreateMenuItemRequest: Codable {
    let name: String
    let description: String
    let price: Double
    let volume: String
    let ingredients: String
    let menuId: Int
    let categoryId: Int
    let image: String
}

struct MenuItemsResponse: Codable {
    let message: String
    let menuItems: [MenuItem]
    let categories: [MenuCategory]
}

struct GetCategoriesRequest: Codable {
    let menuId: Int
}
