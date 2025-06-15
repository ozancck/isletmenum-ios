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
    
    var body: some View {
        Group {
            if businessService.hasActiveBusiness {
                TabView {
            HomeView()
                .tabItem {
                    Image(systemName: "house.fill")
                    Text("Ana Sayfa")
                }
            
            BusinessView()
                .tabItem {
                    Image(systemName: "building.2.fill")
                    Text("İşletmeler")
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
            } else {
                CreateBusinessView()
            }
        }
        .onAppear {
            Task {
                await businessService.checkUserHasBusiness()
            }
        }
    }
}

// Geçici placeholder view'lar
struct HomeView: View {
    var body: some View {
        NavigationView {
            VStack {
                Image(systemName: "house.fill")
                    .font(.system(size: 60))
                    .foregroundColor(.blue)
                Text("Ana Sayfa")
                    .font(.title)
                    .padding()
                Text("Bu sayfa henüz hazırlanıyor...")
                    .foregroundColor(.secondary)
            }
            .navigationTitle("Ana Sayfa")
        }
    }
}

struct BusinessView: View {
    @StateObject private var businessService = BusinessService.shared
    @State private var showCreateBusiness = false
    
    var body: some View {
        NavigationView {
            VStack {
                if businessService.userBusinesses.isEmpty {
                    // Boş durum
                    VStack(spacing: 20) {
                        Image(systemName: "building.2")
                            .font(.system(size: 60))
                            .foregroundColor(.gray)
                        
                        Text("Henüz İşletmeniz Yok")
                            .font(.title2)
                            .fontWeight(.semibold)
                        
                        Text("İlk işletmenizi oluşturun ve müşterilerinize ulaşın")
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                        
                        Button("İşletme Oluştur") {
                            showCreateBusiness = true
                        }
                        .buttonStyle(.borderedProminent)
                    }
                    .padding()
                } else {
                    // İşletme listesi
                    List(businessService.userBusinesses, id: \.id) { business in
                        BusinessRowView(business: business)
                    }
                }
            }
            .navigationTitle("İşletmelerim")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Ekle") {
                        showCreateBusiness = true
                    }
                }
            }
        }
        .sheet(isPresented: $showCreateBusiness) {
            CreateBusinessView()
        }
        .onAppear {
            Task {
                await businessService.checkUserHasBusiness()
            }
        }
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
