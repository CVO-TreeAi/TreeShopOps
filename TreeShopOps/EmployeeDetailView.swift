import SwiftUI

struct EmployeeDetailView: View {
    let employee: Employee
    @EnvironmentObject var employeeManager: EmployeeManager
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
                        
                        // Qualification overview
                        qualificationOverviewCard
                        
                        // Cost analysis
                        costAnalysisCard
                        
                        // Performance metrics
                        performanceMetricsCard
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 100)
                }
            }
            .navigationTitle("Employee Details")
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
                        Label("Edit Employee", systemImage: "pencil")
                    }
                    
                    Button(action: {
                        // TODO: Assign to loadout
                    }) {
                        Label("Assign to Loadout", systemImage: "rectangle.3.group")
                    }
                    
                    Button(role: .destructive, action: {
                        showingDeleteConfirm = true
                    }) {
                        Label("Remove Employee", systemImage: "trash")
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                        .foregroundColor(Color("TreeShopGreen"))
                }
            )
        }
        .sheet(isPresented: $showingEditForm) {
            // TODO: Edit employee form
            Text("Edit Employee - Coming Soon")
        }
        .alert("Remove Employee", isPresented: $showingDeleteConfirm) {
            Button("Cancel", role: .cancel) { }
            Button("Remove", role: .destructive) {
                employeeManager.deleteEmployee(employee)
                presentationMode.wrappedValue.dismiss()
            }
        } message: {
            Text("Are you sure you want to remove \(employee.fullName) from the system? This action cannot be undone.")
        }
    }
    
    private var headerCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 8) {
                    Text(employee.fullName)
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    Text(employee.qualifications.primaryRole.fullName)
                        .font(.subheadline)
                        .foregroundColor(.gray)
                    
                    Text("Employee #\(employee.personalInfo.employeeNumber)")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 8) {
                    // Status badge
                    HStack(spacing: 6) {
                        Image(systemName: employee.metadata.status.systemImage)
                            .font(.caption)
                        Text(employee.metadata.status.rawValue)
                            .font(.caption)
                            .fontWeight(.semibold)
                    }
                    .foregroundColor(Color(employee.metadata.status.color))
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color(employee.metadata.status.color).opacity(0.2))
                    )
                    
                    // Tier level
                    Text("Tier \(employee.qualifications.tier)")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(Color("TreeShopBlue"))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(
                            RoundedRectangle(cornerRadius: 6)
                                .fill(Color("TreeShopBlue").opacity(0.2))
                        )
                }
            }
            
            // Qualification Code
            VStack(alignment: .leading, spacing: 8) {
                Text("Qualification Code")
                    .font(.caption)
                    .foregroundColor(.gray)
                
                Text(employee.qualificationCode)
                    .font(.title3)
                    .fontWeight(.monospaced(.semibold))
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
        .cardStyle()
    }
    
    private var qualificationOverviewCard: some View {
        DetailCard(title: "Qualifications", icon: "person.badge.shield.checkmark.fill") {
            VStack(alignment: .leading, spacing: 12) {
                // Primary role and tier
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Primary Role")
                            .font(.caption)
                            .foregroundColor(.gray)
                        Text("\(employee.qualifications.primaryRole.rawValue) - \(employee.qualifications.primaryRole.fullName)")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(.white)
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing, spacing: 2) {
                        Text("Tier Level")
                            .font(.caption)
                            .foregroundColor(.gray)
                        Text("Tier \(employee.qualifications.tier)")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(Color("TreeShopBlue"))
                    }
                }
                
                // Leadership
                if employee.qualifications.leadershipLevel != .none {
                    EmployeeDetailRow(
                        title: "Leadership",
                        value: employee.qualifications.leadershipLevel.fullName
                    )
                }
                
                // Equipment Certifications
                if !employee.qualifications.equipmentCertifications.isEmpty {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Equipment Certifications")
                            .font(.caption)
                            .foregroundColor(.gray)
                        
                        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 4) {
                            ForEach(employee.qualifications.equipmentCertifications, id: \.self) { cert in
                                Text(cert.rawValue)
                                    .font(.caption)
                                    .foregroundColor(Color("TreeShopGreen"))
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 2)
                                    .background(
                                        RoundedRectangle(cornerRadius: 4)
                                            .fill(Color("TreeShopGreen").opacity(0.2))
                                    )
                            }
                        }
                    }
                }
                
                // Driver Classification
                if let driver = employee.qualifications.driverClassification {
                    EmployeeDetailRow(
                        title: "Driver License",
                        value: driver.description
                    )
                }
                
                // Professional Certifications
                if !employee.qualifications.professionalCertifications.isEmpty {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Professional Certifications")
                            .font(.caption)
                            .foregroundColor(.gray)
                        
                        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 4) {
                            ForEach(employee.qualifications.professionalCertifications, id: \.self) { cert in
                                Text(cert.rawValue)
                                    .font(.caption2)
                                    .foregroundColor(Color("TreeShopBlue"))
                                    .padding(.horizontal, 6)
                                    .padding(.vertical, 2)
                                    .background(
                                        RoundedRectangle(cornerRadius: 4)
                                            .fill(Color("TreeShopBlue").opacity(0.2))
                                    )
                            }
                        }
                    }
                }
            }
        }
    }
    
    private var costAnalysisCard: some View {
        DetailCard(title: "Cost Analysis", icon: "dollarsign.circle.fill") {
            if let calculated = employee.calculated {
                VStack(alignment: .leading, spacing: 12) {
                    // Key metrics
                    HStack(spacing: 16) {
                        VStack(spacing: 4) {
                            Text("Base Rate")
                                .font(.caption)
                                .foregroundColor(.gray)
                            Text(employee.compensation.baseHourlyRate.asCurrencyWithCents)
                                .font(.headline)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                        }
                        .frame(maxWidth: .infinity)
                        
                        VStack(spacing: 4) {
                            Text("True Cost")
                                .font(.caption)
                                .foregroundColor(.gray)
                            Text(calculated.trueHourlyCost.asCurrencyWithCents)
                                .font(.headline)
                                .fontWeight(.bold)
                                .foregroundColor(Color("TreeShopGreen"))
                        }
                        .frame(maxWidth: .infinity)
                        
                        VStack(spacing: 4) {
                            Text("Billing Rate")
                                .font(.caption)
                                .foregroundColor(.gray)
                            Text(calculated.billingRate.asCurrencyWithCents)
                                .font(.headline)
                                .fontWeight(.bold)
                                .foregroundColor(Color("TreeShopBlue"))
                        }
                        .frame(maxWidth: .infinity)
                    }
                    .padding(16)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.white.opacity(0.03))
                    )
                    
                    // Cost breakdown
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Cost Breakdown")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(.white)
                        
                        VStack(spacing: 6) {
                            if calculated.leadershipPremium > 0 {
                                HStack {
                                    Text("Leadership Premium")
                                        .foregroundColor(.gray)
                                    Spacer()
                                    Text("+\(calculated.leadershipPremium.asCurrencyWithCents)/hr")
                                        .foregroundColor(Color("TreeShopGreen"))
                                }
                            }
                            
                            if calculated.equipmentPremium > 0 {
                                HStack {
                                    Text("Equipment Certifications")
                                        .foregroundColor(.gray)
                                    Spacer()
                                    Text("+\(calculated.equipmentPremium.asCurrencyWithCents)/hr")
                                        .foregroundColor(Color("TreeShopGreen"))
                                }
                            }
                            
                            if calculated.driverPremium > 0 {
                                HStack {
                                    Text("Driver Premium")
                                        .foregroundColor(.gray)
                                    Spacer()
                                    Text("+\(calculated.driverPremium.asCurrencyWithCents)/hr")
                                        .foregroundColor(Color("TreeShopGreen"))
                                }
                            }
                            
                            if calculated.certificationPremium > 0 {
                                HStack {
                                    Text("Professional Certifications")
                                        .foregroundColor(.gray)
                                    Spacer()
                                    Text("+\(calculated.certificationPremium.asCurrencyWithCents)/hr")
                                        .foregroundColor(Color("TreeShopGreen"))
                                }
                            }
                        }
                        .font(.caption)
                    }
                    
                    // Annual cost projection
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Annual Projections")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(.white)
                        
                        VStack(spacing: 6) {
                            HStack {
                                Text("Annual Cost (2080 hrs)")
                                    .foregroundColor(.gray)
                                Spacer()
                                Text(calculated.annualCost.asCurrency)
                                    .foregroundColor(.white)
                            }
                            
                            HStack {
                                Text("Profit Margin")
                                    .foregroundColor(.gray)
                                Spacer()
                                Text(calculated.profitMargin.asPercentage)
                                    .foregroundColor(Color("TreeShopGreen"))
                            }
                        }
                        .font(.caption)
                    }
                }
            }
        }
    }
    
    private var performanceMetricsCard: some View {
        DetailCard(title: "Performance Metrics", icon: "chart.line.uptrend.xyaxis") {
            VStack(alignment: .leading, spacing: 12) {
                // Performance rating
                VStack(alignment: .leading, spacing: 4) {
                    Text("Performance Rating")
                        .font(.caption)
                        .foregroundColor(.gray)
                    
                    HStack {
                        HStack(spacing: 2) {
                            ForEach(0..<5) { index in
                                Image(systemName: "star.fill")
                                    .font(.subheadline)
                                    .foregroundColor(
                                        Double(index) < employee.metadata.performanceRating ? 
                                        Color("TreeShopGreen") : Color.gray.opacity(0.3)
                                    )
                            }
                        }
                        
                        Spacer()
                        
                        Text(String(format: "%.1f/5.0", employee.metadata.performanceRating))
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(.white)
                    }
                }
                
                EmployeeDetailRow(title: "Years of Service", value: "\(employee.metadata.yearsOfService) years")
                EmployeeDetailRow(title: "Hours This Month", value: employee.metadata.hoursThisMonth.asHours)
                EmployeeDetailRow(title: "Total Hours Worked", value: employee.metadata.totalHoursWorked.asHours)
                EmployeeDetailRow(title: "Utilization Rate", value: employee.metadata.utilizationRate.asPercentage)
                
                if employee.metadata.safetyRecord > 0 {
                    EmployeeDetailRow(title: "Safety Record", value: "\(Int(employee.metadata.safetyRecord)) days incident-free")
                }
                
                if let customerRating = employee.metadata.customerRating {
                    EmployeeDetailRow(title: "Customer Rating", value: String(format: "%.1f/5.0", customerRating))
                }
            }
        }
    }
}

struct EmployeeDetailRow: View {
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

#Preview {
    let sampleEmployee = Employee(
        personalInfo: EmployeePersonalInfo(
            firstName: "John",
            lastName: "Smith",
            employeeNumber: "EMP001",
            email: "john@treeshop.com",
            phone: "555-123-4567",
            emergencyContact: nil,
            address: nil
        ),
        qualifications: EmployeeQualifications(
            primaryRole: .TRS,
            tier: 4,
            leadershipLevel: .supervisor,
            equipmentCertifications: [.E3],
            driverClassification: .D3,
            professionalCertifications: [.CRA, .ISA],
            crossTraining: [],
            specializations: []
        ),
        compensation: EmployeeCompensation(
            baseHourlyRate: 25.0,
            overtime: 1.5,
            benefits: 0,
            workersComp: 0.05,
            payrollTaxes: 0.15,
            bonusStructure: nil,
            lastRaise: nil,
            nextReviewDate: nil
        )
    )
    
    EmployeeDetailView(employee: sampleEmployee)
        .environmentObject(EmployeeManager())
}