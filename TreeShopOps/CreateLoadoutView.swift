import SwiftUI

struct CreateLoadoutView: View {
    @EnvironmentObject var loadoutManager: LoadoutManager
    @Environment(\.presentationMode) var presentationMode
    
    // Basic info
    @State private var loadoutName = ""
    @State private var selectedCategory = LoadoutCategory.treeRemoval
    @State private var description = ""
    
    // Crew selection
    @State private var selectedEmployees: Set<UUID> = []
    @State private var selectedEquipment: Set<UUID> = []
    
    // Pricing
    @State private var markupMultiplier = 2.5
    @State private var customRate = ""
    @State private var useCustomRate = false
    
    var isFormValid: Bool {
        return !loadoutName.isEmpty &&
               (!selectedEmployees.isEmpty || !selectedEquipment.isEmpty)
    }
    
    var calculatedCost: LoadoutCalculation? {
        guard isFormValid else { return nil }
        
        let crew = LoadoutCrew(
            employees: Array(selectedEmployees),
            equipment: Array(selectedEquipment),
            notes: nil
        )
        
        let pricing = LoadoutPricing(
            markupMultiplier: markupMultiplier,
            hourlyMinimum: nil,
            dayRateMultiplier: nil,
            emergencyMultiplier: nil,
            seasonalAdjustment: nil,
            customRateOverride: useCustomRate ? Double(customRate) : nil
        )
        
        return LoadoutCalculationEngine.calculateLoadout(crew: crew, pricing: pricing)
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                Color("TreeShopBlack").ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Basic Information Section
                        basicInfoSection
                        
                        // Template Selection Section
                        templateSelectionSection
                        
                        // Crew Selection Section
                        crewSelectionSection
                        
                        // Pricing Strategy Section
                        pricingSection
                        
                        // Calculation Preview
                        if let calculated = calculatedCost {
                            calculationPreviewSection(calculated)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 100)
                }
            }
            .navigationTitle("Create Loadout")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(
                leading: Button("Cancel") {
                    presentationMode.wrappedValue.dismiss()
                }
                .foregroundColor(.white),
                
                trailing: Button("Save") {
                    saveLoadout()
                }
                .foregroundColor(isFormValid ? Color("TreeShopGreen") : .gray)
                .disabled(!isFormValid)
            )
        }
    }
    
    private var basicInfoSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            SectionHeader(title: "Loadout Information", icon: "rectangle.3.group")
            
            VStack(spacing: 16) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Loadout Name")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.gray)
                    
                    TextField("e.g., Tree Removal Crew A", text: $loadoutName)
                        .textFieldStyle(EquipmentTextFieldStyle())
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Category")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.gray)
                    
                    Picker("Category", selection: $selectedCategory) {
                        ForEach(LoadoutCategory.allCases, id: \.self) { category in
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
                    .onChange(of: selectedCategory) {
                        markupMultiplier = selectedCategory.typicalMarkup
                    }
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Description (Optional)")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.gray)
                    
                    TextField("Brief description of this loadout", text: $description)
                        .textFieldStyle(EquipmentTextFieldStyle())
                }
            }
        }
        .cardStyle()
    }
    
    private var templateSelectionSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            SectionHeader(title: "Quick Start Templates", icon: "wand.and.stars")
            
            VStack(spacing: 12) {
                Text("Choose a preset template to get started quickly")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 1), spacing: 8) {
                    ForEach(LoadoutTemplates.getPresetTemplates(), id: \.name) { template in
                        Button(action: {
                            applyTemplate(template)
                        }) {
                            HStack(spacing: 16) {
                                Image(systemName: template.systemImage)
                                    .font(.title2)
                                    .foregroundColor(Color(template.color))
                                    .frame(width: 32)
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(template.name)
                                        .font(.subheadline)
                                        .fontWeight(.semibold)
                                        .foregroundColor(.white)
                                    
                                    Text(template.description)
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                    
                                    HStack {
                                        Text("\(template.recommendedEmployees) employees")
                                            .font(.caption2)
                                            .foregroundColor(.gray)
                                        
                                        Text("•")
                                            .foregroundColor(.gray)
                                        
                                        Text("\(template.recommendedEquipment) equipment")
                                            .font(.caption2)
                                            .foregroundColor(.gray)
                                        
                                        Text("•")
                                            .foregroundColor(.gray)
                                        
                                        Text("~\(template.estimatedBillingRate.asCurrency)/hr")
                                            .font(.caption2)
                                            .foregroundColor(Color("TreeShopGreen"))
                                    }
                                }
                                
                                Spacer()
                                
                                Image(systemName: "chevron.right")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                            .padding(16)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color.white.opacity(0.03))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(Color(template.color).opacity(0.2), lineWidth: 1)
                                    )
                            )
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
            }
        }
        .cardStyle()
    }
    
    private var crewSelectionSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            SectionHeader(title: "Crew Selection", icon: "person.3.sequence.fill")
            
            VStack(spacing: 16) {
                // Mock crew selection - in real implementation would show actual employees/equipment
                Text("Selected Crew Members")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.white)
                
                HStack {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Employees")
                            .font(.caption)
                            .foregroundColor(.gray)
                        
                        Button(action: {
                            // Simulate adding employees
                            selectedEmployees.insert(UUID())
                        }) {
                            HStack {
                                Image(systemName: "plus.circle")
                                Text("Add Employee")
                            }
                            .font(.caption)
                            .foregroundColor(Color("TreeShopGreen"))
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(
                                RoundedRectangle(cornerRadius: 6)
                                    .fill(Color("TreeShopGreen").opacity(0.1))
                            )
                        }
                        
                        Text("\(selectedEmployees.count) selected")
                            .font(.caption)
                            .foregroundColor(.white)
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing, spacing: 8) {
                        Text("Equipment")
                            .font(.caption)
                            .foregroundColor(.gray)
                        
                        Button(action: {
                            // Simulate adding equipment
                            selectedEquipment.insert(UUID())
                        }) {
                            HStack {
                                Image(systemName: "plus.circle")
                                Text("Add Equipment")
                            }
                            .font(.caption)
                            .foregroundColor(Color("TreeShopBlue"))
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(
                                RoundedRectangle(cornerRadius: 6)
                                    .fill(Color("TreeShopBlue").opacity(0.1))
                            )
                        }
                        
                        Text("\(selectedEquipment.count) selected")
                            .font(.caption)
                            .foregroundColor(.white)
                    }
                }
            }
        }
        .cardStyle()
    }
    
    private var pricingSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            SectionHeader(title: "Pricing Strategy", icon: "dollarsign.circle")
            
            VStack(spacing: 16) {
                // Markup multiplier
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("Markup Multiplier")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(.gray)
                        
                        Spacer()
                        
                        Text(String(format: "%.1fx", markupMultiplier))
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(Color("TreeShopGreen"))
                    }
                    
                    Slider(value: $markupMultiplier, in: 1.5...4.0, step: 0.1)
                        .accentColor(Color("TreeShopGreen"))
                    
                    HStack {
                        Text("1.5x - Competitive")
                            .font(.caption)
                            .foregroundColor(.gray)
                        Spacer()
                        Text("4.0x - Premium")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                }
                
                // Preset markup buttons
                HStack(spacing: 8) {
                    ForEach([
                        ("Competitive", 2.0),
                        ("Standard", 2.5),
                        ("Premium", 3.0),
                        ("Emergency", 3.5)
                    ], id: \.0) { preset in
                        Button(preset.0) {
                            markupMultiplier = preset.1
                        }
                        .font(.caption)
                        .foregroundColor(abs(markupMultiplier - preset.1) < 0.1 ? .black : .white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(
                            RoundedRectangle(cornerRadius: 6)
                                .fill(abs(markupMultiplier - preset.1) < 0.1 ? Color("TreeShopGreen") : Color.white.opacity(0.1))
                        )
                    }
                }
                
                // Custom rate override
                HStack {
                    Toggle("Custom Rate Override", isOn: $useCustomRate)
                        .foregroundColor(.white)
                        .toggleStyle(SwitchToggleStyle(tint: Color("TreeShopGreen")))
                }
                
                if useCustomRate {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Custom Hourly Rate")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(.gray)
                        
                        TextField("450", text: $customRate)
                            .textFieldStyle(EquipmentTextFieldStyle())
                            .keyboardType(.decimalPad)
                    }
                }
            }
        }
        .cardStyle()
    }
    
    private func calculationPreviewSection(_ calculated: LoadoutCalculation) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            SectionHeader(title: "Loadout Analysis", icon: "chart.bar.fill")
            
            VStack(spacing: 16) {
                // Key metrics
                HStack(spacing: 12) {
                    VStack(spacing: 4) {
                        Text("Operating Cost")
                            .font(.caption)
                            .foregroundColor(.gray)
                        Text(calculated.totalOperatingCost.asCurrency)
                            .font(.title3)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                        Text("per hour")
                            .font(.caption2)
                            .foregroundColor(.gray)
                    }
                    .frame(maxWidth: .infinity)
                    
                    VStack(spacing: 4) {
                        Text("Billing Rate")
                            .font(.caption)
                            .foregroundColor(.gray)
                        Text(calculated.billingRate.asCurrency)
                            .font(.title3)
                            .fontWeight(.bold)
                            .foregroundColor(Color("TreeShopGreen"))
                        Text("per hour")
                            .font(.caption2)
                            .foregroundColor(.gray)
                    }
                    .frame(maxWidth: .infinity)
                    
                    VStack(spacing: 4) {
                        Text("Profit Margin")
                            .font(.caption)
                            .foregroundColor(.gray)
                        Text(calculated.profitMargin.asPercentage)
                            .font(.title3)
                            .fontWeight(.bold)
                            .foregroundColor(Color(calculated.profitabilityCategory.color))
                        Text(calculated.profitabilityCategory.rawValue.lowercased())
                            .font(.caption2)
                            .foregroundColor(.gray)
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
                
                // Revenue projections
                VStack(alignment: .leading, spacing: 8) {
                    Text("Revenue Projections")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                    
                    VStack(spacing: 6) {
                        HStack {
                            Text("Daily (8 hours)")
                                .foregroundColor(.gray)
                            Spacer()
                            Text(calculated.dailyRevenue.asCurrency)
                                .foregroundColor(.white)
                        }
                        
                        HStack {
                            Text("Weekly (40 hours)")
                                .foregroundColor(.gray)
                            Spacer()
                            Text(calculated.weeklyRevenue.asCurrency)
                                .foregroundColor(.white)
                        }
                        
                        HStack {
                            Text("Monthly (160 hours)")
                                .foregroundColor(.gray)
                            Spacer()
                            Text(calculated.monthlyRevenue.asCurrency)
                                .foregroundColor(Color("TreeShopGreen"))
                                .fontWeight(.semibold)
                        }
                    }
                    .font(.subheadline)
                }
                
                // Cost breakdown
                VStack(alignment: .leading, spacing: 8) {
                    Text("Cost Breakdown")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                    
                    VStack(spacing: 6) {
                        HStack {
                            Text("Employee Costs")
                                .foregroundColor(.gray)
                            Spacer()
                            Text(calculated.totalEmployeeCost.asCurrency + "/hr")
                                .foregroundColor(.white)
                        }
                        
                        HStack {
                            Text("Equipment Costs")
                                .foregroundColor(.gray)
                            Spacer()
                            Text(calculated.totalEquipmentCost.asCurrency + "/hr")
                                .foregroundColor(.white)
                        }
                        
                        Divider()
                            .background(Color.white.opacity(0.2))
                        
                        HStack {
                            Text("Total Operating Cost")
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
        .cardStyle()
    }
    
    private func applyTemplate(_ template: LoadoutTemplate) {
        loadoutName = template.name
        selectedCategory = template.category
        description = template.description
        markupMultiplier = template.category.typicalMarkup
        
        // Simulate selecting crew members based on template
        selectedEmployees = Set((0..<template.recommendedEmployees).map { _ in UUID() })
        selectedEquipment = Set((0..<template.recommendedEquipment).map { _ in UUID() })
    }
    
    private func saveLoadout() {
        guard isFormValid else { return }
        
        let info = LoadoutInfo(
            name: loadoutName,
            category: selectedCategory,
            description: description.isEmpty ? nil : description,
            assignedServices: [],
            primaryLocation: nil
        )
        
        let crew = LoadoutCrew(
            employees: Array(selectedEmployees),
            equipment: Array(selectedEquipment),
            notes: nil
        )
        
        let pricing = LoadoutPricing(
            markupMultiplier: markupMultiplier,
            hourlyMinimum: nil,
            dayRateMultiplier: nil,
            emergencyMultiplier: nil,
            seasonalAdjustment: nil,
            customRateOverride: useCustomRate ? Double(customRate) : nil
        )
        
        let newLoadout = Loadout(
            info: info,
            crew: crew,
            pricing: pricing
        )
        
        loadoutManager.addLoadout(newLoadout)
        presentationMode.wrappedValue.dismiss()
    }
}

#Preview {
    CreateLoadoutView()
        .environmentObject(LoadoutManager())
}