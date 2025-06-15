//
//  CreateBusinessView.swift
//  isletmenum-ios
//
//  Created by Ozan Çiçek on 15.06.2025.
//

import SwiftUI
import PhotosUI

struct CreateBusinessView: View {
    @StateObject private var businessService = BusinessService.shared
    @State private var name = "Hatay Sofrası"
    @State private var description = "Yöresel Yemekler"
    @State private var type = "Kebapçı"
    @State private var logo = ""
    @State private var selectedImage: UIImage?
    @State private var showImagePicker = false
    @State private var showPhotosPicker = false
    @State private var showImageSourceOptions = false
    @State private var isLoading = false
    @State private var errorMessage = ""
    @State private var showError = false
    @State private var showSuccess = false
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    VStack(spacing: 12) {
                        Image(systemName: "building.2.crop.circle")
                            .font(.system(size: 60))
                            .foregroundColor(.blue)
                        
                        Text("İşletme Oluştur")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                        
                        Text("İşletmenizi kaydedin ve müşterilerinize ulaşın")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.top, 20)
                    
                    // Form
                    VStack(spacing: 20) {
                        // İşletme Adı
                        VStack(alignment: .leading, spacing: 8) {
                            Label("İşletme Adı", systemImage: "storefront")
                                .font(.headline)
                                .foregroundColor(.primary)
                            
                            TextField("Örn: Hatay Sofrası", text: $name)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .disabled(isLoading)
                        }
                        
                        // Açıklama
                        VStack(alignment: .leading, spacing: 8) {
                            Label("Açıklama", systemImage: "text.quote")
                                .font(.headline)
                                .foregroundColor(.primary)
                            
                            TextField("Örn: Yöresel Yemekler", text: $description)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .disabled(isLoading)
                        }
                        
                        // İşletme Türü
                        VStack(alignment: .leading, spacing: 8) {
                            Label("İşletme Türü", systemImage: "tag")
                                .font(.headline)
                                .foregroundColor(.primary)
                            
                            TextField("Örn: Kebapçı", text: $type)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .disabled(isLoading)
                        }
                        
                        // Logo Seçimi
                        VStack(alignment: .leading, spacing: 8) {
                            Label("Logo", systemImage: "photo.circle")
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
                                                    Text("Logo Seç")
                                                        .font(.caption2)
                                                        .foregroundColor(.blue)
                                                }
                                            )
                                    }
                                    
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(selectedImage != nil ? "Logo seçildi" : "Logo seçin")
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
                        
                        // Preview Card
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Önizleme")
                                .font(.headline)
                                .foregroundColor(.primary)
                            
                            HStack(spacing: 16) {
                                // Logo preview
                                if let selectedImage = selectedImage {
                                    Image(uiImage: selectedImage)
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 60, height: 60)
                                        .clipped()
                                        .cornerRadius(12)
                                } else {
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Color.blue.opacity(0.1))
                                        .frame(width: 60, height: 60)
                                        .overlay(
                                            Image(systemName: "photo")
                                                .font(.title2)
                                                .foregroundColor(.blue)
                                        )
                                }
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(name.isEmpty ? "İşletme Adı" : name)
                                        .font(.headline)
                                        .foregroundColor(name.isEmpty ? .secondary : .primary)
                                    
                                    Text(type.isEmpty ? "İşletme Türü" : type)
                                        .font(.subheadline)
                                        .foregroundColor(.blue)
                                    
                                    Text(description.isEmpty ? "Açıklama" : description)
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                        .lineLimit(2)
                                }
                                
                                Spacer()
                            }
                            .padding()
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(12)
                        }
                    }
                    .padding(.horizontal, 20)
                    
                    // Oluştur Butonu
                    Button(action: {
                        Task {
                            await createBusiness()
                        }
                    }) {
                        HStack {
                            if isLoading {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                    .scaleEffect(0.8)
                            }
                            
                            Text(isLoading ? "Oluşturuluyor..." : "İşletme Oluştur")
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
                    
                    Spacer(minLength: 40)
                }
            }
            .navigationBarHidden(true)
        }
        .alert("Hata", isPresented: $showError) {
            Button("Tamam", role: .cancel) { }
        } message: {
            Text(errorMessage)
        }
        .alert("Başarılı!", isPresented: $showSuccess) {
            Button("Tamam") {
                dismiss()
            }
        } message: {
            Text("İşletmeniz başarıyla oluşturuldu!")
        }
        .actionSheet(isPresented: $showImageSourceOptions) {
            ActionSheet(
                title: Text("Logo Seçin"),
                message: Text("Nereden logo seçmek istiyorsunuz?"),
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
    }
    
    private var isFormValid: Bool {
        !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !description.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !type.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        selectedImage != nil
    }
    
    private func createBusiness() async {
        guard let selectedImage = selectedImage else { return }
        
        isLoading = true
        errorMessage = ""
        
        do {
            // İşletmeyi direkt oluştur (görsel body'de gönderilecek)
            let response = try await businessService.createBusiness(
                name: name.trimmingCharacters(in: .whitespacesAndNewlines),
                description: description.trimmingCharacters(in: .whitespacesAndNewlines),
                type: type.trimmingCharacters(in: .whitespacesAndNewlines),
                logoImage: selectedImage
            )
            
            showSuccess = true
            print("İşletme oluşturuldu: \(response.message)")
            
        } catch {
            errorMessage = "İşletme oluşturulamadı. Lütfen tekrar deneyin."
            showError = true
            print("Hata: \(error)")
        }
        
        isLoading = false
    }
}

#Preview {
    CreateBusinessView()
}
