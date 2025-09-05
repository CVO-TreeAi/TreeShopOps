import SwiftUI

struct BusinessProfileView: View {
    @ObservedObject var pricingModel: PricingModel
    @Environment(\.presentationMode) var presentationMode
    
    // Section selection
    @State private var selectedSection = 0
    private let sections = ["Business Info", "Package Rates", "Additional Costs", "Business Rules"]
    
    var body: some View {
        NavigationView {
            ZStack {
                Color("TreeShopBlack").ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Section picker
                    sectionPicker
                    
                    // Form content
                    ScrollView {
                        VStack(spacing: 20) {
                            switch selectedSection {
                            case 0:
                                businessInfoSection
                            case 1:
                                packageRatesSection
                            case 2:
                                additionalCostsSection
                            case 3:
                                businessRulesSection
                            default:
                                EmptyView()
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.bottom, 100)
                    }
                    .onTapGesture {
                        hideKeyboard()
                    }
                }
            }
            .navigationTitle("Business Settings")
            .navigationBarTitleDisplayMode(.large)
            .navigationBarItems(
                leading: Button("Cancel") {
                    presentationMode.wrappedValue.dismiss()
                }
                .foregroundColor(.white),
                
                trailing: Button("Save") {
                    pricingModel.saveSettings()
                    presentationMode.wrappedValue.dismiss()
                }
                .foregroundColor(Color("TreeShopGreen"))
                .fontWeight(.semibold)
            )
        }
    }
    
    private var sectionPicker: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 16) {
                ForEach(0..<sections.count, id: \.self) { index in
                    Button(action: {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            selectedSection = index
                        }
                    }) {
                        VStack(spacing: 4) {
                            Text(sections[index])
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundColor(selectedSection == index ? Color("TreeShopGreen") : .gray)
                            
                            Rectangle()
                                .fill(selectedSection == index ? Color("TreeShopGreen") : Color.clear)
                                .frame(height: 2)
                        }
                    }
                }
            }
            .padding(.horizontal, 20)
        }
        .padding(.vertical, 16)
        .background(Color.white.opacity(0.05))
    }
    
    private var businessInfoSection: some View {
        VStack(spacing: 20) {
            BusinessSettingsSection(title: "Company Details", icon: "building.2.fill") {
                VStack(spacing: 16) {
                    BusinessField(title: "Business Name", text: $pricingModel.businessName, placeholder: "TreeShop")
                    BusinessField(title: "Base Location Address", text: $pricingModel.baseLocationAddress, placeholder: "123 Main St, City, State")
                    BusinessField(title: "Business Phone", text: $pricingModel.businessPhone, placeholder: "(555) 123-4567")
                    BusinessField(title: "Business Email", text: $pricingModel.businessEmail, placeholder: "contact@treeshop.com")
                }
            }
        }
    }
    
    private var packageRatesSection: some View {
        VStack(spacing: 20) {
            BusinessSettingsSection(title: "Forestry Mulching Rates (Per Acre)", icon: "dollarsign.circle.fill") {
                VStack(spacing: 16) {
                    ForEach(PackageType.allCases, id: \.self) { packageType in
                        PackageRateField(
                            packageType: packageType,
                            rate: Binding(
                                get: { pricingModel.packageRates[packageType] ?? 0 },
                                set: { pricingModel.packageRates[packageType] = $0 }
                            ),
                            isManuallyOverridden: pricingModel.manuallyOverriddenRates.contains(packageType)
                        )
                    }
                    
                    Text("Medium (6\" DBH) is the base rate. Other rates auto-adjust unless manually overridden.")
                        .font(.caption)
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                        .padding(.top, 8)
                }
            }
        }
    }
    
    private var additionalCostsSection: some View {
        VStack(spacing: 20) {
            BusinessSettingsSection(title: "Additional Costs", icon: "plus.circle.fill") {
                VStack(spacing: 16) {
                    BusinessDoubleField(title: "Transport Rate (Per Hour)", value: $pricingModel.transportRatePerHour)
                    BusinessDoubleField(title: "Debris Rate (Per Yard)", value: $pricingModel.debrisRatePerYard)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Final Markup Multiplier")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(.white)
                        
                        HStack {
                            Slider(value: $pricingModel.finalMarkupMultiplier, in: 1.0...2.0, step: 0.05)
                                .accentColor(Color("TreeShopGreen"))
                            
                            Text(String(format: "%.0f%%", (pricingModel.finalMarkupMultiplier - 1) * 100))
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .foregroundColor(Color("TreeShopGreen"))
                                .frame(width: 60, alignment: .trailing)
                        }
                        .padding(12)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color.white.opacity(0.1))
                                .stroke(Color.white.opacity(0.2), lineWidth: 1)
                        )
                    }
                }
            }
        }
    }
    
    private var businessRulesSection: some View {
        VStack(spacing: 20) {
            BusinessSettingsSection(title: "Business Rules", icon: "doc.text.fill") {
                VStack(spacing: 16) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Deposit Percentage")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(.white)
                        
                        HStack {
                            Slider(value: $pricingModel.depositPercentage, in: 0.1...0.5, step: 0.05)
                                .accentColor(Color("TreeShopGreen"))
                            
                            Text(String(format: "%.0f%%", pricingModel.depositPercentage * 100))
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .foregroundColor(Color("TreeShopGreen"))
                                .frame(width: 60, alignment: .trailing)
                        }
                        .padding(12)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color.white.opacity(0.1))
                                .stroke(Color.white.opacity(0.2), lineWidth: 1)
                        )
                    }
                    
                    Text("Debris Estimates (Yards per Acre)")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.white)
                    
                    VStack(spacing: 12) {
                        ForEach([PackageType.maxLight, PackageType.maxMedium, PackageType.maxHeavy], id: \.self) { packageType in
                            DebrisEstimateField(
                                packageType: packageType,
                                estimate: Binding(
                                    get: { pricingModel.debrisEstimates[packageType] ?? 0 },
                                    set: { pricingModel.debrisEstimates[packageType] = $0 }
                                )
                            )
                        }
                    }
                }
            }
        }
    }
}

