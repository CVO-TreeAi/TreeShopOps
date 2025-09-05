import SwiftUI

struct CustomerListView: View {
    @EnvironmentObject var customerManager: CustomerManager
    @State private var searchText = ""
    @State private var showingAddCustomer = false
    @State private var selectedCustomer: Customer? = nil
    @State private var showingCustomerDetail = false
    
    var onCustomerSelected: ((Customer) -> Void)? = nil
    @Environment(\.presentationMode) var presentationMode
    
    init(onCustomerSelected: ((Customer) -> Void)? = nil) {
        self.onCustomerSelected = onCustomerSelected
    }
    
    var filteredCustomers: [Customer] {
        let customers = customerManager.searchCustomers(searchText)
        return customers.sorted { $0.lastUpdated > $1.lastUpdated }
    }
    
    var body: some View {
        ZStack {
            Color("TreeShopBlack").ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header with stats
                headerSection
                
                // Customers list
                customersList
            }
        }
        .navigationTitle("Customers")
        .navigationBarTitleDisplayMode(.large)
        .navigationBarItems(
            trailing: Button(action: {
                showingAddCustomer = true
            }) {
                Image(systemName: "plus.circle.fill")
                    .font(.title2)
                    .foregroundColor(Color("TreeShopGreen"))
            }
        )
        .sheet(isPresented: $showingAddCustomer) {
            AddEditCustomerView(customerManager: customerManager)
                .environmentObject(customerManager)
        }
        .sheet(isPresented: $showingCustomerDetail) {
            if let customer = selectedCustomer {
                CustomerDetailView(customer: customer, customerManager: customerManager)
            }
        }
        .searchable(text: $searchText, prompt: "Search customers...")
    }
    
    private var headerSection: some View {
        VStack(spacing: 16) {
            // Stats cards
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: 2), spacing: 12) {
                CustomerStatCard(
                    title: "Total Customers",
                    value: "\(customerManager.customers.count)",
                    icon: "person.2.fill",
                    color: .gray
                )
                
                CustomerStatCard(
                    title: "Residential",
                    value: "\(customerManager.getCustomersByType(.residential).count)",
                    icon: "house.fill",
                    color: Color("TreeShopBlue")
                )
                
                CustomerStatCard(
                    title: "Commercial",
                    value: "\(customerManager.getCustomersByType(.commercial).count)",
                    icon: "building.2.fill",
                    color: Color("TreeShopGreen")
                )
                
                CustomerStatCard(
                    title: "Total Projects",
                    value: "\(customerManager.customers.reduce(0) { $0 + $1.projects.count })",
                    icon: "hammer.fill",
                    color: .orange
                )
            }
            .padding(.horizontal, 20)
        }
        .padding(.top, 20)
    }
    
    private var customersList: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                if filteredCustomers.isEmpty {
                    emptyStateView
                } else {
                    ForEach(filteredCustomers) { customer in
                        CustomerRowView(customer: customer) {
                            if let onSelect = onCustomerSelected {
                                onSelect(customer)
                                presentationMode.wrappedValue.dismiss()
                            } else {
                                selectedCustomer = customer
                                showingCustomerDetail = true
                            }
                        }
                        .contextMenu {
                            Button(action: {
                                selectedCustomer = customer
                                showingAddCustomer = true
                            }) {
                                Label("Edit", systemImage: "pencil")
                            }
                            
                            Button(role: .destructive, action: {
                                withAnimation(.spring()) {
                                    customerManager.deleteCustomer(customer)
                                }
                            }) {
                                Label("Delete", systemImage: "trash")
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
            Image(systemName: "person.2.badge.plus")
                .font(.system(size: 60))
                .foregroundColor(.gray)
            
            VStack(spacing: 8) {
                Text("No Customers Found")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                
                Text(searchText.isEmpty ? "Add your first customer to get started" : "No customers match your search")
                    .font(.body)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
            }
            
            if searchText.isEmpty {
                Button(action: {
                    showingAddCustomer = true
                }) {
                    HStack {
                        Image(systemName: "plus.circle.fill")
                        Text("Add Customer")
                    }
                    .font(.headline)
                    .foregroundColor(.black)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                    .background(Color("TreeShopGreen"))
                    .cornerRadius(12)
                }
            }
        }
        .padding(.vertical, 60)
    }
}

struct CustomerStatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title)
                .foregroundColor(color)
            
            VStack(spacing: 4) {
                Text(value)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                Text(title)
                    .font(.caption)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
            }
        }
        .frame(maxWidth: .infinity)
        .frame(height: 100)
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white.opacity(0.05))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(color.opacity(0.2), lineWidth: 1)
                )
        )
    }
}

struct CustomerRowView: View {
    let customer: Customer
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 12) {
                // Header row
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(customer.fullName.isEmpty ? "New Customer" : customer.fullName)
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .lineLimit(1)
                        
                        if !customer.email.isEmpty {
                            Text(customer.email)
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing, spacing: 4) {
                        // Customer type badge
                        HStack(spacing: 4) {
                            Image(systemName: customer.customerType == .residential ? "house.fill" : "building.2.fill")
                                .font(.caption)
                            Text(customer.customerType.rawValue)
                                .font(.caption)
                                .fontWeight(.medium)
                        }
                        .foregroundColor(customer.customerType == .residential ? Color("TreeShopBlue") : Color("TreeShopGreen"))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(
                            RoundedRectangle(cornerRadius: 6)
                                .fill((customer.customerType == .residential ? Color("TreeShopBlue") : Color("TreeShopGreen")).opacity(0.2))
                        )
                        
                        // Project count
                        if customer.projects.count > 0 {
                            Text("\(customer.projects.count) project\(customer.projects.count == 1 ? "" : "s")")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                    }
                }
                
                // Details row
                HStack {
                    if !customer.phone.isEmpty {
                        Label(customer.phone, systemImage: "phone.fill")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    
                    if !customer.city.isEmpty && !customer.state.isEmpty {
                        Label("\(customer.city), \(customer.state)", systemImage: "location.fill")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    
                    Spacer()
                    
                    Label(customer.dateCreated.formatted(date: .abbreviated, time: .omitted), 
                          systemImage: "calendar")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
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
        .buttonStyle(PlainButtonStyle())
    }
}

// Extension for CustomerManager to support type filtering
extension CustomerManager {
    func searchCustomers(_ searchText: String) -> [Customer] {
        if searchText.isEmpty {
            return customers
        }
        return customers.filter { customer in
            customer.fullName.localizedCaseInsensitiveContains(searchText) ||
            customer.email.localizedCaseInsensitiveContains(searchText) ||
            customer.phone.localizedCaseInsensitiveContains(searchText) ||
            customer.city.localizedCaseInsensitiveContains(searchText)
        }
    }
    
    func getCustomersByType(_ type: CustomerType) -> [Customer] {
        return customers.filter { $0.customerType == type }
    }
}

#Preview {
    NavigationView {
        CustomerListView()
            .environmentObject(CustomerManager())
    }
}