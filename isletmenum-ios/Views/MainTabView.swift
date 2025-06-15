//
//  MainTabView.swift
//  isletmenum-ios
//
//  Created by Ozan Çiçek on 15.06.2025.
//

import SwiftUI

struct MainTabView: View {
    @StateObject private var businessService = BusinessService.shared
    @State private var showCreateBusiness = false
    @State private var hasCheckedBusinesses = false
    
    var body: some View {
        Group {
            if !hasCheckedBusinesses {
                // Yükleme ekranı
                VStack {
                    ProgressView()
                        .scaleEffect(1.5)
                    Text("Yükleniyor...")
                        .padding(.top)
                }
            } else {
                TabView {
            HomeView()
                .tabItem {
                    Image(systemName: "house.fill")
                    Text("Ana Sayfa")
                }
            
            BusinessView()
                .tabItem {
                    Image(systemName: "list.bullet.rectangle")
                    Text("Menü")
                }
            
            ProfileView()
                .tabItem {
                    Image(systemName: "person.fill")
                    Text("Profil")
                }
            
            SettingsView()
                .tabItem {
                    Image(systemName: "gearshape.fill")
                    Text("Ayarlar")
                }
                }
                .accentColor(.blue)
                .sheet(isPresented: $showCreateBusiness) {
                    CreateBusinessView()
                }
            }
        }
        .onAppear {
            if !hasCheckedBusinesses {
                Task {
                    await checkUserBusinesses()
                }
            }
        }
    }
    
    private func checkUserBusinesses() async {
        do {
            _ = try await businessService.getUserBusinesses()
        } catch {
            print("Hata: \(error)")
            // Hata durumunda bile UI'yi göster, kullanıcı manuel oluşturabilir
        }
        hasCheckedBusinesses = true
    }
}

// Geçici placeholder view'lar
struct HomeView: View {
    @StateObject private var businessService = BusinessService.shared
    @State private var isLoading = false
    @State private var searchText = ""
    
    var filteredBusinesses: [Business] {
        if searchText.isEmpty {
            return businessService.allBusinesses
        } else {
            return businessService.allBusinesses.filter {
                $0.name.localizedCaseInsensitiveContains(searchText) ||
                $0.type.localizedCaseInsensitiveContains(searchText) ||
                $0.description.localizedCaseInsensitiveContains(searchText)
            }
        }
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Header
                VStack(spacing: 16) {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Merhaba! 👋")
                                .font(.headline)
                                .foregroundColor(.secondary)
                            
                            Text("İşletmeleri Keşfedin")
                                .font(.largeTitle)
                                .fontWeight(.bold)
                        }
                        
                        Spacer()
                        
                        Button(action: {
                            Task {
                                await loadBusinesses()
                            }
                        }) {
                            Image(systemName: "arrow.clockwise")
                                .font(.title2)
                                .foregroundColor(.blue)
                        }
                        .disabled(isLoading)
                    }
                    
                    // Search Bar
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.gray)
                        
                        TextField("İşletme ara...", text: $searchText)
                            .textFieldStyle(PlainTextFieldStyle())
                    }
                    .padding(12)
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(12)
                }
                .padding(.horizontal, 20)
                .padding(.top, 10)
                .padding(.bottom, 20)
                .background(Color(UIColor.systemBackground))
                
                // Content
                if isLoading {
                    Spacer()
                    VStack(spacing: 16) {
                        ProgressView()
                            .scaleEffect(1.2)
                        Text("Yükleniyor...")
                            .foregroundColor(.secondary)
                    }
                    Spacer()
                } else if filteredBusinesses.isEmpty {
                    Spacer()
                    VStack(spacing: 20) {
                        Image(systemName: searchText.isEmpty ? "building.2" : "magnifyingglass")
                            .font(.system(size: 60))
                            .foregroundColor(.gray)
                        
                        Text(searchText.isEmpty ? "Henüz İşletme Yok" : "Sonuç Bulunamadı")
                            .font(.title2)
                            .fontWeight(.semibold)
                        
                        Text(searchText.isEmpty ? "İşletmeler henüz eklenmemiş." : "Aramayı değiştirip tekrar deneyin.")
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding()
                    Spacer()
                } else {
                    ScrollView {
                        LazyVStack(spacing: 16) {
                            ForEach(filteredBusinesses, id: \.id) { business in
                                BusinessCardView(business: business)
                                    .padding(.horizontal, 20)
                            }
                        }
                        .padding(.top, 8)
                        .padding(.bottom, 20)
                    }
                }
            }
            .navigationBarHidden(true)
            .refreshable {
                await loadBusinesses()
            }
        }
        .onAppear {
            Task {
                await loadBusinesses()
            }
        }
    }
    
    private func loadBusinesses() async {
        isLoading = true
        do {
            _ = try await businessService.getAllBusinesses()
        } catch {
            print("Hata: \(error)")
        }
        isLoading = false
    }
}

