import SwiftUI

struct AddEquipmentView: View {
    @EnvironmentObject var equipmentManager: EquipmentManager
    @Environment(\.presentationMode) var presentationMode
    
    // Form state
    @State private var equipmentName = ""
    @State private var year = Calendar.current.component(.year, from: Date())
    @State private var make = ""
    @State private var model = ""
    @State private var serialNumber = ""
    @State private var selectedCategory = EquipmentCategory.forestryMulcher
    
    // Usage
    @State private var daysPerYear = 200.0
    @State private var hoursPerDay = 6.0
    @State private var selectedUsagePattern = UsagePattern.moderate
    
    // Financial
    @State private var purchasePrice = ""
    @State private var yearsOfService = 7.0
    @State private var estimatedResaleValue = ""
    @State private var dailyFuelCost = ""
    @State private var selectedMaintenanceLevel = MaintenanceLevel.standard
    @State private var customMaintenanceCost = ""
    @State private var annualInsuranceCost = ""
    
    // Form validation
    @State private var errors: [String: String] = [:]
    @State private var showingCalculation = false
    
    var isFormValid: Bool {
        return !equipmentName.isEmpty &&
               !make.isEmpty &&
               !model.isEmpty &&
               !purchasePrice.isEmpty &&
               !dailyFuelCost.isEmpty &&
               Double(purchasePrice) ?? 0 > 0 &&
               Double(dailyFuelCost) ?? 0 > 0
    }
    
