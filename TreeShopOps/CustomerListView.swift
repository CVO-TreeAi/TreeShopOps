import SwiftUI

struct CustomerListView: View {
    @EnvironmentObject var customerManager: CustomerManager
    @State private var showingAddCustomer = false
    @State private var selectedCustomer: Customer? = nil
    @State private var showingCustomerDetail = false
    @State private var showingFilters = false
    
    var onCustomerSelected: ((Customer) -> Void)? = nil
    @Environment(\.presentationMode) var presentationMode
    
    init(onCustomerSelected: ((Customer) -> Void)? = nil) {
        self.onCustomerSelected = onCustomerSelected
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Dynamic gradient background (reusing existing pattern)
                backgroundGradient
                
                ScrollView(showsIndicators: false) {
                    LazyVStack(spacing: 0) {
                        // Floating header
                        floatingHeader
                        
                        // Main content
                        VStack(spacing: 20) {
                            searchAndFiltersCard
                            customerStatsCard
                            customersListCard
                        }
                        .padding(.horizontal, 16)
                        .padding(.bottom, 30)
                    }
                }
                .onTapGesture {
                    hideKeyboard()
                }
            }
        }
        .ignoresSafeArea(.container, edges: .top)
        .sheet(isPresented: $showingAddCustomer) {
            AddEditCustomerView(customerManager: customerManager)
                .environmentObject(customerManager)
        }
        .sheet(item: $selectedCustomer) { customer in
            CustomerDetailView(customer: customer, customerManager: customerManager)
        }
        .actionSheet(isPresented: $showingFilters) {
            ActionSheet(
                title: Text("Filter Customers"),
                buttons: filterActionButtons()
            )
        }
    }
    
    // MARK: - Background (reusing existing pattern)
    private var backgroundGradient: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color.black,
                    Color(red: 0.05, green: 0.05, blue: 0.1),
                    Color(red: 0.1, green: 0.15, blue: 0.05),
                    Color.black
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            
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
    
    // MARK: - Floating Header (reusing existing pattern)
    private var floatingHeader: some View {
        HStack {
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
                    
                    Image(systemName: "person.2.fill")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.white)
                }
                
                Text(onCustomerSelected != nil ? "Select Customer" : "Customers")
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                    .foregroundColor(.white)
            }
            
            Spacer()
            
            // Filter button
            Button(action: {
                showingFilters = true
                let impactFeedback = UIImpactFeedbackGenerator(style: .light)
                impactFeedback.impactOccurred()
            }) {
                ZStack {
                    Circle()
                        .fill(Color.white.opacity(0.1))
                        .frame(width: 40, height: 40)
                        .background(.ultraThinMaterial, in: Circle())
                    
                    Image(systemName: "line.3.horizontal.decrease.circle")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.white)
                }
            }
            .buttonStyle(ScaleButtonStyle())
            
            // Add customer button
            Button(action: {
                showingAddCustomer = true
                let impactFeedback = UIImpactFeedbackGenerator(style: .light)
                impactFeedback.impactOccurred()
            }) {
                ZStack {
                    Circle()
                        .fill(Color("TreeShopGreen"))
                        .frame(width: 40, height: 40)
                    
                    Image(systemName: "plus")
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
    
    // MARK: - Search and Filters Card
    private var searchAndFiltersCard: some View {
        VStack(spacing: 16) {
            HStack {
                HStack(spacing: 10) {
                    Image(systemName: "magnifyingglass")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(Color("TreeShopGreen"))
                    
                    Text("Search & Filter")
                        .font(.system(size: 18, weight: .semibold, design: .rounded))
                        .foregroundColor(.white)
                }
                Spacer()
            }
            
            // Search field
            HStack(spacing: 12) {
                Image(systemName: "magnifyingglass")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(Color.white.opacity(0.6))
                    .frame(width: 20)
                
                TextField("Search customers...", text: $customerManager.searchText)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.white)
                
                if !customerManager.searchText.isEmpty {
                    Button(action: {
                        customerManager.searchText = ""
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(Color.white.opacity(0.6))
                    }
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
            
            // Active filters display
            if customerManager.selectedCustomerType != nil {
                HStack {
                    Text("Active Filters:")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(Color.white.opacity(0.7))
                    
                    if let selectedType = customerManager.selectedCustomerType {
                        HStack(spacing: 4) {
                            Text(selectedType.displayName)
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(.white)
                            
                            Button(action: {
                                customerManager.selectedCustomerType = nil
                            }) {
                                Image(systemName: "xmark")
                                    .font(.system(size: 10, weight: .medium))
                                    .foregroundColor(.white)
                            }
                        }
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(
                            RoundedRectangle(cornerRadius: 6)
                                .fill(Color("TreeShopGreen").opacity(0.3))
                        )
                    }
                    
                    Spacer()
                }
            }
        }
        .padding(24)
        .background(glassMorphismBackground)
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }
    
    // MARK: - Customer Stats Card
    private var customerStatsCard: some View {
        VStack(spacing: 16) {
            HStack {
                HStack(spacing: 10) {
                    Image(systemName: "chart.bar.fill")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(Color(red: 1.0, green: 0.76, blue: 0.03))
                    
                    Text("Customer Overview")
                        .font(.system(size: 18, weight: .semibold, design: .rounded))
                        .foregroundColor(.white)
                }
                Spacer()
            }
            
            // Stats grid
            HStack(spacing: 12) {
                statBox(
                    title: "Total",
                    value: "\(customerManager.customers.count)",
                    icon: "person.2.fill",
                    color: Color("TreeShopGreen")
                )
                
                statBox(
                    title: "Projects",
                    value: "\(customerManager.customers.reduce(0) { $0 + $1.totalProjects })",
                    icon: "hammer.fill",
                    color: Color(red: 1.0, green: 0.76, blue: 0.03)
                )
                
                statBox(
                    title: "Revenue",
                    value: formatCurrency(customerManager.customers.reduce(0) { $0 + $1.totalRevenue }),
                    icon: "dollarsign.circle.fill",
                    color: Color(red: 0.0, green: 0.5, blue: 1.0)
                )
            }
        }
        .padding(24)
        .background(glassMorphismBackground)
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }
    
    // MARK: - Customers List Card
    private var customersListCard: some View {
        VStack(spacing: 16) {
            HStack {
                HStack(spacing: 10) {
                    Image(systemName: "list.bullet")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(Color("TreeShopGreen"))
                    
                    Text("Customer List")
                        .font(.system(size: 18, weight: .semibold, design: .rounded))
                        .foregroundColor(.white)
                }
                
                Spacer()
                
                Text("\(customerManager.filteredCustomers.count)")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(Color.white.opacity(0.7))
            }
            
            if customerManager.filteredCustomers.isEmpty {
                emptyStateView
            } else {
                LazyVStack(spacing: 12) {
                    ForEach(customerManager.filteredCustomers) { customer in
                        customerRow(customer)
                    }
                }
            }
        }
        .padding(24)
        .background(glassMorphismBackground)
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }
    
    // MARK: - Customer Row
    private func customerRow(_ customer: Customer) -> some View {
        Button(action: {
            if let onCustomerSelected = onCustomerSelected {
                // If we have a callback, use it and dismiss
                onCustomerSelected(customer)
                presentationMode.wrappedValue.dismiss()
            } else {
                // Otherwise, show customer detail
                selectedCustomer = customer
            }
            let impactFeedback = UIImpactFeedbackGenerator(style: .light)
            impactFeedback.impactOccurred()
        }) {
            HStack(spacing: 12) {
                // Customer type icon
                ZStack {
                    Circle()
                        .fill(customer.customerType.iconName == "house.fill" ? 
                              Color("TreeShopGreen") : 
                              Color(red: 1.0, green: 0.76, blue: 0.03))
                        .frame(width: 40, height: 40)
                    
                    Image(systemName: customer.customerType.iconName)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.white)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(customer.fullName.isEmpty ? "No Name" : customer.fullName)
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.white)
                        
                        Spacer()
                        
                        if customer.totalProjects > 0 {
                            HStack(spacing: 4) {
                                Image(systemName: "hammer.fill")
                                    .font(.system(size: 10, weight: .medium))
                                    .foregroundColor(Color(red: 1.0, green: 0.76, blue: 0.03))
                                
                                Text("\(customer.totalProjects)")
                                    .font(.system(size: 12, weight: .semibold))
                                    .foregroundColor(Color(red: 1.0, green: 0.76, blue: 0.03))
                            }
                        }
                    }
                    
                    if !customer.email.isEmpty {
                        Text(customer.email)
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(Color.white.opacity(0.7))
                    }
                    
                    HStack {
                        if !customer.phone.isEmpty {
                            Text(customer.phone)
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(Color.white.opacity(0.6))
                        }
                        
                        Spacer()
                        
                        if customer.totalRevenue > 0 {
                            Text(formatCurrency(customer.totalRevenue))
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundColor(Color("TreeShopGreen"))
                        }
                    }
                }
                
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
    
    // MARK: - Helper Views
    private func statBox(title: String, value: String, icon: String, color: Color) -> some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(color)
            
            Text(value)
                .font(.system(size: 16, weight: .bold, design: .rounded))
                .foregroundColor(.white)
            
            Text(title)
                .font(.system(size: 11, weight: .medium))
                .foregroundColor(Color.white.opacity(0.7))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.white.opacity(0.03))
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(color.opacity(0.3), lineWidth: 1)
                )
        )
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "person.2.slash")
                .font(.system(size: 40, weight: .medium))
                .foregroundColor(Color.white.opacity(0.4))
            
            Text("No customers found")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(Color.white.opacity(0.7))
            
            if customerManager.customers.isEmpty {
                Button(action: {
                    showingAddCustomer = true
                }) {
                    HStack(spacing: 8) {
                        Image(systemName: "plus.circle.fill")
                        Text("Add Your First Customer")
                    }
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(Color("TreeShopGreen"))
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
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
        .padding(.vertical, 32)
    }
    
    // MARK: - Glassmorphism Background (reusing existing pattern)
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
    
    // MARK: - Helper Functions
    private func filterActionButtons() -> [ActionSheet.Button] {
        var buttons: [ActionSheet.Button] = []
        
        buttons.append(.default(Text("All Customers")) {
            customerManager.selectedCustomerType = nil
        })
        
        for customerType in CustomerType.allCases {
            buttons.append(.default(Text(customerType.displayName)) {
                customerManager.selectedCustomerType = customerType
            })
        }
        
        buttons.append(.cancel())
        return buttons
    }
    
    private func formatCurrency(_ amount: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = Locale(identifier: "en_US")
        formatter.maximumFractionDigits = 0
        return formatter.string(from: NSNumber(value: amount)) ?? "$0"
    }
    
    private func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

// MARK: - Scale Button Style (reusing existing pattern)
struct ScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

#Preview {
    CustomerListView()
        .environmentObject(CustomerManager())
        .preferredColorScheme(.dark)
}