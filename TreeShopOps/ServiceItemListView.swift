import SwiftUI

struct ServiceItemListView: View {
    @EnvironmentObject var serviceItemManager: ServiceItemManager
    @State private var searchText = ""
    @State private var selectedCategory: ServiceCategory? = nil
    @State private var showingAddService = false
    @State private var selectedService: ServiceItem? = nil
    @State private var showingServiceDetail = false
    @State private var showActiveOnly = true
    
    var filteredServices: [ServiceItem] {
        var services = serviceItemManager.serviceItems
        
        // Filter by active status
        if showActiveOnly {
            services = services.filter { $0.isActive }
        }
        
        // Filter by category
        if let category = selectedCategory {
            services = services.filter { $0.category == category }
        }
        
        // Filter by search text
        if !searchText.isEmpty {
            services = services.filter { service in
                service.name.localizedCaseInsensitiveContains(searchText) ||
                service.description.localizedCaseInsensitiveContains(searchText)
            }
        }
        
        return services.sorted { $0.name < $1.name }
    }
    
    var body: some View {
        ZStack {
            Color("TreeShopBlack").ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header with stats
                headerSection
                
                // Category filter
                categoryFilterSection
                
                // Services list
                servicesList
            }
        }
        .navigationTitle("Service Items")
        .navigationBarTitleDisplayMode(.large)
        .navigationBarItems(
            leading: Toggle("Active Only", isOn: $showActiveOnly)
                .toggleStyle(SwitchToggleStyle(tint: Color("TreeShopGreen")))
                .foregroundColor(.white),
            
            trailing: Button(action: {
                showingAddService = true
            }) {
                Image(systemName: "plus.circle.fill")
                    .font(.title2)
                    .foregroundColor(Color("TreeShopGreen"))
            }
        )
        .sheet(isPresented: $showingAddService) {
            AddEditServiceItemView()
                .environmentObject(serviceItemManager)
        }
        .sheet(isPresented: $showingServiceDetail) {
            if let service = selectedService {
                ServiceItemDetailView(serviceItem: service)
                    .environmentObject(serviceItemManager)
            }
        }
        .searchable(text: $searchText, prompt: "Search services...")
    }
    
    private var headerSection: some View {
        VStack(spacing: 16) {
            // Service stats
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: 3), spacing: 12) {
                StandardStatCard(
                    title: "Total Services",
                    value: "\(serviceItemManager.serviceItems.count)",
                    icon: "list.bullet",
                    color: .gray
                )
                
                StandardStatCard(
                    title: "Active",
                    value: "\(serviceItemManager.getActiveServiceItems().count)",
                    icon: "checkmark.circle",
                    color: Color("TreeShopGreen")
                )
                
                StandardStatCard(
                    title: "Categories",
                    value: "\(Set(serviceItemManager.serviceItems.map { $0.category }).count)",
                    icon: "folder",
                    color: Color("TreeShopBlue")
                )
            }
            .padding(.horizontal, 20)
        }
        .padding(.top, 20)
    }
    
    private var categoryFilterSection: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ServiceFilterChip(
                    title: "All",
                    isSelected: selectedCategory == nil
                ) {
                    selectedCategory = nil
                }
                
                ForEach(ServiceCategory.allCases, id: \.self) { category in
                    ServiceFilterChip(
                        title: category.rawValue,
                        isSelected: selectedCategory == category,
                        color: category.color
                    ) {
                        selectedCategory = selectedCategory == category ? nil : category
                    }
                }
            }
            .padding(.horizontal, 20)
        }
        .padding(.vertical, 16)
    }
    
    private var servicesList: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                if filteredServices.isEmpty {
                    emptyStateView
                } else {
                    ForEach(filteredServices) { service in
                        ServiceItemRowView(serviceItem: service) {
                            selectedService = service
                            showingServiceDetail = true
                        }
                        .contextMenu {
                            Button(action: {
                                selectedService = service
                                showingAddService = true
                            }) {
                                Label("Edit", systemImage: "pencil")
                            }
                            
                            Button(action: {
                                toggleServiceActive(service)
                            }) {
                                Label(service.isActive ? "Deactivate" : "Activate", 
                                      systemImage: service.isActive ? "pause.circle" : "play.circle")
                            }
                            
                            Button(role: .destructive, action: {
                                withAnimation(.spring()) {
                                    serviceItemManager.deleteServiceItem(service)
                                }
                            }) {
                                Label("Delete", systemImage: "trash")
                            }
                        }
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 100)
        }
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: "list.bullet.rectangle")
                .font(.system(size: 60))
                .foregroundColor(.gray)
            
            VStack(spacing: 8) {
                Text("No Services Found")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                
                Text(searchText.isEmpty ? "Create your first service item" : "No services match your search")
                    .font(.body)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
            }
            
            if searchText.isEmpty {
                Button(action: {
                    showingAddService = true
                }) {
                    HStack {
                        Image(systemName: "plus.circle.fill")
                        Text("Add Service")
                    }
                    .font(.headline)
                    .foregroundColor(.black)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                    .background(Color("TreeShopGreen"))
                    .cornerRadius(12)
                }
            }
        }
        .padding(.vertical, 60)
    }
    
    private func toggleServiceActive(_ service: ServiceItem) {
        var updatedService = service
        updatedService.isActive.toggle()
        serviceItemManager.updateServiceItem(updatedService)
    }
}

