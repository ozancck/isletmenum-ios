//
//  MenuManagementView.swift
//  isletmenum-ios
//
//  Created by Ozan Çiçek on 15.06.2025.
//

import SwiftUI

struct MenuManagementView: View {
    @StateObject private var businessService = BusinessService.shared
    @StateObject private var menuService = MenuService.shared
    @State private var selectedBusiness: Business?
    @State private var showCreateBusiness = false
    @State private var showAddCategory = false
    @State private var isLoadingCategories = false
    
    var body: some View {
        VStack(spacing: 0) {
            // İşletme Seçici
            if !businessService.userBusinesses.isEmpty {
                BusinessPickerSection(
                    businesses: businessService.userBusinesses,
                    selectedBusiness: $selectedBusiness
                )
            }
            
            Divider()
            
            // Menü Yönetimi Content
            MenuContentSection(
                businessService: businessService,
                selectedBusiness: selectedBusiness,
                categories: menuService.categories,
                isLoadingCategories: isLoadingCategories,
                showCreateBusiness: $showCreateBusiness,
                showAddCategory: $showAddCategory
            )
        }
        .navigationTitle("Menü Yönetimi")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                HStack {
                    if selectedBusiness != nil {
                        Button(action: {
                            showAddCategory = true
                        }) {
                            Image(systemName: "folder.badge.plus")
                        }
                    }
                    
                    Button(action: {
                        showCreateBusiness = true
                    }) {
                        Image(systemName: "plus")
                    }
                }
            }
        }
        .sheet(isPresented: $showCreateBusiness) {
            CreateBusinessView()
        }
        .sheet(isPresented: $showAddCategory) {
            if let business = selectedBusiness {
                AddCategoryView(menuId: 1) {
                    Task {
                        await loadCategories()
                    }
                }
            }
        }
        .onChange(of: selectedBusiness) { newBusiness in
            if newBusiness != nil {
                Task {
                    await loadCategories()
                }
            } else {
                menuService.clearData()
            }
        }
        .onAppear {
            Task {
                await loadUserBusinesses()
            }
        }
    }
    
    private func loadUserBusinesses() async {
        do {
            _ = try await businessService.getUserBusinesses()
            // İlk işletmeyi otomatik seç
            if let firstBusiness = businessService.userBusinesses.first {
                selectedBusiness = firstBusiness
            }
        } catch {
            print("Hata: \(error)")
        }
    }
    
    private func loadCategories() async {
        isLoadingCategories = true
        do {
            _ = try await menuService.getCategories(menuId: 1)
        } catch {
            print("Hata: \(error)")
        }
        isLoadingCategories = false
    }
}

// MARK: - Business Picker Section
struct BusinessPickerSection: View {
    let businesses: [Business]
    @Binding var selectedBusiness: Business?
    
    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Text("İşletme Seçin")
                    .font(.headline)
                    .foregroundColor(.primary)
                Spacer()
            }
            
            Menu {
                Button("Seçiniz...") {
                    selectedBusiness = nil
                }
                
                ForEach(businesses, id: \.id) { business in
                    Button(business.name) {
                        selectedBusiness = business
                    }
                }
            } label: {
                HStack {
                    Text(selectedBusiness?.name ?? "Seçiniz...")
                        .foregroundColor(selectedBusiness != nil ? .primary : .secondary)
                    Spacer()
                    Image(systemName: "chevron.up.chevron.down")
                        .foregroundColor(.gray)
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.gray.opacity(0.1))
                )
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Color(UIColor.systemBackground))
    }
}

// MARK: - Menu Content Section
struct MenuContentSection: View {
    let businessService: BusinessService
    let selectedBusiness: Business?
    let categories: [MenuCategory]
    let isLoadingCategories: Bool
    @Binding var showCreateBusiness: Bool
    @Binding var showAddCategory: Bool
    
    var body: some View {
        if let business = selectedBusiness {
            BusinessSelectedContent(
                business: business,
                categories: categories,
                isLoadingCategories: isLoadingCategories,
                showAddCategory: $showAddCategory
            )
        } else {
            BusinessNotSelectedContent(
                businessService: businessService,
                showCreateBusiness: $showCreateBusiness
            )
        }
    }
}

