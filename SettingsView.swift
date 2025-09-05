import SwiftUI
import MapKit

struct SettingsView: View {
    @ObservedObject var pricingModel: PricingModel
    @Environment(\.presentationMode) var presentationMode
    @State private var addressSearchResults: [MKMapItem] = []
    @State private var showingAddressSearch = false
    
    var body: some View {
        NavigationView {
            ZStack {
                Color("TreeShopBlack").ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 25) {
                        // Business Information Section
                        businessInfoSection
                        
                        // Package Rates Section
                        packageRatesSection
                        
                        // Additional Costs Section
                        additionalCostsSection
                        
                        // Business Rules Section
                        businessRulesSection
                        
                        // Save Button
                        saveButton
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                }
                .onTapGesture {
                    // Dismiss keyboard when tapping outside
                    hideKeyboard()
                }
            }
            .navigationTitle("Pricing Settings")
            .navigationBarTitleDisplayMode(.large)
            .navigationBarItems(
                leading: Button("Cancel") {
                    presentationMode.wrappedValue.dismiss()
                },
                trailing: Button("Done") {
                    pricingModel.saveSettings()
                    presentationMode.wrappedValue.dismiss()
                }
                .foregroundColor(Color("TreeShopGreen"))
            )
        }
        .preferredColorScheme(.dark)
    }
    
    // MARK: - Business Information Section
    private var businessInfoSection: some View {
        VStack(alignment: .leading, spacing: 15) {
            sectionHeader(title: "Business Information", icon: "building.2.fill")
            
            VStack(spacing: 12) {
                textSettingsRow(
                    title: "Business Name",
                    value: $pricingModel.businessName,
                    placeholder: "Enter business name"
                )
                
                addressSettingsRow(
                    title: "Base Location Address",
                    value: $pricingModel.baseLocationAddress,
                    placeholder: "Enter business address"
                )
                
                textSettingsRow(
                    title: "Business Phone",
                    value: $pricingModel.businessPhone,
                    placeholder: "(555) 123-4567"
                )
                
                textSettingsRow(
                    title: "Business Email",
                    value: $pricingModel.businessEmail,
                    placeholder: "contact@business.com"
                )
            }
        }
        .padding(20)
        .background(settingsCardBackground)
    }
    
    // MARK: - Package Rates Section
    private var packageRatesSection: some View {
        VStack(alignment: .leading, spacing: 15) {
            sectionHeader(title: "Package Rates (Per Acre)", icon: "tree.fill")
            
            VStack(spacing: 12) {
                ForEach(PackageType.allCases, id: \.self) { package in
                    dynamicPricingRow(for: package)
                }
            }
        }
        .padding(20)
        .background(settingsCardBackground)
    }
    
    // MARK: - Additional Costs Section
    private var additionalCostsSection: some View {
        VStack(alignment: .leading, spacing: 15) {
            sectionHeader(title: "Additional Costs", icon: "plus.circle.fill")
            
            VStack(spacing: 12) {
                settingsRow(
                    title: "Transport Rate (Per Hour)",
                    value: $pricingModel.transportRatePerHour,
                    isCurrency: true
                )
                
                settingsRow(
                    title: "Debris Hauling (Per Yard)",
                    value: $pricingModel.debrisRatePerYard,
                    isCurrency: true
                )
            }
        }
        .padding(20)
        .background(settingsCardBackground)
    }
    
    // MARK: - Business Rules Section
    private var businessRulesSection: some View {
        VStack(alignment: .leading, spacing: 15) {
            sectionHeader(title: "Business Rules", icon: "slider.horizontal.3")
            
            VStack(spacing: 12) {
                settingsRow(
                    title: "Final Price Modifier",
                    value: $pricingModel.finalMarkupMultiplier,
                    isCurrency: false,
                    suffix: "×",
                    help: "Quick pricing adjustment (1.0 = no change, 1.15 = +15%)"
                )
                
                settingsRow(
                    title: "Deposit Percentage",
                    value: Binding(
                        get: { pricingModel.depositPercentage * 100 },
                        set: { pricingModel.depositPercentage = $0 / 100 }
                    ),
                    isCurrency: false,
                    suffix: "%",
                    help: "Percentage of total project cost required as deposit"
                )
            }
        }
        .padding(20)
        .background(settingsCardBackground)
    }
    
    // MARK: - Save Button
    private var saveButton: some View {
        Button(action: {
            pricingModel.saveSettings()
            
            // Haptic feedback
            let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
            impactFeedback.impactOccurred()
            
            presentationMode.wrappedValue.dismiss()
        }) {
            HStack {
                Image(systemName: "checkmark.circle.fill")
                    .font(.title2)
                Text("Save Settings")
                    .font(.headline)
                    .fontWeight(.semibold)
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(
                LinearGradient(
                    colors: [Color(red: 0.18, green: 0.49, blue: 0.20), Color("TreeShopGreen")],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .clipShape(RoundedRectangle(cornerRadius: 12))
            )
            .shadow(color: .black.opacity(0.3), radius: 5, x: 0, y: 2)
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    // MARK: - Section Header
    private func sectionHeader(title: String, icon: String) -> some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(Color("TreeShopGreen"))
                .font(.title2)
            
            Text(title)
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(.white)
        }
    }
    
    // MARK: - Settings Row
    private func settingsRow(title: String, value: Binding<Double>, isCurrency: Bool, suffix: String = "", help: String = "") -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(Color(red: 0.8, green: 0.8, blue: 0.8))
            
            if !help.isEmpty {
                Text(help)
                    .font(.caption)
                    .foregroundColor(Color(red: 0.6, green: 0.6, blue: 0.6))
            }
            
            HStack {
                if isCurrency {
                    Text("$")
                        .foregroundColor(Color(red: 0.6, green: 0.6, blue: 0.6))
                        .font(.body)
                }
                
                TextField("0", value: value, formatter: numberFormatter(isCurrency: isCurrency))
                    .keyboardType(.decimalPad)
                    .foregroundColor(.white)
                    .font(.body)
                
                if !suffix.isEmpty {
                    Text(suffix)
                        .foregroundColor(Color(red: 0.6, green: 0.6, blue: 0.6))
                        .font(.body)
                }
            }
            .padding(12)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(red: 0.24, green: 0.24, blue: 0.24))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.white.opacity(0.1), lineWidth: 2)
                    )
            )
        }
    }
    
    // MARK: - Settings Card Background
    private var settingsCardBackground: some View {
        RoundedRectangle(cornerRadius: 16)
            .fill(Color(red: 0.15, green: 0.15, blue: 0.15))
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.white.opacity(0.1), lineWidth: 1)
            )
    }
    
    // MARK: - Text Settings Row
    private func textSettingsRow(title: String, value: Binding<String>, placeholder: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(Color(red: 0.8, green: 0.8, blue: 0.8))
            
            TextField(placeholder, text: value)
                .padding(12)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(red: 0.24, green: 0.24, blue: 0.24))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.white.opacity(0.1), lineWidth: 2)
                        )
                )
                .foregroundColor(.white)
        }
    }
    
    // MARK: - Address Settings Row with Maps Integration
    private func addressSettingsRow(title: String, value: Binding<String>, placeholder: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(Color(red: 0.8, green: 0.8, blue: 0.8))
            
            HStack {
                TextField(placeholder, text: value)
                    .onSubmit {
                        searchForAddress(value.wrappedValue)
                    }
                    .onChange(of: value.wrappedValue) { oldValue, newValue in
                        if newValue.count > 3 {
                            searchForAddress(newValue)
                        }
                    }
                
                Button(action: {
                    showingAddressSearch = true
                }) {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(Color("TreeShopGreen"))
                }
            }
            .padding(12)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(red: 0.24, green: 0.24, blue: 0.24))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.white.opacity(0.1), lineWidth: 2)
                    )
            )
            .foregroundColor(.white)
            
            // Show search results
            if !addressSearchResults.isEmpty {
                VStack(spacing: 4) {
                    ForEach(addressSearchResults.prefix(3), id: \.self) { mapItem in
                        Button(action: {
                            value.wrappedValue = formatAddress(mapItem)
                            addressSearchResults = []
                        }) {
                            HStack {
                                Image(systemName: "mappin.circle.fill")
                                    .foregroundColor(Color(red: 1.0, green: 0.76, blue: 0.03))
                                Text(formatAddress(mapItem))
                                    .font(.caption)
                                    .foregroundColor(.white)
                                Spacer()
                            }
                            .padding(.vertical, 6)
                            .padding(.horizontal, 8)
                            .background(Color(red: 0.2, green: 0.2, blue: 0.2))
                            .cornerRadius(6)
                        }
                    }
                }
                .padding(.top, 4)
            }
        }
    }
    
    // MARK: - Address Search Functions
    private func searchForAddress(_ query: String) {
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = query
        
        let search = MKLocalSearch(request: request)
        search.start { response, error in
            if let response = response {
                DispatchQueue.main.async {
                    self.addressSearchResults = Array(response.mapItems.prefix(5))
                }
            }
        }
    }
    
    private func formatAddress(_ mapItem: MKMapItem) -> String {
        let placemark = mapItem.placemark
        var components: [String] = []
        
        if let streetNumber = placemark.subThoroughfare {
            components.append(streetNumber)
        }
        if let street = placemark.thoroughfare {
            components.append(street)
        }
        if let city = placemark.locality {
            components.append(city)
        }
        if let state = placemark.administrativeArea {
            components.append(state)
        }
        if let zipCode = placemark.postalCode {
            components.append(zipCode)
        }
        
        return components.joined(separator: " ")
    }
    
    // MARK: - Dynamic Pricing Row
    private func dynamicPricingRow(for package: PackageType) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(package.displayName)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(Color(red: 0.8, green: 0.8, blue: 0.8))
                
                Spacer()
                
                // Show status badges
                if package == .medium {
                    Text("BASE RATE")
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundColor(Color("TreeShopGreen"))
                } else if pricingModel.isRateManuallyOverridden(package) {
                    HStack(spacing: 4) {
                        Text("CUSTOM")
                            .font(.caption)
                            .foregroundColor(Color(red: 1.0, green: 0.3, blue: 0.3))
                        
                        Button(action: {
                            pricingModel.resetToAutoCalculated(package)
                        }) {
                            Image(systemName: "arrow.counterclockwise")
                                .font(.caption)
                                .foregroundColor(Color(red: 0.6, green: 0.6, blue: 0.6))
                        }
                    }
                }
            }
            
            HStack {
                Text("$")
                    .foregroundColor(Color(red: 0.6, green: 0.6, blue: 0.6))
                    .font(.body)
                
                TextField("0", value: Binding(
                    get: { pricingModel.packageRates[package] ?? 0 },
                    set: { newValue in
                        if package == .medium {
                            // Update medium rate and trigger auto-calculation
                            pricingModel.updateDependentRates(basedOn: .medium, newRate: newValue)
                        } else {
                            // Mark as manually overridden and set custom rate
                            pricingModel.packageRates[package] = newValue
                            pricingModel.markAsManuallyOverridden(package)
                        }
                    }
                ), formatter: numberFormatter(isCurrency: false))
                .keyboardType(.decimalPad)
                .foregroundColor(.white)
                .font(.body)
            }
            .padding(12)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(red: 0.24, green: 0.24, blue: 0.24))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(getBorderColor(for: package), lineWidth: 2)
                    )
            )
        }
    }
    
    // MARK: - Helper Functions
    private func getPricingRelationship(for package: PackageType) -> String {
        // Don't show percentage relationships anymore, keep it clean
        return ""
    }
    
    private func getBorderColor(for package: PackageType) -> Color {
        if package == .medium {
            return Color("TreeShopGreen").opacity(0.5) // Green for base rate
        } else if pricingModel.isRateManuallyOverridden(package) {
            return Color(red: 1.0, green: 0.3, blue: 0.3).opacity(0.5) // Red for custom
        } else {
            return Color(red: 1.0, green: 0.76, blue: 0.03).opacity(0.3) // Gold for auto-calculated
        }
    }
    
    // MARK: - Keyboard Dismissal
    private func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
    
    // MARK: - Number Formatter
    private func numberFormatter(isCurrency: Bool) -> NumberFormatter {
        let formatter = NumberFormatter()
        formatter.numberStyle = isCurrency ? .decimal : .decimal
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 2
        formatter.groupingSeparator = ","
        formatter.usesGroupingSeparator = true
        return formatter
    }
}

#Preview {
    SettingsView(pricingModel: PricingModel())
}