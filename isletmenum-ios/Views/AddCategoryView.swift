//
//  AddCategoryView.swift
//  isletmenum-ios
//
//  Created by Ozan Çiçek on 15.06.2025.
//

import SwiftUI

struct AddCategoryView: View {
    @StateObject private var menuService = MenuService.shared
    @State private var categoryName = ""
    @State private var isLoading = false
    @State private var errorMessage = ""
    @State private var showError = false
    @Environment(\.dismiss) private var dismiss
    
    let menuId: Int
    let onCategoryAdded: () -> Void
    
    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                VStack(spacing: 16) {
                    Image(systemName: "folder.badge.plus")
                        .font(.system(size: 60))
                        .foregroundColor(.blue)
                    
                    Text("Yeni Kategori")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    Text("Menünüze yeni bir kategori ekleyin")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding(.top, 20)
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Kategori Adı")
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    TextField("Örn: Ana Yemekler, İçecekler, Tatlılar", text: $categoryName)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .disabled(isLoading)
                }
                .padding(.horizontal, 20)
                
                Spacer()
                
                Button(action: {
                    Task {
                        await createCategory()
                    }
                }) {
                    HStack {
                        if isLoading {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                .scaleEffect(0.8)
                        }
                        
                        Text(isLoading ? "Ekleniyor..." : "Kategori Ekle")
                            .font(.headline)
                            .foregroundColor(.white)
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(
                        categoryName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? Color.gray : Color.blue
                    )
                    .cornerRadius(12)
                }
                .disabled(categoryName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || isLoading)
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
            }
            .navigationTitle("Kategori Ekle")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("İptal") {
                        dismiss()
                    }
                }
            }
        }
        .alert("Hata", isPresented: $showError) {
            Button("Tamam", role: .cancel) { }
        } message: {
            Text(errorMessage)
        }
    }
    
    private func createCategory() async {
        isLoading = true
        errorMessage = ""
        
        do {
            try await menuService.createCategory(
                name: categoryName.trimmingCharacters(in: .whitespacesAndNewlines),
                menuId: menuId
            )
            
            onCategoryAdded()
            dismiss()
            
        } catch {
            errorMessage = "Kategori eklenemedi. Lütfen tekrar deneyin."
            showError = true
            print("Hata: \(error)")
        }
        
        isLoading = false
    }
}

#Preview {
    AddCategoryView(menuId: 1, onCategoryAdded: {})
}