// MARK: - Business Selected Content
struct BusinessSelectedContent: View {
    let business: Business
    let categories: [MenuCategory]
    let isLoadingCategories: Bool
    @Binding var showAddCategory: Bool
    
    var body: some View {
        if isLoadingCategories {
            LoadingView(message: "Kategoriler yükleniyor...")
        } else if categories.isEmpty {
            EmptyStateView(
                icon: "folder.badge.plus",
                title: "Henüz Kategori Yok",
                subtitle: "\(business.name) için ilk kategoriyi oluşturun",
                buttonTitle: "Kategori Ekle"
            ) {
                showAddCategory = true
            }
        } else {
            CategoryListView(categories: categories)
        }
    }
}

// MARK: - Business Not Selected Content
struct BusinessNotSelectedContent: View {
    let businessService: BusinessService
    @Binding var showCreateBusiness: Bool
    
    var body: some View {
        if businessService.userBusinesses.isEmpty {
            EmptyStateView(
                icon: "building.2",
                title: "Henüz İşletmeniz Yok",
                subtitle: "İlk işletmenizi oluşturun ve menü yönetimine başlayın",
                buttonTitle: "İşletme Oluştur"
            ) {
                showCreateBusiness = true
            }
        } else {
            EmptyStateView(
                icon: "arrow.up",
                title: "İşletme Seçin",
                subtitle: "Menü yönetimi için yukarıdan bir işletme seçin",
                buttonTitle: nil
            )
        }
    }
}

// MARK: - Category List View
struct CategoryListView: View {
    let categories: [MenuCategory]
    
    var body: some View {
        List {
            Section {
                ForEach(categories) { category in
                    NavigationLink(destination: CategoryDetailView(category: category, menuId: 1)) {
                        CategoryRowView(category: category)
                    }
                }
            } header: {
                Text("Menü Kategorileri")
            } footer: {
                Text("Kategorilere tıklayarak ürünleri görüntüleyin ve düzenleyin.")
            }
        }
        .listStyle(InsetGroupedListStyle())
    }
}

// MARK: - Reusable Components
struct LoadingView: View {
    let message: String
    
    var body: some View {
        VStack(spacing: 16) {
            ProgressView()
                .scaleEffect(1.2)
            Text(message)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct EmptyStateView: View {
    let icon: String
    let title: String
    let subtitle: String
    let buttonTitle: String?
    let action: (() -> Void)?
    
    init(icon: String, title: String, subtitle: String, buttonTitle: String?, action: (() -> Void)? = nil) {
        self.icon = icon
        self.title = title
        self.subtitle = subtitle
        self.buttonTitle = buttonTitle
        self.action = action
    }
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: icon)
                .font(.system(size: 60))
                .foregroundColor(buttonTitle != nil ? .gray : .blue)
            
            Text(title)
                .font(.title2)
                .fontWeight(.semibold)
            
            Text(subtitle)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            if let buttonTitle = buttonTitle, let action = action {
                Button(buttonTitle) {
                    action()
                }
                .buttonStyle(.borderedProminent)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct CategoryRowView: View {
    let category: MenuCategory
    @StateObject private var menuService = MenuService.shared
    
    private var itemCount: Int {
        menuService.getItemsForCategory(category.id).count
    }
    
    var body: some View {
        HStack {
            // Kategori ikonu
            Image(systemName: "folder.fill")
                .font(.title2)
                .foregroundColor(.blue)
                .frame(width: 30)
            
            // Kategori bilgileri
            VStack(alignment: .leading, spacing: 2) {
                Text(category.name)
                    .font(.body)
                    .foregroundColor(.primary)
                
                Text("\(itemCount) ürün")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            // iOS style disclosure indicator
            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundColor(.gray)
        }
        .padding(.vertical, 2)
    }
}

#Preview {
    NavigationView {
        MenuManagementView()
    }
}
