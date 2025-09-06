import SwiftUI

struct LoadoutListView: View {
    @EnvironmentObject var loadoutManager: LoadoutManager
    @State private var searchText = ""
    @State private var selectedCategory: LoadoutCategory? = nil
    @State private var selectedStatus: LoadoutStatus? = nil
    @State private var showingCreateLoadout = false
    @State private var selectedLoadout: Loadout? = nil
    @State private var showingLoadoutDetail = false
    
    var filteredLoadouts: [Loadout] {
        var loadouts = loadoutManager.loadouts
        
        // Filter by category
        if let category = selectedCategory {
            loadouts = loadouts.filter { $0.info.category == category }
        }
        
        // Filter by status
        if let status = selectedStatus {
            loadouts = loadouts.filter { $0.metadata.status == status }
        }
        
        // Filter by search text
        if !searchText.isEmpty {
            loadouts = loadoutManager.searchLoadouts(searchText)
        }
        
        return loadouts.sorted { $0.info.name < $1.info.name }
    }
    
    var body: some View {
        ZStack {
            Color("TreeShopBlack").ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header with stats
                headerSection
                
                // Filter section
                filterSection
                
                // Loadout list
                loadoutGrid
            }
        }
        .navigationTitle("Loadouts")
        .navigationBarTitleDisplayMode(.large)
        .navigationBarItems(
            trailing: Button(action: {
                showingCreateLoadout = true
            }) {
                Image(systemName: "rectangle.3.group.badge.plus")
                    .foregroundColor(Color("TreeShopGreen"))
                    .font(.title2)
            }
        )
        .sheet(isPresented: $showingCreateLoadout) {
            CreateLoadoutView()
                .environmentObject(loadoutManager)
        }
        .sheet(isPresented: $showingLoadoutDetail) {
            if let loadout = selectedLoadout {
                LoadoutDetailView(loadout: loadout)
                    .environmentObject(loadoutManager)
            }
        }
        .searchable(text: $searchText, prompt: "Search loadouts...")
    }
    
    private var headerSection: some View {
        let stats = loadoutManager.getLoadoutStats()
        
        return VStack(spacing: 16) {
            // Loadout overview stats
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: 3), spacing: 12) {
                StandardStatCard(
                    title: "Total Loadouts",
                    value: "\(stats.totalCount)",
                    icon: "rectangle.3.group",
                    color: Color("TreeShopBlue")
                )
                
                StandardStatCard(
                    title: "Active Crews",
                    value: "\(stats.activeCount)",
                    icon: "checkmark.circle",
                    color: Color("TreeShopGreen")
                )
                
                StandardStatCard(
                    title: "Avg Margin",
                    value: stats.averageProfitMargin.asPercentage,
                    icon: "chart.line.uptrend.xyaxis",
                    color: .orange
                )
            }
            .padding(.horizontal, 20)
        }
        .padding(.top, 20)
    }
    
    private var filterSection: some View {
        VStack(spacing: 12) {
            // Category filter
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    LoadoutFilterChip(
                        title: "All Categories",
                        isSelected: selectedCategory == nil
                    ) {
                        selectedCategory = nil
                    }
                    
                    ForEach(LoadoutCategory.allCases.prefix(6), id: \.self) { category in
                        LoadoutFilterChip(
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
            
            // Status filter
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    LoadoutFilterChip(
                        title: "All Status",
                        isSelected: selectedStatus == nil
                    ) {
                        selectedStatus = nil
                    }
                    
                    ForEach([LoadoutStatus.active, .onProject, .inactive], id: \.self) { status in
                        LoadoutFilterChip(
                            title: status.rawValue,
                            isSelected: selectedStatus == status,
                            color: Color(status.color)
                        ) {
                            selectedStatus = selectedStatus == status ? nil : status
                        }
                    }
                }
                .padding(.horizontal, 20)
            }
        }
        .padding(.vertical, 16)
    }
    
    private var loadoutGrid: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                if filteredLoadouts.isEmpty {
                    emptyStateView
                } else {
                    ForEach(filteredLoadouts) { loadout in
                        LoadoutRowView(loadout: loadout) {
                            selectedLoadout = loadout
                            showingLoadoutDetail = true
                        }
                        .contextMenu {
                            Button(action: {
                                selectedLoadout = loadout
                                showingLoadoutDetail = true
                            }) {
                                Label("View Details", systemImage: "eye")
                            }
                            
                            Button(action: {
                                // TODO: Edit loadout
                            }) {
                                Label("Edit Loadout", systemImage: "pencil")
                            }
                            
                            Button(action: {
                                // TODO: Duplicate loadout
                            }) {
                                Label("Duplicate", systemImage: "doc.on.doc")
                            }
                            
                            if loadout.metadata.status == .active {
                                Button(action: {
                                    // TODO: Assign to project
                                }) {
                                    Label("Assign to Project", systemImage: "hammer")
                                }
                            }
                            
                            Button(role: .destructive, action: {
                                loadoutManager.deleteLoadout(loadout)
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
            Image(systemName: "rectangle.3.group.badge.plus")
                .font(.system(size: 60))
                .foregroundColor(.gray)
            
            VStack(spacing: 8) {
                Text("No Loadouts Found")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                
                Text(searchText.isEmpty && selectedCategory == nil && selectedStatus == nil ? 
                     "Create your first crew loadout to get started" : 
                     "No loadouts match your search or filter")
                    .font(.body)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
            }
            
            Button(action: {
                showingCreateLoadout = true
            }) {
                HStack {
                    Image(systemName: "rectangle.3.group.badge.plus")
                    Text("Create Loadout")
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

struct LoadoutFilterChip: View {
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

struct LoadoutRowView: View {
    let loadout: Loadout
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 12) {
                // Header row
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(loadout.info.displayName)
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                        
                        Text(loadout.info.category.rawValue)
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing, spacing: 4) {
                        // Status badge
                        HStack(spacing: 4) {
                            Image(systemName: loadout.metadata.status.systemImage)
                                .font(.caption)
                            Text(loadout.metadata.status.rawValue)
                                .font(.caption)
                                .fontWeight(.medium)
                        }
                        .foregroundColor(Color(loadout.metadata.status.color))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(
                            RoundedRectangle(cornerRadius: 6)
                                .fill(Color(loadout.metadata.status.color).opacity(0.2))
                        )
                        
                        // Billing rate
                        if let calculated = loadout.calculated {
                            Text(calculated.billingRate.asCurrency + "/hr")
                                .font(.headline)
                                .fontWeight(.bold)
                                .foregroundColor(Color("TreeShopGreen"))
                        }
                    }
                }
                
                // Crew composition
                HStack {
                    Label("\(loadout.crew.employees.count) employees", systemImage: "person.3")
                        .font(.caption)
                        .foregroundColor(.gray)
                    
                    Label("\(loadout.crew.equipment.count) equipment", systemImage: "gear")
                        .font(.caption)
                        .foregroundColor(.gray)
                    
                    Spacer()
                    
                    if let calculated = loadout.calculated {
                        Text("Operating: \(calculated.totalOperatingCost.asCurrency)/hr")
                            .font(.caption)
                            .foregroundColor(.white)
                    }
                }
                
                // Metrics row
                if let calculated = loadout.calculated {
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Profit Margin")
                                .font(.caption)
                                .foregroundColor(.gray)
                            Text(calculated.profitMargin.asPercentage)
                                .font(.subheadline)
                                .fontWeight(.bold)
                                .foregroundColor(Color(calculated.profitabilityCategory.color))
                        }
                        
                        Spacer()
                        
                        VStack(alignment: .center, spacing: 2) {
                            Text("Daily Revenue")
                                .font(.caption)
                                .foregroundColor(.gray)
                            Text(calculated.dailyRevenue.asCurrency)
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                        }
                        
                        Spacer()
                        
                        VStack(alignment: .trailing, spacing: 2) {
                            Text("Times Used")
                                .font(.caption)
                                .foregroundColor(.gray)
                            Text("\(loadout.metadata.timesUsed)")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .foregroundColor(Color(loadout.metadata.utilizationCategory.color))
                        }
                    }
                }
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.white.opacity(0.05))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color(loadout.info.category.color).opacity(0.3), lineWidth: 1)
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    NavigationView {
        LoadoutListView()
            .environmentObject(LoadoutManager())
    }
}