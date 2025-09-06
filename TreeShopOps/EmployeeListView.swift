import SwiftUI

struct EmployeeListView: View {
    @EnvironmentObject var employeeManager: EmployeeManager
    @State private var searchText = ""
    @State private var selectedRole: PrimaryRole? = nil
    @State private var selectedStatus: EmployeeStatus? = nil
    @State private var showingAddEmployee = false
    @State private var selectedEmployee: Employee? = nil
    @State private var showingEmployeeDetail = false
    
    var filteredEmployees: [Employee] {
        var employees = employeeManager.employees
        
        // Filter by role
        if let role = selectedRole {
            employees = employees.filter { $0.qualifications.primaryRole == role }
        }
        
        // Filter by status
        if let status = selectedStatus {
            employees = employees.filter { $0.metadata.status == status }
        }
        
        // Filter by search text
        if !searchText.isEmpty {
            employees = employeeManager.searchEmployees(searchText)
        }
        
        return employees.sorted { $0.personalInfo.lastName < $1.personalInfo.lastName }
    }
    
    var body: some View {
        ZStack {
            Color("TreeShopBlack").ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header with stats
                headerSection
                
                // Filter section
                filterSection
                
                // Employee list
                employeeList
            }
        }
        .navigationTitle("Employees")
        .navigationBarTitleDisplayMode(.large)
        .navigationBarItems(
            trailing: Button(action: {
                showingAddEmployee = true
            }) {
                Image(systemName: "person.badge.plus.fill")
                    .foregroundColor(Color("TreeShopGreen"))
                    .font(.title2)
            }
        )
        .sheet(isPresented: $showingAddEmployee) {
            AddEmployeeView()
                .environmentObject(employeeManager)
        }
        .sheet(isPresented: $showingEmployeeDetail) {
            if let employee = selectedEmployee {
                EmployeeDetailView(employee: employee)
                    .environmentObject(employeeManager)
            }
        }
        .searchable(text: $searchText, prompt: "Search employees...")
    }
    
    private var headerSection: some View {
        let stats = employeeManager.getWorkforceStats()
        
        return VStack(spacing: 16) {
            // Workforce overview stats
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: 3), spacing: 12) {
                StandardStatCard(
                    title: "Total Employees",
                    value: "\(stats.totalCount)",
                    icon: "person.3",
                    color: Color("TreeShopBlue")
                )
                
                StandardStatCard(
                    title: "Available Now",
                    value: "\(stats.availableCount)",
                    icon: "person.check",
                    color: Color("TreeShopGreen")
                )
                
                StandardStatCard(
                    title: "Avg Rate/Hr",
                    value: stats.averageHourlyRate.asCurrencyWithCents,
                    icon: "dollarsign.circle",
                    color: .orange
                )
            }
            .padding(.horizontal, 20)
        }
        .padding(.top, 20)
    }
    
    private var filterSection: some View {
        VStack(spacing: 12) {
            // Role filter
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    EmployeeFilterChip(
                        title: "All Roles",
                        isSelected: selectedRole == nil
                    ) {
                        selectedRole = nil
                    }
                    
                    ForEach(PrimaryRole.allCases.prefix(8), id: \.self) { role in
                        EmployeeFilterChip(
                            title: role.rawValue,
                            isSelected: selectedRole == role,
                            color: Color("TreeShopGreen")
                        ) {
                            selectedRole = selectedRole == role ? nil : role
                        }
                    }
                }
                .padding(.horizontal, 20)
            }
            
            // Status filter
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    EmployeeFilterChip(
                        title: "All Status",
                        isSelected: selectedStatus == nil
                    ) {
                        selectedStatus = nil
                    }
                    
                    ForEach([EmployeeStatus.active, .onProject, .onLeave, .unavailable], id: \.self) { status in
                        EmployeeFilterChip(
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
    
    private var employeeList: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                if filteredEmployees.isEmpty {
                    emptyStateView
                } else {
                    ForEach(filteredEmployees) { employee in
                        EmployeeRowView(employee: employee) {
                            selectedEmployee = employee
                            showingEmployeeDetail = true
                        }
                        .contextMenu {
                            Button(action: {
                                selectedEmployee = employee
                                showingEmployeeDetail = true
                            }) {
                                Label("View Details", systemImage: "eye")
                            }
                            
                            Button(action: {
                                // TODO: Edit employee
                            }) {
                                Label("Edit Employee", systemImage: "pencil")
                            }
                            
                            if employee.metadata.status == .active {
                                Button(action: {
                                    // TODO: Assign to project
                                }) {
                                    Label("Assign to Project", systemImage: "hammer")
                                }
                            }
                            
                            Button(role: .destructive, action: {
                                employeeManager.deleteEmployee(employee)
                            }) {
                                Label("Remove", systemImage: "trash")
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
            Image(systemName: "person.3.sequence.fill")
                .font(.system(size: 60))
                .foregroundColor(.gray)
            
            VStack(spacing: 8) {
                Text("No Employees Found")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                
                Text(searchText.isEmpty && selectedRole == nil && selectedStatus == nil ? 
                     "Add your first employee to get started" : 
                     "No employees match your search or filter")
                    .font(.body)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
            }
            
            Button(action: {
                showingAddEmployee = true
            }) {
                HStack {
                    Image(systemName: "person.badge.plus.fill")
                    Text("Add Employee")
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

struct EmployeeFilterChip: View {
    let title: String
    let isSelected: Bool
    let color: Color
    let action: () -> Void
    
    init(title: String, isSelected: Bool, color: Color = Color("TreeShopBlue"), action: @escaping () -> Void) {
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

struct EmployeeRowView: View {
    let employee: Employee
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            employeeCardContent
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private var employeeCardContent: some View {
        VStack(alignment: .leading, spacing: 12) {
                // Header row
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(employee.fullName)
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                        
                        Text(employee.qualifications.primaryRole.fullName)
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing, spacing: 4) {
                        // Status badge
                        HStack(spacing: 4) {
                            Image(systemName: employee.metadata.status.systemImage)
                                .font(.caption)
                            Text(employee.metadata.status.rawValue)
                                .font(.caption)
                                .fontWeight(.medium)
                        }
                        .foregroundColor(Color(employee.metadata.status.color))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(
                            RoundedRectangle(cornerRadius: 6)
                                .fill(Color(employee.metadata.status.color).opacity(0.2))
                        )
                        
                        // Tier badge
                        Text("Tier \(employee.qualifications.tier)")
                            .font(.caption)
                            .foregroundColor(Color("TreeShopBlue"))
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(
                                RoundedRectangle(cornerRadius: 4)
                                    .fill(Color("TreeShopBlue").opacity(0.2))
                            )
                    }
                }
                
                // Qualification code
                HStack {
                    Text("Qualification:")
                        .font(.caption)
                        .foregroundColor(.gray)
                    
                    Text(employee.qualificationCode)
                        .font(.system(.caption, design: .monospaced))
                        .fontWeight(.medium)
                        .foregroundColor(Color("TreeShopGreen"))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(
                            RoundedRectangle(cornerRadius: 4)
                                .fill(Color("TreeShopGreen").opacity(0.1))
                        )
                    
                    Spacer()
                }
                
                // Metrics row
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("True Cost")
                            .font(.caption)
                            .foregroundColor(.gray)
                        Text(employee.calculated?.trueHourlyCost.asCurrencyWithCents ?? "$0.00")
                            .font(.headline)
                            .fontWeight(.bold)
                            .foregroundColor(Color("TreeShopGreen"))
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .center, spacing: 2) {
                        Text("Billing Rate")
                            .font(.caption)
                            .foregroundColor(.gray)
                        Text(employee.calculated?.billingRate.asCurrencyWithCents ?? "$0.00")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing, spacing: 2) {
                        Text("Performance")
                            .font(.caption)
                            .foregroundColor(.gray)
                        HStack(spacing: 2) {
                            ForEach(0..<5) { index in
                                Image(systemName: "star.fill")
                                    .font(.caption2)
                                    .foregroundColor(
                                        Double(index) < employee.metadata.performanceRating ? 
                                        Color("TreeShopGreen") : Color.gray.opacity(0.3)
                                    )
                            }
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
                            .stroke(Color(employee.metadata.status.color).opacity(0.3), lineWidth: 1)
                    )
            )
        }
}

#Preview {
    NavigationView {
        EmployeeListView()
            .environmentObject(EmployeeManager())
    }
}