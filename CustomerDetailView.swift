import SwiftUI

struct CustomerDetailView: View {
    let customer: Customer
    @ObservedObject var customerManager: CustomerManager
    @Environment(\.presentationMode) var presentationMode
    @State private var showingEditCustomer = false
    @State private var selectedProject: CustomerProject? = nil
    @State private var showingProjectActions = false
    @State private var showingDeleteAlert = false
    @State private var projectToDelete: CustomerProject? = nil
    @State private var showingStatusChange = false
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.black.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 20) {
                        // Customer Info Card
                        customerInfoCard
                        
                        // Projects Card
                        projectsCard
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 20)
                    .padding(.bottom, 30)
                }
            }
            .navigationTitle("Customer Details")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Close") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Edit") {
                        showingEditCustomer = true
                    }
                    .foregroundColor(Color("TreeShopGreen"))
                }
            }
        }
        .preferredColorScheme(.dark)
        .sheet(isPresented: $showingEditCustomer) {
            AddEditCustomerView(customerManager: customerManager, existingCustomer: customer)
        }
        .actionSheet(isPresented: $showingProjectActions) {
            ActionSheet(
                title: Text("Project Actions"),
                message: Text(selectedProject?.projectName ?? ""),
                buttons: [
                    .default(Text("Edit Project")) {
                        // Will implement project editing
                    },
                    .default(Text("Duplicate Project")) {
                        duplicateProject()
                    },
                    .default(Text("Change Status")) {
                        showingStatusChange = true
                    },
                    .destructive(Text("Delete Project")) {
                        projectToDelete = selectedProject
                        showingDeleteAlert = true
                    },
                    .cancel()
                ]
            )
        }
        .alert(isPresented: $showingDeleteAlert) {
            Alert(
                title: Text("Delete Project"),
                message: Text("Are you sure you want to delete '\(projectToDelete?.projectName ?? "")'? This action cannot be undone."),
                primaryButton: .destructive(Text("Delete")) {
                    deleteProject()
                },
                secondaryButton: .cancel()
            )
        }
        .actionSheet(isPresented: $showingStatusChange) {
            ActionSheet(
                title: Text("Change Project Status"),
                message: Text(selectedProject?.projectName ?? ""),
                buttons: ProjectStatus.allCases.map { status in
                    .default(Text(status.displayName)) {
                        changeProjectStatus(to: status)
                    }
                } + [.cancel()]
            )
        }
    }
    
    // MARK: - Customer Info Card
    private var customerInfoCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                HStack(spacing: 10) {
                    Image(systemName: "person.fill")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(Color("TreeShopGreen"))
                    
                    Text("Customer Information")
                        .font(.system(size: 18, weight: .semibold, design: .rounded))
                        .foregroundColor(.white)
                }
                Spacer()
            }
            
            VStack(spacing: 12) {
                if !customer.fullName.isEmpty {
                    infoRow(title: "Name", value: customer.fullName, icon: "person.fill")
                }
                if !customer.email.isEmpty {
                    infoRow(title: "Email", value: customer.email, icon: "envelope.fill")
                }
                if !customer.phone.isEmpty {
                    infoRow(title: "Phone", value: customer.phone, icon: "phone.fill")
                }
                if !customer.fullAddress.isEmpty {
                    infoRow(title: "Address", value: customer.fullAddress, icon: "location.fill")
                }
                infoRow(title: "Type", value: customer.customerType.displayName, icon: customer.customerType.iconName)
                infoRow(title: "Contact Method", value: customer.preferredContactMethod.displayName, icon: customer.preferredContactMethod.iconName)
            }
        }
        .padding(24)
        .background(glassMorphismBackground)
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }
    
    // MARK: - Projects Card
    private var projectsCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                HStack(spacing: 10) {
                    Image(systemName: "hammer.fill")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(Color(red: 1.0, green: 0.76, blue: 0.03))
                    
                    Text("Projects")
                        .font(.system(size: 18, weight: .semibold, design: .rounded))
                        .foregroundColor(.white)
                }
                
                Spacer()
                
                Text("\(customer.projects.count)")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(Color.white.opacity(0.7))
            }
            
            if customer.projects.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "hammer.slash")
                        .font(.system(size: 30, weight: .medium))
                        .foregroundColor(Color.white.opacity(0.4))
                    
                    Text("No projects yet")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(Color.white.opacity(0.7))
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 32)
            } else {
                LazyVStack(spacing: 12) {
                    ForEach(customer.projects) { project in
                        projectRow(project)
                    }
                }
            }
        }
        .padding(24)
        .background(glassMorphismBackground)
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }
    
    // MARK: - Helper Views
    private func infoRow(title: String, value: String, icon: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(Color("TreeShopGreen"))
                .frame(width: 16)
            
            Text(title)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(Color.white.opacity(0.7))
            
            Spacer()
            
            Text(value)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.white)
        }
    }
    
    private func projectRow(_ project: CustomerProject) -> some View {
        VStack(spacing: 8) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(project.projectName)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                    
                    Text(String(format: "%.1f acres • %@", project.landSize, project.packageType.displayName))
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(Color.white.opacity(0.7))
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text(formatCurrency(project.finalPrice))
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(Color("TreeShopGreen"))
                    
                    Text(project.projectStatus.displayName)
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(project.statusColor)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(project.statusColor.opacity(0.2))
                        .cornerRadius(4)
                }
            }
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
        .onLongPressGesture {
            selectedProject = project
            showingProjectActions = true
        }
    }
    
    // MARK: - Glassmorphism Background
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
    
    // MARK: - CRUD Functions
    private func duplicateProject() {
        guard let project = selectedProject else { return }
        
        var duplicatedProject = project
        duplicatedProject.id = UUID()
        duplicatedProject.projectName = "\(project.projectName) (Copy)"
        duplicatedProject.dateCreated = Date()
        duplicatedProject.projectStatus = .quoted
        
        customerManager.addProjectToCustomer(customer.id, project: duplicatedProject)
    }
    
    private func deleteProject() {
        guard let projectToDelete = projectToDelete else { return }
        
        if let customerIndex = customerManager.customers.firstIndex(where: { $0.id == customer.id }) {
            customerManager.customers[customerIndex].projects.removeAll { $0.id == projectToDelete.id }
            customerManager.customers[customerIndex].lastUpdated = Date()
            customerManager.saveCustomers()
        }
        
        self.projectToDelete = nil
    }
    
    private func changeProjectStatus(to status: ProjectStatus) {
        guard let project = selectedProject else { return }
        
        if let customerIndex = customerManager.customers.firstIndex(where: { $0.id == customer.id }),
           let projectIndex = customerManager.customers[customerIndex].projects.firstIndex(where: { $0.id == project.id }) {
            customerManager.customers[customerIndex].projects[projectIndex].projectStatus = status
            customerManager.customers[customerIndex].lastUpdated = Date()
            
            // Set completion date if marking as completed
            if status == .completed {
                customerManager.customers[customerIndex].projects[projectIndex].completedDate = Date()
            }
            
            customerManager.saveCustomers()
        }
    }
    
    // MARK: - Helper Functions
    private func formatCurrency(_ amount: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = Locale(identifier: "en_US")
        formatter.maximumFractionDigits = 0
        return formatter.string(from: NSNumber(value: amount)) ?? "$0"
    }
}

#Preview {
    CustomerDetailView(
        customer: Customer(
            firstName: "Frank",
            lastName: "Abignale",
            email: "frank@example.com",
            phone: "(555) 123-4567",
            address: "123 Main St",
            city: "Portland",
            state: "OR",
            zipCode: "97205"
        ),
        customerManager: CustomerManager()
    )
}