    var calculatedCosts: EquipmentCalculation? {
        guard isFormValid else { return nil }
        
        let usage = EquipmentUsage(
            daysPerYear: Int(daysPerYear),
            hoursPerDay: hoursPerDay,
            usagePattern: selectedUsagePattern
        )
        
        let financial = EquipmentFinancial(
            purchasePrice: Double(purchasePrice) ?? 0,
            yearsOfService: Int(yearsOfService),
            estimatedResaleValue: Double(estimatedResaleValue) ?? 0,
            dailyFuelCost: Double(dailyFuelCost) ?? 0,
            maintenanceLevel: selectedMaintenanceLevel,
            customMaintenanceCost: selectedMaintenanceLevel == .custom ? (Double(customMaintenanceCost) ?? 0) : nil,
            annualInsuranceCost: Double(annualInsuranceCost) ?? 0
        )
        
        return EquipmentCalculationEngine.calculateCosts(usage: usage, financial: financial)
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                Color("TreeShopBlack").ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Equipment Identity Section
                        equipmentIdentitySection
                        
                        // Usage Pattern Section
                        usagePatternSection
                        
                        // Financial Details Section
                        financialDetailsSection
                        
                        // Calculation Preview
                        if showingCalculation, let calculated = calculatedCosts {
                            calculationPreviewSection(calculated)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 100)
                }
            }
            .navigationTitle("Add Equipment")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(
                leading: Button("Cancel") {
                    presentationMode.wrappedValue.dismiss()
                }
                .foregroundColor(.white),
                
                trailing: Button("Save") {
                    saveEquipment()
                }
                .foregroundColor(isFormValid ? Color("TreeShopGreen") : .gray)
                .disabled(!isFormValid)
            )
            .onAppear {
                // Auto-calculate resale value when purchase price changes
                updateEstimatedResale()
            }
        }
    }
    
    private var equipmentIdentitySection: some View {
        VStack(alignment: .leading, spacing: 16) {
            SectionHeader(title: "Equipment Information", icon: "gear")
            
            VStack(spacing: 16) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Equipment Name")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.gray)
                    
                    TextField("e.g., CAT 289D - Unit 1", text: $equipmentName)
                        .textFieldStyle(EquipmentTextFieldStyle())
                }
                
                HStack(spacing: 16) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Year")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(.gray)
                        
                        TextField("2018", value: $year, format: .number)
                            .textFieldStyle(EquipmentTextFieldStyle())
                            .keyboardType(.numberPad)
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Category")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(.gray)
                        
                        Picker("Category", selection: $selectedCategory) {
                            ForEach(EquipmentCategory.allCases, id: \.self) { category in
                                Text(category.rawValue).tag(category)
                            }
                        }
                        .pickerStyle(MenuPickerStyle())
                        .foregroundColor(.white)
                        .padding(12)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color.white.opacity(0.05))
                        )
                    }
                }
                
                HStack(spacing: 16) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Make")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(.gray)
                        
                        TextField("Caterpillar", text: $make)
                            .textFieldStyle(EquipmentTextFieldStyle())
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Model")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(.gray)
                        
                        TextField("289D", text: $model)
                            .textFieldStyle(EquipmentTextFieldStyle())
                    }
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Serial Number (Optional)")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.gray)
                    
                    TextField("Optional", text: $serialNumber)
                        .textFieldStyle(EquipmentTextFieldStyle())
                }
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white.opacity(0.05))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.white.opacity(0.1), lineWidth: 1)
                )
        )
    }
    
    private var usagePatternSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            SectionHeader(title: "Usage Pattern", icon: "clock")
            
            VStack(spacing: 16) {
                // Usage preset buttons
                HStack(spacing: 8) {
                    ForEach([UsagePattern.light, .moderate, .heavy], id: \.self) { pattern in
                        Button(action: {
                            selectedUsagePattern = pattern
                            daysPerYear = Double(pattern.defaultDaysPerYear)
                            hoursPerDay = pattern.defaultHoursPerDay
                        }) {
                            VStack(spacing: 4) {
                                Text(pattern.rawValue)
                                    .font(.caption)
                                    .fontWeight(.medium)
                                Text(pattern.description)
                                    .font(.caption2)
                                    .opacity(0.8)
                            }
                            .foregroundColor(selectedUsagePattern == pattern ? .black : .white)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(selectedUsagePattern == pattern ? Color("TreeShopGreen") : Color.white.opacity(0.1))
                            )
                        }
                    }
                }
                
                VStack(spacing: 12) {
                    // Days per year slider
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("Days Per Year")
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundColor(.gray)
                            
                            Spacer()
                            
                            Text("\(Int(daysPerYear)) days")
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundColor(Color("TreeShopGreen"))
                        }
                        
                        Slider(value: $daysPerYear, in: 100...300, step: 5)
                            .accentColor(Color("TreeShopGreen"))
                    }
                    
                    // Hours per day slider
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("Hours Per Day")
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundColor(.gray)
                            
                            Spacer()
                            
                            Text(String(format: "%.1f hrs", hoursPerDay))
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundColor(Color("TreeShopGreen"))
                        }
                        
                        Slider(value: $hoursPerDay, in: 2...16, step: 0.5)
                            .accentColor(Color("TreeShopGreen"))
                    }
                    
                    // Annual hours display
                    HStack {
                        Text("Annual Hours:")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                        
                        Spacer()
                        
                        Text("\(Int(daysPerYear * hoursPerDay)) hours/year")
                            .font(.headline)
                            .fontWeight(.bold)
                            .foregroundColor(Color("TreeShopGreen"))
                    }
                    .padding(12)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color("TreeShopGreen").opacity(0.1))
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color("TreeShopGreen").opacity(0.3), lineWidth: 1)
                            )
                    )
                }
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white.opacity(0.05))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.white.opacity(0.1), lineWidth: 1)
                )
        )
    }
    
    private var financialDetailsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            SectionHeader(title: "Financial Details", icon: "dollarsign.circle")
            
            VStack(spacing: 16) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Purchase Price")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.gray)
                    
                    TextField("65000", text: $purchasePrice)
                        .textFieldStyle(EquipmentTextFieldStyle())
                        .keyboardType(.decimalPad)
                        .onChange(of: purchasePrice) { _ in
                            updateEstimatedResale()
                        }
                }
                
                HStack(spacing: 16) {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("Years of Service")
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundColor(.gray)
                            
                            Spacer()
                            
                            Text("\(Int(yearsOfService)) years")
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundColor(Color("TreeShopGreen"))
                        }
                        
                        Slider(value: $yearsOfService, in: 1...15, step: 1)
                            .accentColor(Color("TreeShopGreen"))
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Daily Fuel Cost")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(.gray)
                        
                        TextField("150", text: $dailyFuelCost)
                            .textFieldStyle(EquipmentTextFieldStyle())
                            .keyboardType(.decimalPad)
                    }
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Estimated Resale Value")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.gray)
                    
                    TextField("Auto-calculated", text: $estimatedResaleValue)
                        .textFieldStyle(EquipmentTextFieldStyle())
                        .keyboardType(.decimalPad)
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Maintenance Level")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.gray)
                    
                    Picker("Maintenance Level", selection: $selectedMaintenanceLevel) {
                        ForEach(MaintenanceLevel.allCases.filter { $0 != .custom }, id: \.self) { level in
                            VStack(alignment: .leading) {
                                Text(level.rawValue)
                                Text(level.annualCost.asCurrency + "/year")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }.tag(level)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Annual Insurance Cost (Optional)")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.gray)
                    
                    TextField("0", text: $annualInsuranceCost)
                        .textFieldStyle(EquipmentTextFieldStyle())
                        .keyboardType(.decimalPad)
                }
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white.opacity(0.05))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.white.opacity(0.1), lineWidth: 1)
                )
        )
    }
    
    private func calculationPreviewSection(_ calculated: EquipmentCalculation) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            SectionHeader(title: "Cost Analysis", icon: "chart.bar.fill")
            
            VStack(spacing: 16) {
                // Key metrics
                HStack(spacing: 16) {
                    VStack(spacing: 4) {
                        Text("Hourly Cost")
                            .font(.caption)
                            .foregroundColor(.gray)
                        Text(calculated.hourlyCost.asCurrencyWithCents)
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(Color("TreeShopGreen"))
                    }
                    .frame(maxWidth: .infinity)
                    
                    VStack(spacing: 4) {
                        Text("Recommended Rate")
                            .font(.caption)
                            .foregroundColor(.gray)
                        Text(calculated.recommendedRate.asCurrencyWithCents)
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                    }
                    .frame(maxWidth: .infinity)
                    
                    VStack(spacing: 4) {
                        Text("Annual Hours")
                            .font(.caption)
                            .foregroundColor(.gray)
                        Text("\(Int(calculated.annualHours))")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(Color("TreeShopBlue"))
                    }
                    .frame(maxWidth: .infinity)
                }
                .padding(16)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.white.opacity(0.03))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color("TreeShopGreen").opacity(0.2), lineWidth: 1)
                        )
                )
                
                // Cost breakdown
                VStack(alignment: .leading, spacing: 8) {
                    Text("Annual Cost Breakdown")
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                    
                    VStack(spacing: 6) {
                        HStack {
                            Text("Depreciation")
                                .foregroundColor(.gray)
                            Spacer()
                            Text(calculated.annualDepreciation.asCurrency)
                                .foregroundColor(.white)
                        }
                        
                        HStack {
                            Text("Fuel")
                                .foregroundColor(.gray)
                            Spacer()
                            Text(calculated.annualFuel.asCurrency)
                                .foregroundColor(.white)
                        }
                        
                        HStack {
                            Text("Maintenance")
                                .foregroundColor(.gray)
                            Spacer()
                            Text(calculated.annualMaintenance.asCurrency)
                                .foregroundColor(.white)
                        }
                        
                        if (Double(annualInsuranceCost) ?? 0) > 0 {
                            HStack {
                                Text("Insurance")
                                    .foregroundColor(.gray)
                                Spacer()
                                Text((Double(annualInsuranceCost) ?? 0).asCurrency)
                                    .foregroundColor(.white)
                            }
                        }
                        
                        Divider()
                            .background(Color.white.opacity(0.2))
                        
                        HStack {
                            Text("Total Annual Cost")
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                            Spacer()
                            Text(calculated.totalAnnualCost.asCurrency)
                                .fontWeight(.bold)
                                .foregroundColor(Color("TreeShopGreen"))
                        }
                    }
                    .font(.subheadline)
                }
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white.opacity(0.05))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.white.opacity(0.1), lineWidth: 1)
                )
        )
    }
    
    private func updateEstimatedResale() {
        if let price = Double(purchasePrice), price > 0 {
            let estimated = EquipmentCalculationEngine.calculateEstimatedResale(purchasePrice: price)
            estimatedResaleValue = String(format: "%.0f", estimated)
            withAnimation(.easeInOut(duration: 0.3)) {
                showingCalculation = true
            }
        }
    }
    
    private func saveEquipment() {
        guard isFormValid else { return }
        
        let identity = EquipmentIdentity(
            equipmentName: equipmentName,
            year: year,
            make: make,
            model: model,
            serialNumber: serialNumber.isEmpty ? nil : serialNumber,
            category: selectedCategory
        )
        
        let usage = EquipmentUsage(
            daysPerYear: Int(daysPerYear),
            hoursPerDay: hoursPerDay,
            usagePattern: selectedUsagePattern
        )
        
        let financial = EquipmentFinancial(
            purchasePrice: Double(purchasePrice) ?? 0,
            yearsOfService: Int(yearsOfService),
            estimatedResaleValue: Double(estimatedResaleValue) ?? 0,
            dailyFuelCost: Double(dailyFuelCost) ?? 0,
            maintenanceLevel: selectedMaintenanceLevel,
            customMaintenanceCost: nil,
            annualInsuranceCost: Double(annualInsuranceCost) ?? 0
        )
        
        let newEquipment = Equipment(
            identity: identity,
            usage: usage,
            financial: financial
        )
        
        equipmentManager.addEquipment(newEquipment)
        presentationMode.wrappedValue.dismiss()
    }
}


struct EquipmentTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .foregroundColor(.white)
            .padding(12)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.white.opacity(0.05))
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.white.opacity(0.1), lineWidth: 1)
                    )
            )
    }
}

#Preview {
    AddEquipmentView()
        .environmentObject(EquipmentManager())
}