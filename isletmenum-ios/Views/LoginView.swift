//
//  LoginView.swift
//  isletmenum-ios
//
//  Created by Ozan Çiçek on 15.06.2025.
//

import SwiftUI

struct LoginView: View {
    @StateObject private var authService = AuthService.shared
    @State private var email = "yigitkarakurt35@gmail.com"
    @State private var password = "password123"
    @State private var isLoading = false
    @State private var errorMessage = ""
    @State private var showError = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 30) {
                // Logo ve başlık
                VStack(spacing: 16) {
                    Image(systemName: "building.2")
                        .font(.system(size: 60))
                        .foregroundColor(.blue)
                    
                    Text("İşletmenum")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    Text("Giriş Yap")
                        .font(.title2)
                        .foregroundColor(.secondary)
                }
                .padding(.top, 40)
                
                // Form
                VStack(spacing: 20) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("E-posta")
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        TextField("E-posta adresinizi girin", text: $email)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .keyboardType(.emailAddress)
                            .autocapitalization(.none)
                            .disabled(isLoading)
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Şifre")
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        SecureField("Şifrenizi girin", text: $password)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .disabled(isLoading)
                    }
                }
                .padding(.horizontal, 20)
                
                // Giriş butonu
                Button(action: {
                    Task {
                        await loginTapped()
                    }
                }) {
                    HStack {
                        if isLoading {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                .scaleEffect(0.8)
                        }
                        
                        Text(isLoading ? "Giriş yapılıyor..." : "Giriş Yap")
                            .font(.headline)
                            .foregroundColor(.white)
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(Color.blue)
                    .cornerRadius(10)
                }
                .disabled(isLoading || email.isEmpty || password.isEmpty)
                .padding(.horizontal, 20)
                
                Spacer()
            }
            .navigationBarHidden(true)
        }
        .alert("Hata", isPresented: $showError) {
            Button("Tamam", role: .cancel) { }
        } message: {
            Text(errorMessage)
        }
    }
    
    private func loginTapped() async {
        isLoading = true
        errorMessage = ""
        
        do {
            let response = try await authService.login(email: email, password: password)
            print("Giriş başarılı: \(response.message)")
        } catch {
            errorMessage = "Giriş yapılamadı. E-posta ve şifrenizi kontrol edin."
            showError = true
        }
        
        isLoading = false
    }
}

#Preview {
    LoginView()
}