struct ServiceFilterChip: View {
    let title: String
    let isSelected: Bool
    let color: Color
    let action: () -> Void
    
    init(title: String, isSelected: Bool, color: Color = Color("TreeShopGreen"), action: @escaping () -> Void) {
        self.title = title
        self.isSelected = isSelected
        self.color = color
        self.action = action
    }
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(isSelected ? .black : .gray)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(isSelected ? color : Color.white.opacity(0.1))
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(isSelected ? color : Color.white.opacity(0.2), lineWidth: 1)
                        )
                )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct ServiceItemRowView: View {
    let serviceItem: ServiceItem
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 12) {
                // Header row
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(serviceItem.name)
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                        
                        Text(serviceItem.description)
                            .font(.subheadline)
                            .foregroundColor(.gray)
                            .lineLimit(2)
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing, spacing: 4) {
                        // Category badge
                        HStack(spacing: 4) {
                            Image(systemName: serviceItem.category.systemImage)
                                .font(.caption)
                            Text(serviceItem.category.rawValue)
                                .font(.caption)
                                .fontWeight(.medium)
                        }
                        .foregroundColor(serviceItem.category.color)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(
                            RoundedRectangle(cornerRadius: 6)
                                .fill(serviceItem.category.color.opacity(0.2))
                        )
                        
                        // Price
                        Text("$\(String(format: "%.2f", serviceItem.basePrice))\(serviceItem.unitType.shortName)")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(Color("TreeShopGreen"))
                    }
                }
                
                // Details row
                HStack {
                    Label(serviceItem.pricingModel.rawValue, systemImage: "dollarsign.circle")
                        .font(.caption)
                        .foregroundColor(.gray)
                    
                    if !serviceItem.equipmentRequired.isEmpty {
                        Label("\(serviceItem.equipmentRequired.count) equipment", systemImage: "wrench.and.screwdriver")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    
                    Spacer()
                    
                    if !serviceItem.isActive {
                        Label("Inactive", systemImage: "pause.circle")
                            .font(.caption)
                            .foregroundColor(.orange)
                    }
                }
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(serviceItem.isActive ? Color.white.opacity(0.05) : Color.white.opacity(0.02))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(serviceItem.isActive ? serviceItem.category.color.opacity(0.2) : Color.white.opacity(0.1), lineWidth: 1)
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
        .opacity(serviceItem.isActive ? 1.0 : 0.6)
    }
}

