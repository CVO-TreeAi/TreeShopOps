import SwiftUI

struct InvoiceListView: View {
    @EnvironmentObject var invoiceManager: InvoiceManager
    @State private var searchText = ""
    @State private var selectedStatus: InvoiceStatus? = nil
    @State private var showingAddInvoice = false
    @State private var selectedInvoice: Invoice? = nil
    @State private var showingInvoiceDetail = false
    
    var filteredInvoices: [Invoice] {
        var invoices = invoiceManager.searchInvoices(searchText)
        
        if let status = selectedStatus {
            invoices = invoices.filter { $0.status == status }
        }
        
        return invoices.sorted { $0.dateUpdated > $1.dateUpdated }
    }
    
    var body: some View {
        ZStack {
            Color("TreeShopBlack").ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header with financial stats
                headerSection
                
                // Status filter chips
                statusFilterSection
                
                // Invoices list
                invoicesList
            }
        }
        .navigationTitle("Invoices")
        .navigationBarTitleDisplayMode(.large)
        .navigationBarItems(
            trailing: Button(action: {
                showingAddInvoice = true
            }) {
                Image(systemName: "plus.circle.fill")
                    .font(.title2)
                    .foregroundColor(Color("TreeShopGreen"))
            }
        )
        .sheet(isPresented: $showingAddInvoice) {
            AddEditInvoiceView()
                .environmentObject(invoiceManager)
        }
        .sheet(isPresented: $showingInvoiceDetail) {
            if let invoice = selectedInvoice {
                InvoiceDetailView(invoice: invoice)
                    .environmentObject(invoiceManager)
            }
        }
        .searchable(text: $searchText, prompt: "Search invoices...")
    }
    
    private var headerSection: some View {
        VStack(spacing: 16) {
            // Financial stats cards
            HStack(spacing: 12) {
                InvoiceStatCard(
                    title: "Revenue",
                    value: "$\(String(format: "%.0f", invoiceManager.getTotalRevenue()))",
                    icon: "dollarsign.circle.fill",
                    color: Color("TreeShopGreen")
                )
                
                InvoiceStatCard(
                    title: "Outstanding",
                    value: "$\(String(format: "%.0f", invoiceManager.getOutstandingAmount()))",
                    icon: "clock.badge.exclamationmark.fill",
                    color: .orange
                )
                
                InvoiceStatCard(
                    title: "Overdue",
                    value: "\(invoiceManager.getInvoicesByStatus(.overdue).count)",
                    icon: "exclamationmark.triangle.fill",
                    color: .red
                )
            }
            .padding(.horizontal, 20)
        }
        .padding(.top, 20)
    }
    
    private var statusFilterSection: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                InvoiceFilterChip(
                    title: "All",
                    isSelected: selectedStatus == nil
                ) {
                    selectedStatus = nil
                }
                
                ForEach(InvoiceStatus.allCases, id: \.self) { status in
                    InvoiceFilterChip(
                        title: status.rawValue,
                        isSelected: selectedStatus == status,
                        color: status.color
                    ) {
                        selectedStatus = selectedStatus == status ? nil : status
                    }
                }
            }
            .padding(.horizontal, 20)
        }
        .padding(.vertical, 16)
    }
    
    private var invoicesList: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                if filteredInvoices.isEmpty {
                    emptyStateView
                } else {
                    ForEach(filteredInvoices) { invoice in
                        InvoiceRowView(invoice: invoice) {
                            selectedInvoice = invoice
                            showingInvoiceDetail = true
                        }
                        .contextMenu {
                            Button(action: {
                                selectedInvoice = invoice
                                showingAddInvoice = true
                            }) {
                                Label("Edit", systemImage: "pencil")
                            }
                            
                            if !invoice.isFullyPaid {
                                Button(action: {
                                    // Record payment
                                }) {
                                    Label("Record Payment", systemImage: "creditcard.fill")
                                }
                            }
                            
                            Button(role: .destructive, action: {
                                withAnimation(.spring()) {
                                    invoiceManager.deleteInvoice(invoice)
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
            Image(systemName: "dollarsign.square.fill")
                .font(.system(size: 60))
                .foregroundColor(.gray)
            
            VStack(spacing: 8) {
                Text("No Invoices Found")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                
                Text(searchText.isEmpty ? "Create your first invoice to start tracking payments" : "No invoices match your search")
                    .font(.body)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
            }
            
            if searchText.isEmpty {
                Button(action: {
                    showingAddInvoice = true
                }) {
                    HStack {
                        Image(systemName: "plus.circle.fill")
                        Text("Create Invoice")
                    }
                    .font(.headline)
                    .foregroundColor(.white)
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

struct InvoiceStatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundColor(color)
                
                Spacer()
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text(value)
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                Text(title)
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(12)
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

struct InvoiceFilterChip: View {
    let title: String
    let isSelected: Bool
    let color: Color
    let action: () -> Void
    
    init(title: String, isSelected: Bool, color: Color = Color("TreeShopGreen"), action: @escaping () -> Void) {
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
                .foregroundColor(isSelected ? .white : .gray)
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

struct InvoiceRowView: View {
    let invoice: Invoice
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 12) {
                // Header row
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(invoice.invoiceNumber)
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                        
                        Text(invoice.customerName)
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing, spacing: 4) {
                        // Status badge
                        HStack(spacing: 4) {
                            Image(systemName: invoice.status.systemImage)
                                .font(.caption)
                            Text(invoice.status.rawValue)
                                .font(.caption)
                                .fontWeight(.medium)
                        }
                        .foregroundColor(invoice.status.color)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(
                            RoundedRectangle(cornerRadius: 6)
                                .fill(invoice.status.color.opacity(0.2))
                        )
                        
                        // Amount
                        Text("$\(String(format: "%.2f", invoice.totalAmount))")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(Color("TreeShopGreen"))
                    }
                }
                
                // Payment progress
                if invoice.totalPaid > 0 {
                    HStack {
                        Text("Paid: $\(String(format: "%.2f", invoice.totalPaid))")
                            .font(.caption)
                            .foregroundColor(Color("TreeShopGreen"))
                        
                        Spacer()
                        
                        if !invoice.isFullyPaid {
                            Text("Due: $\(String(format: "%.2f", invoice.amountDue))")
                                .font(.caption)
                                .foregroundColor(.orange)
                        }
                    }
                    
                    ProgressView(value: invoice.totalPaid / invoice.totalAmount)
                        .progressViewStyle(LinearProgressViewStyle(tint: Color("TreeShopGreen")))
                }
                
                // Details row
                HStack {
                    Label(invoice.dateCreated.formatted(date: .abbreviated, time: .omitted), 
                          systemImage: "calendar")
                        .font(.caption)
                        .foregroundColor(.gray)
                    
                    Spacer()
                    
                    if invoice.isOverdue {
                        Label("Overdue", systemImage: "exclamationmark.triangle.fill")
                            .font(.caption)
                            .foregroundColor(.red)
                    }
                }
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.white.opacity(0.05))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(invoice.isOverdue ? Color.red.opacity(0.5) : Color.white.opacity(0.1), lineWidth: invoice.isOverdue ? 2 : 1)
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    NavigationView {
        InvoiceListView()
            .environmentObject(InvoiceManager())
    }
}