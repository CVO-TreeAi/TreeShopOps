import SwiftUI

struct LoadoutDetailView: View {
    let loadout: Loadout
    @EnvironmentObject var loadoutManager: LoadoutManager
    @Environment(\.presentationMode) var presentationMode
    @State private var showingEditForm = false
    @State private var showingDeleteConfirm = false
    
    var body: some View {
        NavigationView {
            ZStack {
                Color("TreeShopBlack").ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 20) {
                        // Header card
                        headerCard
                        
                        // Crew composition
                        crewCompositionCard
                        
                        // Cost analysis
                        costAnalysisCard
                        
                        // Performance dashboard
                        performanceDashboardCard
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 100)
                }
            }
            .navigationTitle("Loadout Details")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(
                leading: Button("Close") {
                    presentationMode.wrappedValue.dismiss()
                }
                .foregroundColor(.white),
                
                trailing: Menu {
                    Button(action: {
                        showingEditForm = true
                    }) {
                        Label("Edit Loadout", systemImage: "pencil")
                    }
                    
                    Button(action: {
                        // TODO: Duplicate loadout
                    }) {
                        Label("Duplicate", systemImage: "doc.on.doc")
                    }
                    
                    Button(action: {
                        // TODO: Assign to project
                    }) {
                        Label("Assign to Project", systemImage: "hammer")
                    }
                    
                    Button(role: .destructive, action: {
                        showingDeleteConfirm = true
                    }) {
                        Label("Delete", systemImage: "trash")
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                        .foregroundColor(Color("TreeShopGreen"))
                }
            )
        }
        .sheet(isPresented: $showingEditForm) {
            // TODO: Edit loadout form
            Text("Edit Loadout - Coming Soon")
        }
        .alert("Delete Loadout", isPresented: $showingDeleteConfirm) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                loadoutManager.deleteLoadout(loadout)
                presentationMode.wrappedValue.dismiss()
            }
        } message: {
            Text("Are you sure you want to delete \(loadout.info.displayName)? This action cannot be undone.")
        }
    }
    
    private var headerCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 8) {
                    Text(loadout.info.displayName)
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    Text(loadout.info.category.rawValue)
                        .font(.subheadline)
                        .foregroundColor(.gray)
                    
                    if let description = loadout.info.description {
                        Text(description)
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 8) {
                    // Status badge
                    HStack(spacing: 6) {
                        Image(systemName: loadout.metadata.status.systemImage)
                            .font(.caption)
                        Text(loadout.metadata.status.rawValue)
                            .font(.caption)
                            .fontWeight(.semibold)
                    }
                    .foregroundColor(Color(loadout.metadata.status.color))
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color(loadout.metadata.status.color).opacity(0.2))
                    )
                    
                    // Billing rate
                    if let calculated = loadout.calculated {
                        Text(calculated.billingRate.asCurrency + "/hr")
                            .font(.title3)
                            .fontWeight(.bold)
                            .foregroundColor(Color("TreeShopGreen"))
                    }
                }
            }
        }
        .cardStyle()
    }
    
    private var crewCompositionCard: some View {
        DetailCard(title: "Crew Composition", icon: "person.3.sequence.fill") {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Team Members")
                            .font(.caption)
                            .foregroundColor(.gray)
                        Text("\(loadout.crew.employees.count) employees")
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundColor(Color("TreeShopBlue"))
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing, spacing: 4) {
                        Text("Equipment")
                            .font(.caption)
                            .foregroundColor(.gray)
                        Text("\(loadout.crew.equipment.count) units")
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundColor(Color("TreeShopGreen"))
                    }
                }
                
                if let calculated = loadout.calculated {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Cost Breakdown")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(.white)
                        
                        HStack {
                            Text("Employee Costs:")
                                .foregroundColor(.gray)
                            Spacer()
                            Text(calculated.totalEmployeeCost.asCurrency + "/hr")
                                .foregroundColor(.white)
                        }
                        
                        HStack {
                            Text("Equipment Costs:")
                                .foregroundColor(.gray)
                            Spacer()
                            Text(calculated.totalEquipmentCost.asCurrency + "/hr")
                                .foregroundColor(.white)
                        }
                        
                        Divider()
                            .background(Color.white.opacity(0.2))
                        
                        HStack {
                            Text("Total Operating Cost:")
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                            Spacer()
                            Text(calculated.totalOperatingCost.asCurrency + "/hr")
                                .fontWeight(.bold)
                                .foregroundColor(Color("TreeShopGreen"))
                        }
                    }
                    .font(.subheadline)
                }
            }
        }
    }
    
    private var costAnalysisCard: some View {
        DetailCard(title: "Profitability Analysis", icon: "chart.pie.fill") {
            if let calculated = loadout.calculated {
                VStack(alignment: .leading, spacing: 12) {
                    // Profitability metrics
                    HStack(spacing: 16) {
                        VStack(spacing: 4) {
                            Text("Profit Margin")
                                .font(.caption)
                                .foregroundColor(.gray)
                            Text(calculated.profitMargin.asPercentage)
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(Color(calculated.profitabilityCategory.color))
                        }
                        .frame(maxWidth: .infinity)
                        
                        VStack(spacing: 4) {
                            Text("Hourly Profit")
                                .font(.caption)
                                .foregroundColor(.gray)
                            Text(calculated.hourlyProfit.asCurrency)
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(Color("TreeShopGreen"))
                        }
                        .frame(maxWidth: .infinity)
                        
                        VStack(spacing: 4) {
                            Text("Daily Profit")
                                .font(.caption)
                                .foregroundColor(.gray)
                            Text(calculated.dailyProfit.asCurrency)
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                        }
                        .frame(maxWidth: .infinity)
                    }
                    .padding(16)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.white.opacity(0.03))
                    )
                    
                    // Revenue projections
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Revenue Projections")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(.white)
                        
                        VStack(spacing: 6) {
                            HStack {
                                Text("Daily Revenue (8 hrs)")
                                    .foregroundColor(.gray)
                                Spacer()
                                Text(calculated.dailyRevenue.asCurrency)
                                    .foregroundColor(.white)
                            }
                            
                            HStack {
                                Text("Weekly Revenue (40 hrs)")
                                    .foregroundColor(.gray)
                                Spacer()
                                Text(calculated.weeklyRevenue.asCurrency)
                                    .foregroundColor(.white)
                            }
                            
                            HStack {
                                Text("Monthly Revenue (160 hrs)")
                                    .foregroundColor(.gray)
                                Spacer()
                                Text(calculated.monthlyRevenue.asCurrency)
                                    .foregroundColor(Color("TreeShopGreen"))
                                    .fontWeight(.semibold)
                            }
                        }
                        .font(.subheadline)
                    }
                }
            }
        }
    }
    
    private var performanceDashboardCard: some View {
        DetailCard(title: "Performance Metrics", icon: "chart.line.uptrend.xyaxis") {
            VStack(alignment: .leading, spacing: 12) {
                EmployeeDetailRow(title: "Times Used", value: "\(loadout.metadata.timesUsed)")
                EmployeeDetailRow(title: "Total Revenue", value: loadout.metadata.totalRevenue.asCurrency)
                EmployeeDetailRow(title: "Avg Revenue/Use", value: loadout.metadata.averageRevenuePerUse.asCurrency)
                EmployeeDetailRow(title: "Loadout Age", value: "\(loadout.metadata.age) days")
                EmployeeDetailRow(title: "Utilization", value: loadout.metadata.utilizationCategory.rawValue)
                
                if let lastUsed = loadout.metadata.lastUsed {
                    EmployeeDetailRow(title: "Last Used", value: lastUsed.formatted(date: .abbreviated, time: .omitted))
                }
                
                if let efficiency = loadout.metadata.efficiencyRating {
                    EmployeeDetailRow(title: "Efficiency Rating", value: String(format: "%.1f/5.0", efficiency))
                }
            }
        }
    }
}

#Preview {
    let sampleLoadout = Loadout(
        info: LoadoutInfo(
            name: "Tree Removal Crew A",
            category: .treeRemoval,
            description: "Primary tree removal crew with aerial equipment",
            assignedServices: [.treeRemoval, .stumpGrinding],
            primaryLocation: nil
        ),
        crew: LoadoutCrew(
            employees: [UUID(), UUID(), UUID(), UUID()],
            equipment: [UUID(), UUID(), UUID()],
            notes: nil
        ),
        pricing: LoadoutPricing(
            markupMultiplier: 2.5,
            hourlyMinimum: nil,
            dayRateMultiplier: nil,
            emergencyMultiplier: nil,
            seasonalAdjustment: nil,
            customRateOverride: nil
        )
    )
    
    LoadoutDetailView(loadout: sampleLoadout)
        .environmentObject(LoadoutManager())
}