struct ServiceItemDetailView: View {
    @EnvironmentObject var serviceItemManager: ServiceItemManager
    @Environment(\.presentationMode) var presentationMode
    let serviceItem: ServiceItem
    
    var body: some View {
        NavigationView {
            ZStack {
                Color("TreeShopBlack").ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 20) {
                        // Service header
                        serviceHeader
                        
                        // Pricing details
                        pricingDetails
                        
                        // Requirements
                        requirementsSection
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 100)
                }
            }
            .navigationTitle("Service Details")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(
                leading: Button("Close") {
                    presentationMode.wrappedValue.dismiss()
                }
                .foregroundColor(.white)
            )
        }
    }
    
    private var serviceHeader: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 8) {
                    Text(serviceItem.name)
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    Text(serviceItem.description)
                        .font(.body)
                        .foregroundColor(.gray)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 8) {
                    HStack(spacing: 6) {
                        Image(systemName: serviceItem.category.systemImage)
                            .font(.caption)
                        Text(serviceItem.category.rawValue)
                            .font(.caption)
                            .fontWeight(.semibold)
                    }
                    .foregroundColor(serviceItem.category.color)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(serviceItem.category.color.opacity(0.2))
                    )
                    
                    Text("$\(String(format: "%.2f", serviceItem.basePrice))\(serviceItem.unitType.shortName)")
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(Color("TreeShopGreen"))
                }
            }
        }
        .cardStyle()
    }
    
    private var pricingDetails: some View {
        DetailCard(title: "Pricing Configuration", icon: "dollarsign.circle") {
            VStack(alignment: .leading, spacing: 12) {
                ServiceDetailRow(title: "Base Price", value: "$\(String(format: "%.2f", serviceItem.basePrice))")
                ServiceDetailRow(title: "Unit Type", value: serviceItem.unitType.rawValue)
                ServiceDetailRow(title: "Pricing Model", value: serviceItem.pricingModel.rawValue)
                ServiceDetailRow(title: "Min Quantity", value: String(format: "%.1f", serviceItem.minimumQuantity))
                
                if let maxQty = serviceItem.maximumQuantity {
                    ServiceDetailRow(title: "Max Quantity", value: String(format: "%.1f", maxQty))
                }
                
                ServiceDetailRow(title: "Tax Category", value: serviceItem.taxCategory.rawValue)
                ServiceDetailRow(title: "Discount Eligible", value: serviceItem.discountEligible ? "Yes" : "No")
            }
        }
    }
    
    private var requirementsSection: some View {
        DetailCard(title: "Service Requirements", icon: "wrench.and.screwdriver") {
            VStack(alignment: .leading, spacing: 12) {
                ServiceDetailRow(title: "Estimated Duration", value: "\(String(format: "%.1f", serviceItem.estimatedDuration)) hours")
                
                if !serviceItem.equipmentRequired.isEmpty {
                    ServiceDetailRow(title: "Equipment Required", value: serviceItem.equipmentRequired.joined(separator: ", "))
                }
                
                if !serviceItem.skillRequirements.isEmpty {
                    ServiceDetailRow(title: "Skill Requirements", value: serviceItem.skillRequirements.joined(separator: ", "))
                }
                
                ServiceDetailRow(title: "Seasonal Available", value: serviceItem.seasonalAvailable ? "Year-round" : "Seasonal only")
                
                if !serviceItem.notes.isEmpty {
                    ServiceDetailRow(title: "Notes", value: serviceItem.notes)
                }
            }
        }
    }
}

struct ServiceDetailRow: View {
    let title: String
    let value: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(.gray)
            Text(value)
                .font(.body)
                .foregroundColor(.white)
        }
    }
}

#Preview {
    NavigationView {
        ServiceItemListView()
            .environmentObject(ServiceItemManager())
    }
}