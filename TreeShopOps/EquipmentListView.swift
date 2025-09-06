import SwiftUI

struct EquipmentListView: View {
    @EnvironmentObject var equipmentManager: EquipmentManager
    @State private var searchText = ""
    @State private var selectedCategory: EquipmentCategory? = nil
    @State private var showingAddEquipment = false
    @State private var selectedEquipment: Equipment? = nil
    @State private var showingEquipmentDetail = false
    
    var filteredEquipment: [Equipment] {
        var equipment = equipmentManager.equipment
        
        // Filter by category
        if let category = selectedCategory {
            equipment = equipment.filter { $0.identity.category == category }
        }
        
        // Filter by search text
        if !searchText.isEmpty {
            equipment = equipmentManager.searchEquipment(searchText)
        }
        
        return equipment.sorted { $0.identity.equipmentName < $1.identity.equipmentName }
    }
    
    var body: some View {
        ZStack {
            Color("TreeShopBlack").ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header with stats
                headerSection
                
                // Filter section
                filterSection
                
                // Equipment list
                equipmentGrid
            }
        }
        .navigationTitle("Equipment")
        .navigationBarTitleDisplayMode(.large)
        .navigationBarItems(
            trailing: Button(action: {
                showingAddEquipment = true
            }) {
                Image(systemName: "plus.circle.fill")
                    .foregroundColor(Color("TreeShopGreen"))
                    .font(.title2)
            }
        )
        .sheet(isPresented: $showingAddEquipment) {
            AddEquipmentView()
                .environmentObject(equipmentManager)
        }
        .sheet(isPresented: $showingEquipmentDetail) {
            if let equipment = selectedEquipment {
                EquipmentDetailView(equipment: equipment)
                    .environmentObject(equipmentManager)
            }
        }
        .searchable(text: $searchText, prompt: "Search equipment...")
    }
    
    private var headerSection: some View {
        let stats = equipmentManager.getFleetStats()
        
        return VStack(spacing: 16) {
            // Fleet overview stats
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: 3), spacing: 12) {
                StandardStatCard(
                    title: "Total Equipment",
                    value: "\(stats.totalCount)",
                    icon: "gear",
                    color: Color("TreeShopGreen")
                )
                
                StandardStatCard(
                    title: "Fleet Value",
                    value: stats.totalFleetValue.asCurrency,
                    icon: "dollarsign.circle",
                    color: Color("TreeShopBlue")
                )
                
                StandardStatCard(
                    title: "Avg Cost/Hr",
                    value: stats.averageHourlyCost.asCurrencyWithCents,
                    icon: "chart.bar",
                    color: .orange
                )
            }
            .padding(.horizontal, 20)
        }
        .padding(.top, 20)
    }
    
    private var filterSection: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                EquipmentFilterChip(
                    title: "All",
                    isSelected: selectedCategory == nil
                ) {
                    selectedCategory = nil
                }
                
                ForEach(EquipmentCategory.allCases, id: \.self) { category in
                    EquipmentFilterChip(
                        title: category.rawValue,
                        isSelected: selectedCategory == category,
                        color: Color(category.color)
                    ) {
                        selectedCategory = selectedCategory == category ? nil : category
                    }
                }
            }
            .padding(.horizontal, 20)
        }
        .padding(.vertical, 16)
    }
    
    private var equipmentGrid: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                if filteredEquipment.isEmpty {
                    emptyStateView
                } else {
                    ForEach(filteredEquipment) { equipment in
                        EquipmentRowView(equipment: equipment) {
                            selectedEquipment = equipment
                            showingEquipmentDetail = true
                        }
                        .contextMenu {
                            Button(action: {
                                selectedEquipment = equipment
                                showingEquipmentDetail = true
                            }) {
                                Label("View Details", systemImage: "eye")
                            }
                            
                            Button(action: {
                                // TODO: Edit equipment
                            }) {
                                Label("Edit Equipment", systemImage: "pencil")
                            }
                            
                            Button(action: {
                                // TODO: Duplicate equipment
                            }) {
                                Label("Duplicate", systemImage: "doc.on.doc")
                            }
                            
                            Button(role: .destructive, action: {
                                equipmentManager.deleteEquipment(equipment)
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
            Image(systemName: "gear.badge.xmark")
                .font(.system(size: 60))
                .foregroundColor(.gray)
            
            VStack(spacing: 8) {
                Text("No Equipment Found")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                
                Text(searchText.isEmpty && selectedCategory == nil ? 
                     "Add your first piece of equipment to get started" : 
                     "No equipment matches your search or filter")
                    .font(.body)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
            }
            
            Button(action: {
                showingAddEquipment = true
            }) {
                HStack {
                    Image(systemName: "plus.circle.fill")
                    Text("Add Equipment")
                }
                .font(.headline)
                .foregroundColor(.black)
                .padding(.horizontal, 24)
                .padding(.vertical, 12)
                .background(Color("TreeShopGreen"))
                .cornerRadius(12)
            }
        }
        .padding(.vertical, 60)
    }
}

struct EquipmentFilterChip: View {
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

struct EquipmentRowView: View {
    let equipment: Equipment
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 12) {
                // Header row
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(equipment.identity.displayName)
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                        
                        Text(equipment.identity.fullDescription)
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing, spacing: 4) {
                        // Status badge
                        HStack(spacing: 4) {
                            Image(systemName: equipment.metadata.status.systemImage)
                                .font(.caption)
                            Text(equipment.metadata.status.rawValue)
                                .font(.caption)
                                .fontWeight(.medium)
                        }
                        .foregroundColor(Color(equipment.metadata.status.color))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(
                            RoundedRectangle(cornerRadius: 6)
                                .fill(Color(equipment.metadata.status.color).opacity(0.2))
                        )
                        
                        // Category badge
                        Text(equipment.identity.category.rawValue)
                            .font(.caption)
                            .foregroundColor(Color(equipment.identity.category.color))
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(
                                RoundedRectangle(cornerRadius: 4)
                                    .fill(Color(equipment.identity.category.color).opacity(0.2))
                            )
                    }
                }
                
                // Metrics row
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Hourly Cost")
                            .font(.caption)
                            .foregroundColor(.gray)
                        Text(equipment.calculated?.hourlyCost.asCurrencyWithCents ?? "$0.00")
                            .font(.headline)
                            .fontWeight(.bold)
                            .foregroundColor(Color("TreeShopGreen"))
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .center, spacing: 2) {
                        Text("Recommended Rate")
                            .font(.caption)
                            .foregroundColor(.gray)
                        Text(equipment.calculated?.recommendedRate.asCurrencyWithCents ?? "$0.00")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing, spacing: 2) {
                        Text("Utilization")
                            .font(.caption)
                            .foregroundColor(.gray)
                        Text(equipment.metadata.utilization.asPercentage)
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(Color(equipment.metadata.utilizationCategory.color))
                    }
                }
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.white.opacity(0.05))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color(equipment.identity.category.color).opacity(0.3), lineWidth: 1)
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    NavigationView {
        EquipmentListView()
            .environmentObject(EquipmentManager())
    }
}