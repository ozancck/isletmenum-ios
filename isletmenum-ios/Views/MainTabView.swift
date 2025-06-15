//
//  MainTabView.swift
//  isletmenum-ios
//
//  Created by Ozan Çiçek on 15.06.2025.
//

import SwiftUI

struct MainTabView: View {
    var body: some View {
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
    var body: some View {
        NavigationView {
            VStack {
                Image(systemName: "building.2.fill")
                    .font(.system(size: 60))
                    .foregroundColor(.blue)
                Text("İşletmeler")
                    .font(.title)
                    .padding()
                Text("Bu sayfa henüz hazırlanıyor...")
                    .foregroundColor(.secondary)
            }
            .navigationTitle("İşletmeler")
        }
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
