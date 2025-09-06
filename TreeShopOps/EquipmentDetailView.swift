import SwiftUI

struct EquipmentDetailView: View {
    let equipment: Equipment
    @EnvironmentObject var equipmentManager: EquipmentManager
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
                        
                        // Financial foundation
                        financialFoundationCard
                        
                        // Hourly economics
                        hourlyEconomicsCard
                        
                        // Performance metrics
                        performanceMetricsCard
                        
                        // Cost analysis
                        costAnalysisCard
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 100)
                }
            }
            .navigationTitle("Equipment Details")
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
                        Label("Edit Equipment", systemImage: "pencil")
                    }
                    
                    Button(action: {
                        // TODO: Duplicate equipment
                    }) {
                        Label("Duplicate", systemImage: "doc.on.doc")
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
            // TODO: Edit equipment form
            Text("Edit Equipment - Coming Soon")
        }
        .alert("Delete Equipment", isPresented: $showingDeleteConfirm) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                equipmentManager.deleteEquipment(equipment)
                presentationMode.wrappedValue.dismiss()
            }
        } message: {
            Text("Are you sure you want to delete \(equipment.identity.displayName)? This action cannot be undone.")
        }
    }
    
    private var headerCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 8) {
                    Text(equipment.identity.displayName)
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    Text(equipment.identity.fullDescription)
                        .font(.subheadline)
                        .foregroundColor(.gray)
                    
                    HStack(spacing: 4) {
                        Image(systemName: equipment.identity.category.systemImage)
                            .font(.caption)
                            .foregroundColor(Color(equipment.identity.category.color))
                        Text(equipment.identity.category.rawValue)
                            .font(.subheadline)
                            .foregroundColor(Color(equipment.identity.category.color))
                    }
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 8) {
                    HStack(spacing: 6) {
                        Image(systemName: equipment.metadata.status.systemImage)
                            .font(.caption)
                        Text(equipment.metadata.status.rawValue)
                            .font(.caption)
                            .fontWeight(.semibold)
                    }
                    .foregroundColor(Color(equipment.metadata.status.color))
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color(equipment.metadata.status.color).opacity(0.2))
                    )
                    
                    if let serialNumber = equipment.identity.serialNumber {
                        Text("S/N: \(serialNumber)")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                }
            }
        }
        .cardStyle()
    }
    
    private var financialFoundationCard: some View {
        DetailCard(title: "Financial Foundation", icon: "building.columns.fill") {
            VStack(alignment: .leading, spacing: 12) {
                EquipmentDetailRow(title: "Purchase Cost", value: equipment.financial.purchasePrice.asCurrency)
                
                if let calculated = equipment.calculated {
                    let currentValue = equipment.financial.purchasePrice - (calculated.annualDepreciation * Double(equipment.metadata.age))
                    EquipmentDetailRow(title: "Current Value", value: max(0, currentValue).asCurrency)
                }
                
                EquipmentDetailRow(title: "Expected Life", value: "\(equipment.financial.yearsOfService) years")
                EquipmentDetailRow(title: "Usage Hours", value: "\(Int(equipment.metadata.usageHours)) hours")
                EquipmentDetailRow(title: "Utilization", value: equipment.metadata.utilization.asPercentage)
            }
        }
    }
    
    private var hourlyEconomicsCard: some View {
        DetailCard(title: "Hourly Economics", icon: "clock.fill") {
            if let calculated = equipment.calculated {
                VStack(alignment: .leading, spacing: 12) {
                    EquipmentDetailRow(title: "Operating Cost", value: calculated.hourlyCost.asCurrencyWithCents + "/hr")
                    
                    EquipmentDetailRow(
                        title: "Fuel Cost", 
                        value: (equipment.financial.dailyFuelCost / equipment.usage.hoursPerDay).asCurrencyWithCents + "/hr"
                    )
                    
                    EquipmentDetailRow(
                        title: "Depreciation", 
                        value: (calculated.annualDepreciation / calculated.annualHours).asCurrencyWithCents + "/hr"
                    )
                    
                    EquipmentDetailRow(
                        title: "Maintenance",
                        value: (calculated.annualMaintenance / calculated.annualHours).asCurrencyWithCents + "/hr"
                    )
                    
                    Divider()
                        .background(Color.white.opacity(0.2))
                    
                    HStack {
                        Text("Recommended Rate")
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                        Spacer()
                        Text(calculated.recommendedRate.asCurrencyWithCents + "/hr")
                            .font(.headline)
                            .fontWeight(.bold)
                            .foregroundColor(Color("TreeShopGreen"))
                    }
                }
            }
        }
    }
    
    private var performanceMetricsCard: some View {
        DetailCard(title: "Performance Metrics", icon: "chart.line.uptrend.xyaxis") {
            VStack(alignment: .leading, spacing: 12) {
                EquipmentDetailRow(title: "Equipment Age", value: "\(equipment.metadata.age) years")
                EquipmentDetailRow(title: "Status", value: equipment.metadata.status.rawValue)
                EquipmentDetailRow(title: "Utilization Category", value: equipment.metadata.utilizationCategory.rawValue)
                
                if let calculated = equipment.calculated {
                    EquipmentDetailRow(title: "Profit Margin", value: calculated.profitMargin.asPercentage)
                    EquipmentDetailRow(title: "Monthly Operating Cost", value: calculated.monthlyOperatingCost.asCurrency)
                }
                
                if let performanceRating = equipment.metadata.performanceRating {
                    EquipmentDetailRow(title: "Performance Rating", value: String(format: "%.1f/5.0", performanceRating))
                }
            }
        }
    }
    
    private var costAnalysisCard: some View {
        DetailCard(title: "Cost Analysis", icon: "chart.pie.fill") {
            if let calculated = equipment.calculated {
                let breakdown = EquipmentCalculationEngine.analyzeCostBreakdown(calculation: calculated)
                
                VStack(alignment: .leading, spacing: 12) {
                    Text("Cost Distribution")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.white)
                    
                    VStack(spacing: 8) {
                        CostBreakdownRow(
                            title: "Depreciation",
                            percentage: breakdown.depreciationPercentage,
                            color: .blue
                        )
                        CostBreakdownRow(
                            title: "Fuel",
                            percentage: breakdown.fuelPercentage,
                            color: .orange
                        )
                        CostBreakdownRow(
                            title: "Maintenance",
                            percentage: breakdown.maintenancePercentage,
                            color: .red
                        )
                        CostBreakdownRow(
                            title: "Insurance",
                            percentage: breakdown.insurancePercentage,
                            color: .purple
                        )
                    }
                    
                    HStack {
                        Text("Dominant Cost Factor:")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                        Text(breakdown.dominantCostFactor)
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(Color("TreeShopGreen"))
                        Spacer()
                    }
                    .padding(.top, 8)
                }
            }
        }
    }
}

