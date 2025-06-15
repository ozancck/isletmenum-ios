//
//  CategoryDetailView.swift
//  isletmenum-ios
//
//  Created by Ozan Çiçek on 15.06.2025.
//

import SwiftUI

struct CategoryDetailView: View {
    @StateObject private var menuService = MenuService.shared
    @State private var showAddItem = false
    @State private var isLoading = false
    
    let category: MenuCategory
    let menuId: Int
    
    private var categoryItems: [MenuItem] {
        menuService.getItemsForCategory(category.id)
    }
    
    var body: some View {
        VStack {
            if isLoading {
                VStack(spacing: 16) {
                    ProgressView()
                        .scaleEffect(1.2)
                    Text("Yükleniyor...")
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if categoryItems.isEmpty {
                // Boş durum
                VStack(spacing: 20) {
                    Image(systemName: "list.bullet.rectangle")
                        .font(.system(size: 60))
                        .foregroundColor(.gray)
                    
                    Text("Henüz Ürün Yok")
                        .font(.title2)
                        .fontWeight(.semibold)
                    
                    Text("Bu kategoriye ilk ürününüzü ekleyin")
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                    
                    Button("Ürün Ekle") {
                        showAddItem = true
                    }
                    .buttonStyle(.borderedProminent)
                }
                .padding()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                List {
                    ForEach(categoryItems) { item in
                        MenuItemRowView(item: item)
                    }
                }
                .listStyle(InsetGroupedListStyle())
            }
        }
        .navigationTitle(category.name)
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    showAddItem = true
                }) {
                    Image(systemName: "plus")
                }
            }
        }
        .sheet(isPresented: $showAddItem) {
            AddMenuItemView(
                menuId: menuId,
                categoryId: category.id,
                categoryName: category.name
            ) {
                Task {
                    await loadMenuItems()
                }
            }
        }
        .onAppear {
            Task {
                await loadMenuItems()
            }
        }
    }
    
    private func loadMenuItems() async {
        isLoading = true
        do {
            _ = try await menuService.getMenuItems(menuId: menuId)
        } catch {
            print("Hata: \(error)")
        }
        isLoading = false
    }
}

struct MenuItemRowView: View {
    let item: MenuItem
    
    var body: some View {
        HStack(spacing: 12) {
            // Ürün görseli
            if let imageUrl = item.imageUrl, !imageUrl.isEmpty {
                AsyncImage(url: URL(string: imageUrl)) { image in
                    image
                        .resizable()
                        .scaledToFill()
                } placeholder: {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.gray.opacity(0.2))
                        .overlay(
                            Image(systemName: "photo")
                                .foregroundColor(.gray)
                        )
                }
                .frame(width: 60, height: 60)
                .clipShape(RoundedRectangle(cornerRadius: 8))
            } else {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.blue.opacity(0.1))
                    .frame(width: 60, height: 60)
                    .overlay(
                        Image(systemName: "fork.knife")
                            .foregroundColor(.blue)
                    )
            }
            
            // Ürün bilgileri
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(item.name)
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Spacer()
                    
                    Text("₺\(item.price, specifier: "%.2f")")
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.blue)
                }
                
                Text(item.description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
                
                HStack {
                    if let volume = item.volume, !volume.isEmpty {
                        Label(volume, systemImage: "scalemass")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    if let ingredients = item.ingredients, !ingredients.isEmpty {
                        Text(ingredients)
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .lineLimit(1)
                    }
                }
            }
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    NavigationView {
        CategoryDetailView(
            category: MenuCategory(
                id: 1,
                name: "Ana Yemekler",
                createdAt: nil,
                updatedAt: nil,
                MenuId: 1
            ),
            menuId: 1
        )
    }
}
