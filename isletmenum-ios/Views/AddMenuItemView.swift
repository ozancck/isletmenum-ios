//
//  AddMenuItemView.swift
//  isletmenum-ios
//
//  Created by Ozan Çiçek on 15.06.2025.
//

import SwiftUI

struct AddMenuItemView: View {
    @StateObject private var menuService = MenuService.shared
    @State private var itemName = ""
    @State private var itemDescription = ""
    @State private var itemPrice = ""
    @State private var itemVolume = ""
    @State private var itemIngredients = ""
    @State private var selectedImage: UIImage?
    @State private var showImagePicker = false
    @State private var showPhotosPicker = false
    @State private var showImageSourceOptions = false
    @State private var isLoading = false
    @State private var errorMessage = ""
    @State private var showError = false
    @Environment(\.dismiss) private var dismiss
    
    let menuId: Int
    let categoryId: Int
    let categoryName: String
    let onItemAdded: () -> Void
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    VStack(spacing: 12) {
                        Image(systemName: "plus.app")
                            .font(.system(size: 50))
                            .foregroundColor(.blue)
                        
                        Text("Yeni Menü Öğesi")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        Text(categoryName)
                            .font(.subheadline)
                            .foregroundColor(.blue)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(
                                Capsule()
                                    .fill(Color.blue.opacity(0.1))
                            )
                    }
                    .padding(.top, 20)
                    
                    // Form
                    VStack(spacing: 20) {
                        // Ürün Adı
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Ürün Adı")
                                .font(.headline)
                                .foregroundColor(.primary)
                            
                            TextField("Örn: Urfa Kebap", text: $itemName)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .disabled(isLoading)
                        }
                        
                        // Açıklama
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Açıklama")
                                .font(.headline)
                                .foregroundColor(.primary)
                            
                            TextField("Örn: Taze kebap", text: $itemDescription)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .disabled(isLoading)
                        }
                        
                        // Fiyat ve Hacim
                        HStack(spacing: 16) {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Fiyat (TL)")
                                    .font(.headline)
                                    .foregroundColor(.primary)
                                
                                TextField("259.50", text: $itemPrice)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                    .keyboardType(.decimalPad)
                                    .disabled(isLoading)
                            }
                            
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Hacim/Porsiyon")
                                    .font(.headline)
                                    .foregroundColor(.primary)
                                
                                TextField("200gr", text: $itemVolume)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                    .disabled(isLoading)
                            }
                        }
                        
                        // Malzemeler
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Malzemeler")
                                .font(.headline)
                                .foregroundColor(.primary)
                            
                            TextField("Örn: Kıyma, Biber, Soğan", text: $itemIngredients)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .disabled(isLoading)
                        }
                        
                        // Görsel Seçimi
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Ürün Görseli")
                                .font(.headline)
                                .foregroundColor(.primary)
                            
                            Button(action: {
                                showImageSourceOptions = true
                            }) {
                                HStack {
                                    if let selectedImage = selectedImage {
                                        Image(uiImage: selectedImage)
                                            .resizable()
                                            .scaledToFill()
                                            .frame(width: 60, height: 60)
                                            .clipped()
                                            .cornerRadius(8)
                                    } else {
                                        RoundedRectangle(cornerRadius: 8)
                                            .fill(Color.gray.opacity(0.2))
                                            .frame(width: 60, height: 60)
                                            .overlay(
                                                VStack(spacing: 4) {
                                                    Image(systemName: "photo.badge.plus")
                                                        .font(.title2)
                                                        .foregroundColor(.blue)
                                                    Text("Görsel")
                                                        .font(.caption2)
                                                        .foregroundColor(.blue)
                                                }
                                            )
                                    }
                                    
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(selectedImage != nil ? "Görsel seçildi" : "Ürün görseli seçin")
                                            .font(.subheadline)
                                            .foregroundColor(selectedImage != nil ? .green : .primary)
                                        
                                        Text("Galeriden veya kameradan seçin")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                    
                                    Spacer()
                                    
                                    Image(systemName: "chevron.right")
                                        .foregroundColor(.gray)
                                }
                                .padding()
                                .background(Color.gray.opacity(0.1))
                                .cornerRadius(10)
                            }
                            .disabled(isLoading)
                        }
                    }
                    .padding(.horizontal, 20)
                    
                    // Kaydet Butonu
                    Button(action: {
                        Task {
                            await createMenuItem()
                        }
                    }) {
                        HStack {
                            if isLoading {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                    .scaleEffect(0.8)
                            }
                            
                            Text(isLoading ? "Ekleniyor..." : "Menü Öğesi Ekle")
                                .font(.headline)
                                .foregroundColor(.white)
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(
                            isFormValid ? Color.blue : Color.gray
                        )
                        .cornerRadius(12)
                    }
                    .disabled(!isFormValid || isLoading)
                    .padding(.horizontal, 20)
                    .padding(.bottom, 20)
                }
            }
            .navigationTitle("Öğe Ekle")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("İptal") {
                        dismiss()
                    }
                }
            }
        }
        .actionSheet(isPresented: $showImageSourceOptions) {
            ActionSheet(
                title: Text("Ürün Görseli Seçin"),
                message: Text("Nereden görsel seçmek istiyorsunuz?"),
                buttons: [
                    .default(Text("Fotoğraf Galerisi")) {
                        showPhotosPicker = true
                    },
                    .default(Text("Kamera")) {
                        showImagePicker = true
                    },
                    .cancel(Text("İptal"))
                ]
            )
        }
        .sheet(isPresented: $showImagePicker) {
            ImagePicker(selectedImage: $selectedImage)
        }
        .sheet(isPresented: $showPhotosPicker) {
            PhotosPicker(selectedImage: $selectedImage)
        }
        .alert("Hata", isPresented: $showError) {
            Button("Tamam", role: .cancel) { }
        } message: {
            Text(errorMessage)
        }
    }
    
    private var isFormValid: Bool {
        !itemName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !itemDescription.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !itemPrice.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !itemVolume.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !itemIngredients.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        selectedImage != nil
    }
    
    private func createMenuItem() async {
        isLoading = true
        errorMessage = ""
        
        guard let priceDouble = Double(itemPrice.trimmingCharacters(in: .whitespacesAndNewlines)) else {
            errorMessage = "Geçerli bir fiyat girin."
            showError = true
            isLoading = false
            return
        }
        
        do {
            try await menuService.createMenuItem(
                name: itemName.trimmingCharacters(in: .whitespacesAndNewlines),
                description: itemDescription.trimmingCharacters(in: .whitespacesAndNewlines),
                price: priceDouble,
                volume: itemVolume.trimmingCharacters(in: .whitespacesAndNewlines),
                ingredients: itemIngredients.trimmingCharacters(in: .whitespacesAndNewlines),
                menuId: menuId,
                categoryId: categoryId,
                image: selectedImage
            )
            
            onItemAdded()
            dismiss()
            
        } catch {
            errorMessage = "Menü öğesi eklenemedi. Lütfen tekrar deneyin."
            showError = true
            print("Hata: \(error)")
        }
        
        isLoading = false
    }
}

#Preview {
    AddMenuItemView(
        menuId: 1,
        categoryId: 2,
        categoryName: "Ana Yemekler",
        onItemAdded: {}
    )
}