struct EquipmentDetailRow: View {
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            Text(title)
                .font(.subheadline)
                .foregroundColor(.gray)
            Spacer()
            Text(value)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(.white)
        }
    }
}

struct CostBreakdownRow: View {
    let title: String
    let percentage: Double
    let color: Color
    
    var body: some View {
        VStack(spacing: 4) {
            HStack {
                Text(title)
                    .font(.caption)
                    .foregroundColor(.gray)
                Spacer()
                Text(percentage.asPercentage)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.white)
            }
            
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Rectangle()
                        .fill(Color.white.opacity(0.1))
                        .frame(height: 4)
                        .cornerRadius(2)
                    
                    Rectangle()
                        .fill(color)
                        .frame(width: geometry.size.width * (percentage / 100), height: 4)
                        .cornerRadius(2)
                }
            }
            .frame(height: 4)
        }
        .frame(height: 24)
    }
}

#Preview {
    let sampleEquipment = Equipment(
        identity: EquipmentIdentity(
            equipmentName: "CAT 289D - Unit 1",
            year: 2018,
            make: "Caterpillar",
            model: "289D",
            serialNumber: "ABC123",
            category: .forestryMulcher
        ),
        usage: EquipmentUsage(
            daysPerYear: 200,
            hoursPerDay: 6.0,
            usagePattern: .moderate
        ),
        financial: EquipmentFinancial(
            purchasePrice: 65000,
            yearsOfService: 7,
            estimatedResaleValue: 13000,
            dailyFuelCost: 150,
            maintenanceLevel: .standard,
            customMaintenanceCost: nil,
            annualInsuranceCost: 6500
        )
    )
    
    EquipmentDetailView(equipment: sampleEquipment)
        .environmentObject(EquipmentManager())
}