import SwiftUI

struct ContentView: View {
    @StateObject private var pricingModel = PricingModel()
    @EnvironmentObject var customerManager: CustomerManager
    @EnvironmentObject var proposalManager: ProposalManager
    @State private var showingSettings = false
    @State private var showDetailedBreakdown = false
    @State private var showingCustomers = false
    @State private var selectedCustomer: Customer? = nil
    @State private var showingSaveQuote = false
    @State private var showingNewCustomer = false
    @State private var showingQuoteSavedAlert = false
    @State private var showingSaveProposal = false
    @State private var proposalTitle = ""
    @State private var proposalDescription = ""
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Dynamic gradient background
                backgroundGradient
                
                ScrollView(showsIndicators: false) {
                    LazyVStack(spacing: 0) {
                        // Compact floating header
                        floatingHeader
                        
                        // Main content with glassmorphism cards
                        VStack(spacing: 20) {
                            customerSelectionCard
                            inputCard
                            resultsCard
                        }
                        .padding(.horizontal, 16)
                        .padding(.bottom, 30)
                    }
                }
                .onTapGesture {
                    // Dismiss keyboard when tapping outside
                    hideKeyboard()
                }
            }
        }
        .ignoresSafeArea(.container, edges: .top)
        .sheet(isPresented: $showingSettings) {
            SettingsView(pricingModel: pricingModel)
        }
        .sheet(isPresented: $showingCustomers) {
            CustomerListView(onCustomerSelected: { customer in
                selectedCustomer = customer
                // Auto-populate zip code from customer
                if !customer.zipCode.isEmpty && pricingModel.projectZipCode.isEmpty {
                    pricingModel.projectZipCode = customer.zipCode
                    pricingModel.calculateTransportTime(for: customer.zipCode)
                }
                // If we have a valid quote, create a project for this customer
                if pricingModel.landSize > 0 && pricingModel.finalPrice > 0 {
                    customerManager.createProjectFromQuote(customer.id, pricingModel: pricingModel, projectName: "Tree Service Quote")
                }
            })
        }
        .actionSheet(isPresented: $showingSaveQuote) {
            ActionSheet(
                title: Text("Save Quote"),
                message: Text("How would you like to save this quote?"),
                buttons: [
                    .default(Text("Save as Proposal")) {
                        showingSaveProposal = true
                    },
                    .default(Text("Select Existing Customer")) {
                        showingCustomers = true
                    },
                    .default(Text("Create New Customer")) {
                        createNewCustomerWithQuote()
                    },
                    .cancel()
                ]
            )
        }
        .sheet(isPresented: $showingNewCustomer) {
            AddEditCustomerView(customerManager: customerManager, pricingModel: pricingModel)
        }
        .sheet(isPresented: $showingSaveProposal) {
            SaveProposalView(
                pricingModel: pricingModel,
                selectedCustomer: selectedCustomer,
                proposalTitle: $proposalTitle,
                proposalDescription: $proposalDescription,
                onSave: { title, description in
                    saveAsProposal(title: title, description: description)
                }
            )
        }
        .alert(isPresented: $showingQuoteSavedAlert) {
            Alert(
                title: Text("Quote Saved!"),
                message: Text("The quote has been added to \(selectedCustomer?.fullName ?? "the customer")'s projects."),
                dismissButton: .default(Text("OK"))
            )
        }
    }
    
    // MARK: - Modern UI Components
    private var backgroundGradient: some View {
        ZStack {
            // Animated gradient background
            LinearGradient(
                colors: [
                    Color("TreeShopBlack"),
                    Color(red: 0.05, green: 0.05, blue: 0.1),
                    Color(red: 0.1, green: 0.15, blue: 0.05),
                    Color("TreeShopBlack")
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            
            // Floating orbs for depth
            Circle()
                .fill(Color(red: 0.2, green: 0.5, blue: 0.2).opacity(0.1))
                .frame(width: 200, height: 200)
                .offset(x: -100, y: -150)
                .blur(radius: 60)
            
            Circle()
                .fill(Color(red: 0.1, green: 0.7, blue: 0.3).opacity(0.08))
                .frame(width: 300, height: 300)
                .offset(x: 150, y: 300)
                .blur(radius: 80)
        }
    }
    
    private var floatingHeader: some View {
        HStack {
            // Compact logo
            HStack(spacing: 8) {
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [Color("TreeShopGreen"), Color(red: 0.1, green: 0.5, blue: 0.2)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 32, height: 32)
                    
                    Image(systemName: "tree.fill")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.white)
                }
                
                Text("TreeShop")
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                    .foregroundColor(.white)
            }
            
            Spacer()
            
            // Customer management button
            Button(action: {
                showingCustomers = true
                let impactFeedback = UIImpactFeedbackGenerator(style: .light)
                impactFeedback.impactOccurred()
            }) {
                ZStack {
                    Circle()
                        .fill(Color.white.opacity(0.1))
                        .frame(width: 40, height: 40)
                        .background(.ultraThinMaterial, in: Circle())
                    
                    Image(systemName: "person.2.fill")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.white)
                }
            }
            .buttonStyle(ScaleButtonStyle())
            
            // Floating settings button
            Button(action: {
                showingSettings = true
                let impactFeedback = UIImpactFeedbackGenerator(style: .light)
                impactFeedback.impactOccurred()
            }) {
                ZStack {
                    Circle()
                        .fill(Color.white.opacity(0.1))
                        .frame(width: 40, height: 40)
                        .background(.ultraThinMaterial, in: Circle())
                    
                    Image(systemName: "slider.horizontal.3")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.white)
                }
            }
            .buttonStyle(ScaleButtonStyle())
        }
        .padding(.horizontal, 20)
        .padding(.top, 60)
        .padding(.bottom, 20)
    }
    
    // MARK: - Modern Input Card
    private var inputCard: some View {
        VStack(spacing: 24) {
            // Card header with icon
            HStack {
                HStack(spacing: 10) {
                    Image(systemName: "square.and.pencil")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(Color("TreeShopGreen"))
                    
                    Text("Project Details")
                        .font(.system(size: 18, weight: .semibold, design: .rounded))
                        .foregroundColor(.white)
                }
                
                Spacer()
            }
            
            // Input fields with modern styling
            VStack(spacing: 16) {
                // Top row: Land Size + Zip Code
                HStack(spacing: 12) {
                    compactInputField(
                        title: "Land Size",
                        value: $pricingModel.landSize,
                        placeholder: "0.0",
                        suffix: "acres",
                        icon: "ruler"
                    )
                    
                    compactZipCodeField
                }
                
                // Package selection row
                modernPackagePicker
                
                // Additional debris (if needed)
                if pricingModel.debrisYards > 0 || !pricingModel.isMaxPackage {
                    compactInputField(
                        title: "Additional Debris",
                        value: $pricingModel.debrisYards,
                        placeholder: "0",
                        suffix: "yards",
                        icon: "cube.box"
                    )
                }
            }
        }
        .padding(24)
        .background(glassMorphismBackground)
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }
    
    // MARK: - Package Picker
    private var packagePicker: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Package Type")
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(Color(red: 0.8, green: 0.8, blue: 0.8))
            
            Picker("Package Type", selection: $pricingModel.selectedPackage) {
                ForEach(PackageType.allCases) { package in
                    VStack(alignment: .leading) {
                        Text(package.displayName)
                        if !package.densityDescription.isEmpty {
                            Text(package.densityDescription)
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                    }
                    .tag(package)
                }
            }
            .pickerStyle(MenuPickerStyle())
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(12)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color("TreeShopBlack"))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.white.opacity(0.1), lineWidth: 2)
                    )
            )
            .accentColor(Color("TreeShopGreen"))
            
            // Show description for selected Max package
            if !pricingModel.selectedPackage.densityDescription.isEmpty {
                Text(pricingModel.selectedPackage.densityDescription)
                    .font(.caption)
                    .foregroundColor(Color(red: 1.0, green: 0.76, blue: 0.03))
                    .padding(.top, 4)
            }
        }
    }
    
    // MARK: - Input Field
    private func inputField(title: String, value: Binding<Double>, placeholder: String, formatter: NumberFormatter.Style) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(Color(red: 0.8, green: 0.8, blue: 0.8))
            
            TextField(placeholder, value: value, formatter: numberFormatter(style: formatter))
                .padding(12)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color("TreeShopBlack"))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.white.opacity(0.1), lineWidth: 2)
                        )
                )
                .foregroundColor(.white)
                .keyboardType(.decimalPad)
        }
    }
    
    // MARK: - Results Section
    private var resultsSection: some View {
        VStack(spacing: 0) {
            VStack(spacing: 12) {
                resultRow(label: "Package Cost", value: pricingModel.formatCurrency(pricingModel.baseCost))
                resultRow(label: "Transport", value: pricingModel.formatCurrency(pricingModel.transportCost))
                
                // Show debris breakdown for Max packages
                if pricingModel.isMaxPackage {
                    VStack(spacing: 4) {
                        resultRow(label: "Est. Debris (\(Int(pricingModel.estimatedDebrisYards)) yds @ $20)", value: pricingModel.formatCurrency(pricingModel.estimatedDebrisYards * pricingModel.debrisRatePerYard))
                        if pricingModel.debrisYards > 0 {
                            resultRow(label: "Additional Debris", value: pricingModel.formatCurrency(pricingModel.debrisYards * pricingModel.debrisRatePerYard))
                        }
                        resultRow(label: "Total Debris Hauling", value: pricingModel.formatCurrency(pricingModel.debrisCost))
                            .foregroundColor(Color(red: 1.0, green: 0.76, blue: 0.03))
                    }
                } else {
                    resultRow(label: "Debris Hauling", value: pricingModel.formatCurrency(pricingModel.debrisCost))
                }
                
                resultRow(label: "Subtotal", value: pricingModel.formatCurrency(pricingModel.subtotal))
                resultRow(label: "Project Total", value: pricingModel.formatCurrency(pricingModel.finalPrice))
                
                // Highlighted deposit row
                depositRow
                
                resultRow(label: "Balance at Completion", value: pricingModel.formatCurrency(pricingModel.balanceDue))
            }
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color("TreeShopBlack"))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.white.opacity(0.1), lineWidth: 1)
                    )
            )
            
            // Total section
            totalSection
        }
    }
    
    // MARK: - Result Row
    private func resultRow(label: String, value: String) -> some View {
        HStack {
            Text(label)
                .foregroundColor(Color(red: 0.8, green: 0.8, blue: 0.8))
            Spacer()
            Text(value)
                .fontWeight(.semibold)
                .foregroundColor(.white)
        }
        .padding(.vertical, 8)
    }
    
    // MARK: - Deposit Row (Highlighted)
    private var depositRow: some View {
        HStack {
            HStack {
                Image(systemName: "dollarsign.circle.fill")
                    .foregroundColor(Color(red: 1.0, green: 0.76, blue: 0.03))
                Text("Deposit Required (\(Int(pricingModel.depositPercentage * 100))%)")
                    .foregroundColor(Color(red: 0.8, green: 0.8, blue: 0.8))
            }
            Spacer()
            Text(pricingModel.formatCurrency(pricingModel.depositAmount))
                .fontWeight(.bold)
                .foregroundColor(Color(red: 1.0, green: 0.76, blue: 0.03))
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color(red: 1.0, green: 0.76, blue: 0.03).opacity(0.1))
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color(red: 1.0, green: 0.76, blue: 0.03).opacity(0.3), lineWidth: 1)
                )
        )
    }
    
    // MARK: - Total Section
    private var totalSection: some View {
        VStack {
            Text("Total Project Cost")
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(.white)
            
            Text(pricingModel.formatCurrency(pricingModel.finalPrice))
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(.white)
        }
        .frame(maxWidth: .infinity)
        .padding(20)
        .background(
            LinearGradient(
                colors: [Color(red: 0.18, green: 0.49, blue: 0.20), Color("TreeShopGreen")],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .clipShape(RoundedRectangle(cornerRadius: 16))
        )
        .shadow(color: .black.opacity(0.2), radius: 5, x: 0, y: 2)
    }
    
    // MARK: - Project Zip Code Field
    private var projectZipCodeField: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Project Zip Code")
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(Color(red: 0.8, green: 0.8, blue: 0.8))
            
            HStack {
                TextField("Enter project zip code", text: $pricingModel.projectZipCode)
                    .keyboardType(.numberPad)
                    .onChange(of: pricingModel.projectZipCode) { oldValue, newValue in
                        // Auto-calculate when zip code is 5 digits
                        if newValue.count == 5 && !pricingModel.baseLocationAddress.isEmpty {
                            pricingModel.calculateTransportTime(for: newValue)
                        }
                    }
                
                if pricingModel.isCalculatingDistance {
                    ProgressView()
                        .scaleEffect(0.8)
                        .foregroundColor(Color("TreeShopGreen"))
                } else {
                    Button(action: {
                        if !pricingModel.projectZipCode.isEmpty {
                            pricingModel.calculateTransportTime(for: pricingModel.projectZipCode)
                        }
                    }) {
                        Image(systemName: "location.fill")
                            .foregroundColor(Color("TreeShopGreen"))
                    }
                }
            }
            .padding(12)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color("TreeShopBlack"))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.white.opacity(0.1), lineWidth: 2)
                    )
            )
            .foregroundColor(.white)
        }
    }
    
    // MARK: - Transport Hours Field
    private var transportHoursField: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Transport Hours")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(Color(red: 0.8, green: 0.8, blue: 0.8))
                
                Spacer()
                
                if pricingModel.transportHours > 0 && !pricingModel.projectZipCode.isEmpty {
                    Text("Auto-calculated")
                        .font(.caption)
                        .foregroundColor(Color(red: 1.0, green: 0.76, blue: 0.03))
                }
            }
            
            TextField("Hours", value: $pricingModel.transportHours, formatter: numberFormatter(style: .decimal))
                .padding(12)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color("TreeShopBlack"))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(pricingModel.transportHours > 0 && !pricingModel.projectZipCode.isEmpty ? 
                                       Color(red: 1.0, green: 0.76, blue: 0.03).opacity(0.5) : 
                                       Color.white.opacity(0.1), lineWidth: 2)
                        )
                )
                .foregroundColor(.white)
                .keyboardType(.decimalPad)
        }
    }
    
    // MARK: - Modern UI Helpers
    private var glassMorphismBackground: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20)
                .fill(.ultraThinMaterial)
            
            RoundedRectangle(cornerRadius: 20)
                .fill(
                    LinearGradient(
                        colors: [
                            Color.white.opacity(0.05),
                            Color.white.opacity(0.02),
                            Color.black.opacity(0.05)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
            
            RoundedRectangle(cornerRadius: 20)
                .stroke(
                    LinearGradient(
                        colors: [Color.white.opacity(0.2), Color.white.opacity(0.05)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1
                )
        }
    }
    
    private var resultsCard: some View {
        VStack(spacing: 20) {
            // Results header with expand/collapse button
            HStack {
                HStack(spacing: 10) {
                    Image(systemName: "dollarsign.circle.fill")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(Color(red: 1.0, green: 0.76, blue: 0.03))
                    
                    Text("Instant Quote")
                        .font(.system(size: 18, weight: .semibold, design: .rounded))
                        .foregroundColor(.white)
                }
                
                Spacer()
                
                // Live calculation indicator
                HStack(spacing: 8) {
                    HStack(spacing: 4) {
                        Circle()
                            .fill(Color("TreeShopGreen"))
                            .frame(width: 6, height: 6)
                        
                        Text("LIVE")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(Color("TreeShopGreen"))
                    }
                    
                    // Expand/collapse button
                    Button(action: {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            showDetailedBreakdown.toggle()
                        }
                        let impactFeedback = UIImpactFeedbackGenerator(style: .light)
                        impactFeedback.impactOccurred()
                    }) {
                        Image(systemName: showDetailedBreakdown ? "chevron.up.circle.fill" : "chevron.down.circle.fill")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(Color.white.opacity(0.6))
                    }
                    .buttonStyle(ScaleButtonStyle())
                }
            }
            
            VStack(spacing: 16) {
                // Always visible: Project Total and Deposit
                VStack(spacing: 12) {
                    modernResultRow(
                        label: "Project Total",
                        value: pricingModel.formatCurrency(pricingModel.finalPrice),
                        icon: "checkmark.seal.fill",
                        isTotal: true
                    )
                    
                    // Compact deposit info
                    HStack {
                        Image(systemName: "creditcard.fill")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(Color(red: 1.0, green: 0.76, blue: 0.03))
                            .frame(width: 16)
                        
                        Text("Deposit Required (25%)")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(Color.white.opacity(0.8))
                        
                        Spacer()
                        
                        Text(pricingModel.formatCurrency(pricingModel.depositAmount))
                            .font(.system(size: 16, weight: .bold, design: .rounded))
                            .foregroundColor(Color(red: 1.0, green: 0.76, blue: 0.03))
                    }
                }
                
                // Expandable detailed breakdown
                if showDetailedBreakdown {
                    VStack(spacing: 12) {
                        Divider()
                            .background(Color.white.opacity(0.2))
                        
                        // Detailed breakdown
                        VStack(spacing: 10) {
                            modernResultRow(label: "Package Cost", value: pricingModel.formatCurrency(pricingModel.baseCost), icon: "tree.fill")
                            modernResultRow(label: "Transport", value: pricingModel.formatCurrency(pricingModel.transportCost), icon: "truck.box")
                            
                            if pricingModel.isMaxPackage {
                                modernResultRow(
                                    label: "Est. Debris (\(Int(pricingModel.estimatedDebrisYards)) yds)",
                                    value: pricingModel.formatCurrency(pricingModel.estimatedDebrisYards * pricingModel.debrisRatePerYard),
                                    icon: "cube.box.fill",
                                    isHighlighted: true
                                )
                                if pricingModel.debrisYards > 0 {
                                    modernResultRow(
                                        label: "Additional Debris",
                                        value: pricingModel.formatCurrency(pricingModel.debrisYards * pricingModel.debrisRatePerYard),
                                        icon: "plus.circle.fill"
                                    )
                                }
                            } else {
                                if pricingModel.debrisCost > 0 {
                                    modernResultRow(label: "Debris Hauling", value: pricingModel.formatCurrency(pricingModel.debrisCost), icon: "cube.box")
                                }
                            }
                        }
                        
                        Divider()
                            .background(Color.white.opacity(0.2))
                        
                        // Additional deposit details
                        HStack {
                            Text("Balance at Completion")
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(Color.white.opacity(0.7))
                            
                            Spacer()
                            
                            Text(pricingModel.formatCurrency(pricingModel.balanceDue))
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(Color.white.opacity(0.9))
                        }
                    }
                    .transition(.opacity.combined(with: .move(edge: .top)))
                }
            }
        }
        .padding(24)
        .background(glassMorphismBackground)
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }
    
    
    // MARK: - Modern Input Components
    private func modernInputField(title: String, value: Binding<Double>, placeholder: String, suffix: String, icon: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(Color("TreeShopGreen"))
                .frame(width: 20)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(Color.white.opacity(0.7))
                
                HStack {
                    TextField(placeholder, value: value, formatter: numberFormatter(style: .decimal))
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.white)
                        .keyboardType(.decimalPad)
                    
                    Text(suffix)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(Color.white.opacity(0.5))
                }
            }
            
            Spacer()
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white.opacity(0.05))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.white.opacity(0.1), lineWidth: 1)
                )
        )
    }
    
    // MARK: - Compact Input Components (for side-by-side layout)
    private func compactInputField(title: String, value: Binding<Double>, placeholder: String, suffix: String, icon: String) -> some View {
        VStack(spacing: 8) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(Color("TreeShopGreen"))
                    .frame(width: 16)
                
                Text(title)
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(Color.white.opacity(0.7))
                
                Spacer()
            }
            
            HStack(spacing: 4) {
                TextField(placeholder, value: value, formatter: numberFormatter(style: .decimal))
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(.white)
                    .keyboardType(.decimalPad)
                    .multilineTextAlignment(.center)
                
                Text(suffix)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(Color.white.opacity(0.5))
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.white.opacity(0.05))
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.white.opacity(0.1), lineWidth: 1)
                    )
            )
        }
        .frame(maxWidth: .infinity)
    }
    
    private var compactZipCodeField: some View {
        VStack(spacing: 8) {
            HStack(spacing: 6) {
                Image(systemName: "location.fill")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(Color("TreeShopGreen"))
                    .frame(width: 16)
                
                Text("Project Zip")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(Color.white.opacity(0.7))
                
                Spacer()
                
                if pricingModel.isCalculatingDistance {
                    ProgressView()
                        .scaleEffect(0.6)
                        .foregroundColor(Color("TreeShopGreen"))
                }
            }
            
            HStack {
                TextField("12345", text: $pricingModel.projectZipCode)
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(.white)
                    .keyboardType(.numberPad)
                    .multilineTextAlignment(.center)
                    .onChange(of: pricingModel.projectZipCode) { oldValue, newValue in
                        // Auto-calculate when zip code is 5 digits
                        if newValue.count == 5 && !pricingModel.baseLocationAddress.isEmpty {
                            pricingModel.calculateTransportTime(for: newValue)
                        }
                    }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.white.opacity(0.05))
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.white.opacity(0.1), lineWidth: 1)
                    )
            )
        }
        .frame(maxWidth: .infinity)
    }
    
    private func modernResultRow(label: String, value: String, icon: String, isHighlighted: Bool = false, isTotal: Bool = false) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(isTotal ? Color("TreeShopGreen") : (isHighlighted ? Color(red: 1.0, green: 0.76, blue: 0.03) : Color.white.opacity(0.6)))
                .frame(width: 16)
            
            Text(label)
                .font(.system(size: isTotal ? 16 : 14, weight: isTotal ? .semibold : .medium))
                .foregroundColor(isTotal ? .white : Color.white.opacity(0.8))
            
            Spacer()
            
            Text(value)
                .font(.system(size: isTotal ? 18 : 15, weight: isTotal ? .bold : .semibold, design: .rounded))
                .foregroundColor(isTotal ? Color("TreeShopGreen") : .white)
        }
    }
    
    // MARK: - Customer Selection Card
    private var customerSelectionCard: some View {
        VStack(spacing: 16) {
            HStack {
                HStack(spacing: 10) {
                    Image(systemName: "person.2.fill")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(Color("TreeShopGreen"))
                    
                    Text("Customer")
                        .font(.system(size: 18, weight: .semibold, design: .rounded))
                        .foregroundColor(.white)
                }
                
                Spacer()
                
                // Save quote button - different text based on customer selection
                if pricingModel.landSize > 0 && pricingModel.finalPrice > 0 {
                    Button(action: {
                        if let customer = selectedCustomer {
                            // Save directly to selected customer
                            customerManager.createProjectFromQuote(customer.id, pricingModel: pricingModel, projectName: "Tree Service Quote")
                            showingQuoteSavedAlert = true
                            // Clear pricing fields for next quote
                            clearPricingFields()
                            let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
                            impactFeedback.impactOccurred()
                        } else {
                            // Show customer selection dialog
                            showingSaveQuote = true
                            let impactFeedback = UIImpactFeedbackGenerator(style: .light)
                            impactFeedback.impactOccurred()
                        }
                    }) {
                        HStack(spacing: 6) {
                            Image(systemName: selectedCustomer != nil ? "plus.circle.fill" : "square.and.arrow.down")
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(Color(red: 1.0, green: 0.76, blue: 0.03))
                            
                            Text(selectedCustomer != nil ? "Add Quote" : "Save")
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundColor(Color(red: 1.0, green: 0.76, blue: 0.03))
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(
                            RoundedRectangle(cornerRadius: 6)
                                .fill(Color(red: 1.0, green: 0.76, blue: 0.03).opacity(0.1))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 6)
                                        .stroke(Color(red: 1.0, green: 0.76, blue: 0.03).opacity(0.3), lineWidth: 1)
                                )
                        )
                    }
                    .buttonStyle(ScaleButtonStyle())
                }
            }
            
            if let customer = selectedCustomer {
                // Selected customer display
                HStack(spacing: 12) {
                    ZStack {
                        Circle()
                            .fill(Color("TreeShopGreen"))
                            .frame(width: 40, height: 40)
                        
                        Text(getInitials(customer.fullName))
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.white)
                    }
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(customer.fullName.isEmpty ? "No Name" : customer.fullName)
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.white)
                        
                        if !customer.email.isEmpty {
                            Text(customer.email)
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(Color.white.opacity(0.7))
                        }
                    }
                    
                    Spacer()
                    
                    Button(action: {
                        selectedCustomer = nil
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(Color.white.opacity(0.6))
                    }
                }
                .padding(16)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color("TreeShopGreen").opacity(0.1))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color("TreeShopGreen").opacity(0.3), lineWidth: 1)
                        )
                )
            } else {
                // No customer selected state
                Button(action: {
                    showingCustomers = true
                    let impactFeedback = UIImpactFeedbackGenerator(style: .light)
                    impactFeedback.impactOccurred()
                }) {
                    HStack(spacing: 12) {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(Color("TreeShopGreen"))
                        
                        Text("Select or Add Customer")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.white)
                        
                        Spacer()
                        
                        Image(systemName: "chevron.right")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(Color.white.opacity(0.4))
                    }
                    .padding(16)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.white.opacity(0.03))
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.white.opacity(0.1), lineWidth: 1)
                            )
                    )
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
        .padding(24)
        .background(glassMorphismBackground)
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }

    // Add these modern component placeholders for now
    private var modernPackagePicker: some View {
        packagePicker // Will update this separately
    }
    
    private var modernZipCodeField: some View {
        projectZipCodeField // Will update this separately  
    }
    
    private var modernTransportField: some View {
        transportHoursField // Will update this separately
    }
    
    // MARK: - Helper Functions
    private func getInitials(_ name: String) -> String {
        let components = name.components(separatedBy: " ")
        if components.count >= 2 {
            return "\(components[0].prefix(1))\(components[1].prefix(1))".uppercased()
        } else if let first = components.first, !first.isEmpty {
            return String(first.prefix(2)).uppercased()
        }
        return "??"
    }
    
    private func createNewCustomerWithQuote() {
        showingNewCustomer = true
    }
    
    private func saveAsProposal(title: String, description: String) {
        let proposal = proposalManager.createProposalFromPricing(
            pricingModel: pricingModel,
            customer: selectedCustomer,
            projectTitle: title,
            projectDescription: description
        )
        proposalManager.addProposal(proposal)
        showingSaveProposal = false
        showingQuoteSavedAlert = true
    }
    
    private func clearPricingFields() {
        pricingModel.landSize = 0.0
        pricingModel.projectZipCode = ""
        pricingModel.transportHours = 0.0
        pricingModel.debrisYards = 0.0
        pricingModel.selectedPackage = .medium
    }
    
    // MARK: - Custom Button Style
    struct ScaleButtonStyle: ButtonStyle {
        func makeBody(configuration: Configuration) -> some View {
            configuration.label
                .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
                .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
        }
    }
    
    // MARK: - Keyboard Dismissal
    private func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
    
    // MARK: - Number Formatter
    private func numberFormatter(style: NumberFormatter.Style) -> NumberFormatter {
        let formatter = NumberFormatter()
        formatter.numberStyle = style
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 2
        return formatter
    }
}

#Preview {
    ContentView()
        .environmentObject(CustomerManager())
        .preferredColorScheme(.dark)
}