struct BusinessSettingsSection<Content: View>: View {
    let title: String
    let icon: String
    let content: Content
    
    init(title: String, icon: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.icon = icon
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(Color("TreeShopGreen"))
                
                Text(title)
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
            }
            
            content
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white.opacity(0.05))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.white.opacity(0.1), lineWidth: 1)
                )
        )
    }
}

struct BusinessField: View {
    let title: String
    @Binding var text: String
    let placeholder: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(.white)
            
            TextField(placeholder, text: $text)
                .textFieldStyle(PlainTextFieldStyle())
                .foregroundColor(.white)
                .padding(12)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.white.opacity(0.1))
                        .stroke(Color.white.opacity(0.2), lineWidth: 1)
                )
        }
    }
}

struct BusinessDoubleField: View {
    let title: String
    @Binding var value: Double
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(.white)
            
            TextField("$0.00", value: $value, format: .currency(code: "USD"))
                .textFieldStyle(PlainTextFieldStyle())
                .foregroundColor(.white)
                .keyboardType(.decimalPad)
                .padding(12)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.white.opacity(0.1))
                        .stroke(Color.white.opacity(0.2), lineWidth: 1)
                )
        }
    }
}

struct PackageRateField: View {
    let packageType: PackageType
    @Binding var rate: Double
    let isManuallyOverridden: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(packageType.displayName)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.white)
                
                Spacer()
                
                if packageType == .medium {
                    Text("BASE RATE")
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundColor(Color("TreeShopGreen"))
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(
                            RoundedRectangle(cornerRadius: 4)
                                .fill(Color("TreeShopGreen").opacity(0.2))
                        )
                } else if isManuallyOverridden {
                    Text("MANUAL")
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundColor(.orange)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(
                            RoundedRectangle(cornerRadius: 4)
                                .fill(Color.orange.opacity(0.2))
                        )
                }
            }
            
            TextField("$0.00", value: $rate, format: .currency(code: "USD"))
                .textFieldStyle(PlainTextFieldStyle())
                .foregroundColor(.white)
                .keyboardType(.decimalPad)
                .padding(12)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.white.opacity(0.1))
                        .stroke(packageType == .medium ? Color("TreeShopGreen").opacity(0.3) : Color.white.opacity(0.2), lineWidth: packageType == .medium ? 2 : 1)
                )
            
            if !packageType.densityDescription.isEmpty {
                Text(packageType.densityDescription)
                    .font(.caption)
                    .foregroundColor(.gray)
            }
        }
    }
}

struct DebrisEstimateField: View {
    let packageType: PackageType
    @Binding var estimate: Double
    
    var body: some View {
        HStack {
            Text(packageType.displayName)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(.white)
            
            Spacer()
            
            TextField("0", value: $estimate, format: .number)
                .textFieldStyle(PlainTextFieldStyle())
                .foregroundColor(.white)
                .keyboardType(.numberPad)
                .multilineTextAlignment(.trailing)
                .padding(8)
                .background(
                    RoundedRectangle(cornerRadius: 6)
                        .fill(Color.white.opacity(0.1))
                        .stroke(Color.white.opacity(0.2), lineWidth: 1)
                )
                .frame(width: 80)
            
            Text("yards")
                .font(.caption)
                .foregroundColor(.gray)
        }
    }
}

#Preview {
    BusinessProfileView(pricingModel: PricingModel())
}