struct BusinessCardView: View {
    let business: Business
    
    // Random emoji array for logos
    private let businessEmojis = ["🍔", "🍕", "☕️", "🍟", "🍝", "🍜", "🍳", "🍰", "🍺", "🍎", "🎉", "💼", "✏️", "📚", "🚗", "🏠", "💕", "🎵", "🎯", "⚽️"]
    
    private var randomEmoji: String {
        let index = abs((business.name + business.type).hashValue) % businessEmojis.count
        return businessEmojis[index]
    }
    
    var body: some View {
        Button(action: {
            // TODO: İşletme detay sayfasına git
        }) {
            HStack(spacing: 16) {
                // Logo
                if let logoPath = business.logo, !logoPath.isEmpty {
                    AsyncImage(url: URL(string: "https://api.isletmenum.com\(logoPath)")) { image in
                        image
                            .resizable()
                            .scaledToFill()
                    } placeholder: {
                        Text(randomEmoji)
                            .font(.system(size: 32))
                    }
                    .frame(width: 70, height: 70)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color.gray.opacity(0.1))
                    )
                } else {
                    Text(randomEmoji)
                        .font(.system(size: 32))
                        .frame(width: 70, height: 70)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color.blue.opacity(0.1))
                        )
                }
                
                // İçerik
                VStack(alignment: .leading, spacing: 6) {
                    HStack {
                        Text(business.name)
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundColor(.primary)
                        
                        Spacer()
                        
                        Text(business.type)
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(.blue)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(
                                Capsule()
                                    .fill(Color.blue.opacity(0.1))
                            )
                    }
                    
                    Text(business.description)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)
                    
                    HStack {
                        Label("Aktif", systemImage: "checkmark.circle.fill")
                            .font(.caption)
                            .foregroundColor(.green)
                        
                        Spacer()
                        
                        Image(systemName: "chevron.right")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                }
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(UIColor.secondarySystemBackground))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.gray.opacity(0.2), lineWidth: 1)
            )
        }
        .buttonStyle(PlainButtonStyle())
        .scaleEffect(1.0)
        .animation(.easeInOut(duration: 0.1), value: false)
    }
}

struct BusinessView: View {
    var body: some View {
        MenuManagementView()
    }
}

struct BusinessRowView: View {
    let business: Business
    
    var body: some View {
        HStack(spacing: 12) {
            // Logo placeholder
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.blue.opacity(0.1))
                .frame(width: 50, height: 50)
                .overlay(
                    Image(systemName: "building.2")
                        .foregroundColor(.blue)
                )
            
            VStack(alignment: .leading, spacing: 4) {
                Text(business.name)
                    .font(.headline)
                
                Text(business.type)
                    .font(.subheadline)
                    .foregroundColor(.blue)
                
                Text(business.description)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .foregroundColor(.gray)
                .font(.caption)
        }
        .padding(.vertical, 4)
    }
}

struct ProfileView: View {
    @StateObject private var authService = AuthService.shared
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Image(systemName: "person.circle.fill")
                    .font(.system(size: 80))
                    .foregroundColor(.blue)
                
                if let user = authService.currentUser {
                    Text("\(user.firstName) \(user.lastName)")
                        .font(.title2)
                        .fontWeight(.semibold)
                    
                    Text(user.email)
                        .foregroundColor(.secondary)
                }
                
                Button("Çıkış Yap") {
                    authService.logout()
                }
                .foregroundColor(.red)
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.red.opacity(0.1))
                .cornerRadius(10)
                .padding(.horizontal)
                
                Spacer()
            }
            .padding()
            .navigationTitle("Profil")
        }
    }
}

struct SettingsView: View {
    var body: some View {
        NavigationView {
            VStack {
                Image(systemName: "gearshape.fill")
                    .font(.system(size: 60))
                    .foregroundColor(.blue)
                Text("Ayarlar")
                    .font(.title)
                    .padding()
                Text("Bu sayfa henüz hazırlanıyor...")
                    .foregroundColor(.secondary)
            }
            .navigationTitle("Ayarlar")
        }
    }
}

#Preview {
    MainTabView()
}
