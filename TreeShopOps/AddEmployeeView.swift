import SwiftUI

struct AddEmployeeView: View {
    @EnvironmentObject var employeeManager: EmployeeManager
    @Environment(\.presentationMode) var presentationMode
    
    // Personal Info
    @State private var firstName = ""
    @State private var lastName = ""
    @State private var employeeNumber = ""
    @State private var email = ""
    @State private var phone = ""
    
    // Qualifications
    @State private var selectedRole = PrimaryRole.TRS
    @State private var tier = 2
    @State private var leadershipLevel = LeadershipLevel.none
    @State private var equipmentCertifications: Set<EquipmentLevel> = []
    @State private var driverClassification: DriverClass? = nil
    @State private var professionalCertifications: Set<ProfessionalCertification> = []
    
    // Compensation
    @State private var baseHourlyRate = ""
    
    var isFormValid: Bool {
        return !firstName.isEmpty &&
               !lastName.isEmpty &&
               !employeeNumber.isEmpty &&
               !baseHourlyRate.isEmpty &&
               Double(baseHourlyRate) ?? 0 > 0
    }
    
    var calculatedCost: EmployeeCalculation? {
        guard isFormValid else { return nil }
        
        let qualifications = EmployeeQualifications(
            primaryRole: selectedRole,
            tier: tier,
            leadershipLevel: leadershipLevel,
            equipmentCertifications: Array(equipmentCertifications),
            driverClassification: driverClassification,
            professionalCertifications: Array(professionalCertifications),
            crossTraining: [],
            specializations: []
        )
        
        let compensation = EmployeeCompensation(
            baseHourlyRate: Double(baseHourlyRate) ?? 0,
            overtime: 1.5,
            benefits: 0,
            workersComp: 0.05,
            payrollTaxes: 0.15,
            bonusStructure: nil,
            lastRaise: nil,
            nextReviewDate: nil
        )
        
        return EmployeeCalculationEngine.calculateTrueHourlyCost(
            qualifications: qualifications,
            compensation: compensation
        )
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                Color("TreeShopBlack").ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Personal Information Section
                        personalInfoSection
                        
                        // Role & Qualifications Section
                        qualificationsSection
                        
                        // Add-ons Section
                        addOnsSection
                        
                        // Compensation Section
                        compensationSection
                        
                        // Cost Calculation Preview
                        if let calculated = calculatedCost {
                            calculationPreviewSection(calculated)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 100)
                }
            }
            .navigationTitle("Add Employee")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(
                leading: Button("Cancel") {
                    presentationMode.wrappedValue.dismiss()
                }
                .foregroundColor(.white),
                
                trailing: Button("Save") {
                    saveEmployee()
                }
                .foregroundColor(isFormValid ? Color("TreeShopGreen") : .gray)
                .disabled(!isFormValid)
            )
        }
    }
    
    private var personalInfoSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            SectionHeader(title: "Personal Information", icon: "person.circle")
            
            VStack(spacing: 16) {
                HStack(spacing: 16) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("First Name")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(.gray)
                        
                        TextField("John", text: $firstName)
                            .textFieldStyle(EquipmentTextFieldStyle())
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Last Name")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(.gray)
                        
                        TextField("Smith", text: $lastName)
                            .textFieldStyle(EquipmentTextFieldStyle())
                    }
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Employee Number")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.gray)
                    
                    TextField("EMP001", text: $employeeNumber)
                        .textFieldStyle(EquipmentTextFieldStyle())
                }
                
                HStack(spacing: 16) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Email (Optional)")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(.gray)
                        
                        TextField("john@company.com", text: $email)
                            .textFieldStyle(EquipmentTextFieldStyle())
                            .keyboardType(.emailAddress)
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Phone (Optional)")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(.gray)
                        
                        TextField("555-123-4567", text: $phone)
                            .textFieldStyle(EquipmentTextFieldStyle())
                            .keyboardType(.phonePad)
                    }
                }
            }
        }
        .cardStyle()
    }
    
    private var qualificationsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            SectionHeader(title: "Role & Qualifications", icon: "person.badge.shield.checkmark")
            
            VStack(spacing: 16) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Primary Role")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.gray)
                    
                    Picker("Primary Role", selection: $selectedRole) {
                        ForEach(PrimaryRole.allCases, id: \.self) { role in
                            Text("\(role.rawValue) - \(role.fullName)").tag(role)
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
                
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("Tier Level")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(.gray)
                        
                        Spacer()
                        
                        Text("Tier \(tier)")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(Color("TreeShopGreen"))
                    }
                    
                    Slider(value: Binding(
                        get: { Double(tier) },
                        set: { tier = Int($0) }
                    ), in: 1...5, step: 1)
                    .accentColor(Color("TreeShopGreen"))
                    
                    HStack {
                        Text("1 - Entry")
                            .font(.caption)
                            .foregroundColor(.gray)
                        Spacer()
                        Text("5 - Expert")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                }
            }
        }
        .cardStyle()
    }
    
    private var addOnsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            SectionHeader(title: "Add-ons & Certifications", icon: "plus.circle")
            
            VStack(spacing: 16) {
                // Leadership Level
                VStack(alignment: .leading, spacing: 8) {
                    Text("Leadership Level")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.gray)
                    
                    Picker("Leadership", selection: $leadershipLevel) {
                        ForEach(LeadershipLevel.allCases, id: \.self) { level in
                            Text(level.fullName).tag(level)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }
                
                // Equipment Certifications
                VStack(alignment: .leading, spacing: 8) {
                    Text("Equipment Certifications")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.gray)
                    
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 8) {
                        ForEach(EquipmentLevel.allCases, id: \.self) { level in
                            Button(action: {
                                if equipmentCertifications.contains(level) {
                                    equipmentCertifications.remove(level)
                                } else {
                                    equipmentCertifications.insert(level)
                                }
                            }) {
                                HStack {
                                    Image(systemName: equipmentCertifications.contains(level) ? 
                                          "checkmark.square.fill" : "square")
                                        .foregroundColor(equipmentCertifications.contains(level) ? 
                                                       Color("TreeShopGreen") : .gray)
                                    
                                    Text(level.rawValue)
                                        .font(.caption)
                                        .foregroundColor(.white)
                                    
                                    Spacer()
                                }
                                .padding(.horizontal, 12)
                                .padding(.vertical, 8)
                                .background(
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(Color.white.opacity(0.05))
                                )
                            }
                        }
                    }
                }
                
                // Driver Classification
                VStack(alignment: .leading, spacing: 8) {
                    Text("Driver Classification")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.gray)
                    
                    HStack(spacing: 8) {
                        Button("None") {
                            driverClassification = nil
                        }
                        .foregroundColor(driverClassification == nil ? .black : .white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(
                            RoundedRectangle(cornerRadius: 6)
                                .fill(driverClassification == nil ? Color("TreeShopGreen") : Color.white.opacity(0.1))
                        )
                        
                        ForEach(DriverClass.allCases, id: \.self) { driverClass in
                            Button(driverClass.rawValue) {
                                driverClassification = driverClassification == driverClass ? nil : driverClass
                            }
                            .foregroundColor(driverClassification == driverClass ? .black : .white)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(
                                RoundedRectangle(cornerRadius: 6)
                                    .fill(driverClassification == driverClass ? Color("TreeShopGreen") : Color.white.opacity(0.1))
                            )
                        }
                        
                        Spacer()
                    }
                }
                
                // Professional Certifications
                VStack(alignment: .leading, spacing: 8) {
                    Text("Professional Certifications")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.gray)
                    
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 8) {
                        ForEach(Array(ProfessionalCertification.allCases.prefix(9)), id: \.self) { cert in
                            Button(action: {
                                if professionalCertifications.contains(cert) {
                                    professionalCertifications.remove(cert)
                                } else {
                                    professionalCertifications.insert(cert)
                                }
                            }) {
                                VStack(spacing: 4) {
                                    Image(systemName: professionalCertifications.contains(cert) ? 
                                          "checkmark.circle.fill" : "circle")
                                        .foregroundColor(professionalCertifications.contains(cert) ? 
                                                       Color("TreeShopGreen") : .gray)
                                    
                                    Text(cert.rawValue)
                                        .font(.caption2)
                                        .foregroundColor(.white)
                                }
                                .padding(8)
                                .background(
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(Color.white.opacity(0.05))
                                )
                            }
                        }
                    }
                }
            }
        }
        .cardStyle()
    }
    
    private var compensationSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            SectionHeader(title: "Compensation", icon: "dollarsign.circle")
            
            VStack(spacing: 16) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Base Hourly Rate")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.gray)
                    
                    TextField("25.00", text: $baseHourlyRate)
                        .textFieldStyle(EquipmentTextFieldStyle())
                        .keyboardType(.decimalPad)
                }
            }
        }
        .cardStyle()
    }
    
    private func calculationPreviewSection(_ calculated: EmployeeCalculation) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            SectionHeader(title: "Cost Analysis", icon: "chart.bar.fill")
            
            VStack(spacing: 16) {
                // Key metrics
                HStack(spacing: 16) {
                    VStack(spacing: 4) {
                        Text("True Cost")
                            .font(.caption)
                            .foregroundColor(.gray)
                        Text(calculated.trueHourlyCost.asCurrencyWithCents)
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(Color("TreeShopGreen"))
                    }
                    .frame(maxWidth: .infinity)
                    
                    VStack(spacing: 4) {
                        Text("Billing Rate")
                            .font(.caption)
                            .foregroundColor(.gray)
                        Text(calculated.billingRate.asCurrencyWithCents)
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                    }
                    .frame(maxWidth: .infinity)
                    
                    VStack(spacing: 4) {
                        Text("Profit Margin")
                            .font(.caption)
                            .foregroundColor(.gray)
                        Text(calculated.profitMargin.asPercentage)
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
                    Text("Cost Breakdown")
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                    
                    VStack(spacing: 6) {
                        HStack {
                            Text("Base Rate × Multiplier")
                                .foregroundColor(.gray)
                            Spacer()
                            Text((Double(baseHourlyRate) ?? 0 * calculated.baseMultiplier).asCurrencyWithCents)
                                .foregroundColor(.white)
                        }
                        
                        if calculated.leadershipPremium > 0 {
                            HStack {
                                Text("Leadership Premium")
                                    .foregroundColor(.gray)
                                Spacer()
                                Text("+\(calculated.leadershipPremium.asCurrencyWithCents)")
                                    .foregroundColor(Color("TreeShopGreen"))
                            }
                        }
                        
                        if calculated.equipmentPremium > 0 {
                            HStack {
                                Text("Equipment Certifications")
                                    .foregroundColor(.gray)
                                Spacer()
                                Text("+\(calculated.equipmentPremium.asCurrencyWithCents)")
                                    .foregroundColor(Color("TreeShopGreen"))
                            }
                        }
                        
                        if calculated.driverPremium > 0 {
                            HStack {
                                Text("Driver Classification")
                                    .foregroundColor(.gray)
                                Spacer()
                                Text("+\(calculated.driverPremium.asCurrencyWithCents)")
                                    .foregroundColor(Color("TreeShopGreen"))
                            }
                        }
                        
                        if calculated.certificationPremium > 0 {
                            HStack {
                                Text("Professional Certifications")
                                    .foregroundColor(.gray)
                                Spacer()
                                Text("+\(calculated.certificationPremium.asCurrencyWithCents)")
                                    .foregroundColor(Color("TreeShopGreen"))
                            }
                        }
                        
                        Divider()
                            .background(Color.white.opacity(0.2))
                        
                        HStack {
                            Text("True Hourly Cost")
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                            Spacer()
                            Text(calculated.trueHourlyCost.asCurrencyWithCents)
                                .fontWeight(.bold)
                                .foregroundColor(Color("TreeShopGreen"))
                        }
                    }
                    .font(.subheadline)
                }
                
                // Qualification code preview
                let qualCode = EmployeeQualificationCodeBuilder.buildCode(from: EmployeeQualifications(
                    primaryRole: selectedRole,
                    tier: tier,
                    leadershipLevel: leadershipLevel,
                    equipmentCertifications: Array(equipmentCertifications),
                    driverClassification: driverClassification,
                    professionalCertifications: Array(professionalCertifications),
                    crossTraining: [],
                    specializations: []
                ))
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Qualification Code")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                    
                    Text(qualCode)
                        .font(.system(.title3, design: .monospaced))
                        .fontWeight(.medium)
                        .foregroundColor(Color("TreeShopGreen"))
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
        .cardStyle()
    }
    
    private func saveEmployee() {
        guard isFormValid else { return }
        
        let personalInfo = EmployeePersonalInfo(
            firstName: firstName,
            lastName: lastName,
            employeeNumber: employeeNumber,
            email: email.isEmpty ? nil : email,
            phone: phone.isEmpty ? nil : phone,
            emergencyContact: nil,
            address: nil
        )
        
        let qualifications = EmployeeQualifications(
            primaryRole: selectedRole,
            tier: tier,
            leadershipLevel: leadershipLevel,
            equipmentCertifications: Array(equipmentCertifications),
            driverClassification: driverClassification,
            professionalCertifications: Array(professionalCertifications),
            crossTraining: [],
            specializations: []
        )
        
        let compensation = EmployeeCompensation(
            baseHourlyRate: Double(baseHourlyRate) ?? 0,
            overtime: 1.5,
            benefits: 0,
            workersComp: 0.05,
            payrollTaxes: 0.15,
            bonusStructure: nil,
            lastRaise: nil,
            nextReviewDate: Calendar.current.date(byAdding: .month, value: 6, to: Date())
        )
        
        let newEmployee = Employee(
            personalInfo: personalInfo,
            qualifications: qualifications,
            compensation: compensation
        )
        
        employeeManager.addEmployee(newEmployee)
        presentationMode.wrappedValue.dismiss()
    }
}

#Preview {
    AddEmployeeView()
        .environmentObject(EmployeeManager())
}