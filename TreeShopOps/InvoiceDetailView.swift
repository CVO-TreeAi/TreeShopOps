import SwiftUI

struct InvoiceDetailView: View {
    @EnvironmentObject var invoiceManager: InvoiceManager
    @Environment(\.presentationMode) var presentationMode
    
    @State var invoice: Invoice
    @State private var showingEditInvoice = false
    @State private var showingDeleteAlert = false
    @State private var showingPaymentUpdate = false
    @State private var showingRecordPayment = false
    
    var body: some View {
        NavigationView {
            ZStack {
                Color("TreeShopBlack").ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 20) {
                        // Header card
                        headerCard
                        
                        // Customer information
                        customerCard
                        
                        // Project details
                        projectCard
                        
                        // Financial breakdown
                        financialCard
                        
                        // Payment tracking
                        paymentCard
                        
                        // Action buttons
                        actionButtons
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 100)
                }
            }
            .navigationTitle("Invoice Details")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(
                leading: Button("Close") {
                    presentationMode.wrappedValue.dismiss()
                }
                .foregroundColor(.white),
                
                trailing: Menu {
                    Button(action: {
                        showingEditInvoice = true
                    }) {
                        Label("Edit", systemImage: "pencil")
                    }
                    
                    if !invoice.isFullyPaid {
                        Button(action: {
                            showingRecordPayment = true
                        }) {
                            Label("Record Payment", systemImage: "creditcard.fill")
                        }
                    }
                    
                    Button(role: .destructive, action: {
                        showingDeleteAlert = true
                    }) {
                        Label("Delete", systemImage: "trash")
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                        .foregroundColor(Color("TreeShopGreen"))
                }
            )
        }
        .sheet(isPresented: $showingEditInvoice) {
            AddEditInvoiceView(invoice: invoice)
                .environmentObject(invoiceManager)
                .onDisappear {
                    if let updated = invoiceManager.getInvoice(by: invoice.id) {
                        invoice = updated
                    }
                }
        }
        .sheet(isPresented: $showingRecordPayment) {
            RecordPaymentView(invoice: $invoice)
        }
        .alert("Delete Invoice", isPresented: $showingDeleteAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                invoiceManager.deleteInvoice(invoice)
                presentationMode.wrappedValue.dismiss()
            }
        } message: {
            Text("Are you sure you want to delete this invoice? This action cannot be undone.")
        }
    }
    
    private var headerCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 8) {
                    Text(invoice.invoiceNumber)
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    Text(invoice.customerName)
                        .font(.headline)
                        .foregroundColor(.gray)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 8) {
                    // Status badge
                    HStack(spacing: 6) {
                        Image(systemName: invoice.status.systemImage)
                            .font(.caption)
                        Text(invoice.status.rawValue)
                            .font(.caption)
                            .fontWeight(.semibold)
                    }
                    .foregroundColor(invoice.status.color)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(invoice.status.color.opacity(0.2))
                    )
                    
                    // Total amount
                    Text("$\(String(format: "%.2f", invoice.totalAmount))")
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(Color("TreeShopGreen"))
                }
            }
            
            // Payment progress bar
            if invoice.totalPaid > 0 {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("Payment Progress")
                            .font(.subheadline)
                            .foregroundColor(.white)
                        
                        Spacer()
                        
                        Text("$\(String(format: "%.2f", invoice.totalPaid)) / $\(String(format: "%.2f", invoice.totalAmount))")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                    
                    ProgressView(value: invoice.totalPaid / invoice.totalAmount)
                        .progressViewStyle(LinearProgressViewStyle(tint: Color("TreeShopGreen")))
                }
            }
            
            // Overdue warning
            if invoice.isOverdue {
                HStack {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundColor(.red)
                    Text("Payment Overdue")
                        .font(.subheadline)
                        .foregroundColor(.red)
                    
                    Spacer()
                    
                    Text("Due: \(invoice.dueDate.formatted(date: .abbreviated, time: .omitted))")
                        .font(.caption)
                        .foregroundColor(.red)
                }
                .padding(12)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.red.opacity(0.1))
                        .stroke(Color.red.opacity(0.3), lineWidth: 1)
                )
            }
        }
        .cardStyle()
    }
    
    private var customerCard: some View {
        DetailCard(title: "Customer Information", icon: "person.fill") {
            VStack(alignment: .leading, spacing: 12) {
                if !invoice.customerEmail.isEmpty {
                    InvoiceDetailRow(title: "Email", value: invoice.customerEmail, isLink: true)
                }
                if !invoice.customerPhone.isEmpty {
                    InvoiceDetailRow(title: "Phone", value: invoice.customerPhone, isLink: true)
                }
                if !invoice.billingAddress.isEmpty {
                    InvoiceDetailRow(title: "Billing Address", value: invoice.billingAddress)
                }
            }
        }
    }
    
    private var projectCard: some View {
        DetailCard(title: "Project Details", icon: "leaf.fill") {
            VStack(alignment: .leading, spacing: 12) {
                if !invoice.projectTitle.isEmpty {
                    InvoiceDetailRow(title: "Project", value: invoice.projectTitle)
                }
                if !invoice.projectDescription.isEmpty {
                    InvoiceDetailRow(title: "Description", value: invoice.projectDescription)
                }
                if invoice.landSize > 0 {
                    InvoiceDetailRow(title: "Land Size", value: String(format: "%.1f acres", invoice.landSize))
                }
                InvoiceDetailRow(title: "Package Type", value: invoice.packageType.capitalized)
                
                if let completedDate = invoice.workCompletedDate {
                    InvoiceDetailRow(title: "Work Completed", value: completedDate.formatted(date: .long, time: .omitted))
                }
            }
        }
    }
    
    private var financialCard: some View {
        DetailCard(title: "Financial Breakdown", icon: "dollarsign.circle.fill") {
            VStack(spacing: 12) {
                InvoicePricingRow(title: "Original Amount", amount: invoice.originalAmount)
                
                if invoice.additionalCosts > 0 {
                    InvoicePricingRow(title: "Additional Costs", amount: invoice.additionalCosts)
                }
                
                if invoice.discountAmount > 0 {
                    InvoicePricingRow(title: "Discount", amount: -invoice.discountAmount, isDiscount: true)
                }
                
                InvoicePricingRow(title: "Subtotal", amount: invoice.subtotal)
                InvoicePricingRow(title: "Tax (\(String(format: "%.2f", invoice.taxRate * 100))%)", amount: invoice.taxAmount)
                
                Divider()
                    .background(Color.white.opacity(0.3))
                
                InvoicePricingRow(title: "Total", amount: invoice.totalAmount, isTotal: true)
            }
        }
    }
    
    private var paymentCard: some View {
        DetailCard(title: "Payment Tracking", icon: "creditcard.fill") {
            VStack(spacing: 12) {
                // Deposit
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            Text("Deposit (25%)")
                                .font(.subheadline)
                                .foregroundColor(.white)
                            
                            Spacer()
                            
                            Text("$\(String(format: "%.2f", invoice.depositAmount))")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                        }
                        
                        if invoice.depositPaid {
                            HStack {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(Color("TreeShopGreen"))
                                Text("Paid \(invoice.depositPaidDate?.formatted(date: .abbreviated, time: .omitted) ?? "")")
                                    .font(.caption)
                                    .foregroundColor(Color("TreeShopGreen"))
                            }
                        } else {
                            Text("Unpaid")
                                .font(.caption)
                                .foregroundColor(.orange)
                        }
                    }
                }
                .padding(12)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(invoice.depositPaid ? Color("TreeShopGreen").opacity(0.1) : Color.white.opacity(0.05))
                        .stroke(invoice.depositPaid ? Color("TreeShopGreen").opacity(0.3) : Color.white.opacity(0.1), lineWidth: 1)
                )
                
                // Balance
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            Text("Balance")
                                .font(.subheadline)
                                .foregroundColor(.white)
                            
                            Spacer()
                            
                            Text("$\(String(format: "%.2f", invoice.balanceAmount))")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                        }
                        
                        if invoice.balancePaid {
                            HStack {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(Color("TreeShopGreen"))
                                Text("Paid \(invoice.balancePaidDate?.formatted(date: .abbreviated, time: .omitted) ?? "")")
                                    .font(.caption)
                                    .foregroundColor(Color("TreeShopGreen"))
                            }
                        } else {
                            Text("Due: \(invoice.dueDate.formatted(date: .abbreviated, time: .omitted))")
                                .font(.caption)
                                .foregroundColor(invoice.isOverdue ? .red : .orange)
                        }
                    }
                }
                .padding(12)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(invoice.balancePaid ? Color("TreeShopGreen").opacity(0.1) : Color.white.opacity(0.05))
                        .stroke(invoice.balancePaid ? Color("TreeShopGreen").opacity(0.3) : Color.white.opacity(0.1), lineWidth: 1)
                )
            }
        }
    }
    
    private var actionButtons: some View {
        VStack(spacing: 12) {
            if !invoice.isFullyPaid {
                Button(action: {
                    showingRecordPayment = true
                }) {
                    HStack {
                        Image(systemName: "creditcard.fill")
                        Text("Record Payment")
                    }
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(Color("TreeShopGreen"))
                    .cornerRadius(12)
                }
            }
            
            Button(action: {
                showingEditInvoice = true
            }) {
                HStack {
                    Image(systemName: "pencil")
                    Text("Edit Invoice")
                }
                .font(.headline)
                .foregroundColor(Color("TreeShopGreen"))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color("TreeShopGreen"), lineWidth: 2)
                )
            }
        }
        .padding(.top, 10)
    }
}

struct InvoiceDetailRow: View {
    let title: String
    let value: String
    let isLink: Bool
    
    init(title: String, value: String, isLink: Bool = false) {
        self.title = title
        self.value = value
        self.isLink = isLink
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(.gray)
            
            if isLink {
                if title == "Email" {
                    Link(value, destination: URL(string: "mailto:\(value)")!)
                        .font(.body)
                        .foregroundColor(Color("TreeShopGreen"))
                } else if title == "Phone" {
                    Link(value, destination: URL(string: "tel:\(value)")!)
                        .font(.body)
                        .foregroundColor(Color("TreeShopGreen"))
                }
            } else {
                Text(value.isEmpty ? "Not specified" : value)
                    .font(.body)
                    .foregroundColor(value.isEmpty ? .gray : .white)
            }
        }
    }
}

struct InvoicePricingRow: View {
    let title: String
    let amount: Double
    let isDiscount: Bool
    let isTotal: Bool
    
    init(title: String, amount: Double, isDiscount: Bool = false, isTotal: Bool = false) {
        self.title = title
        self.amount = amount
        self.isDiscount = isDiscount
        self.isTotal = isTotal
    }
    
    var body: some View {
        HStack {
            Text(title)
                .font(isTotal ? .headline : .body)
                .fontWeight(isTotal ? .bold : .regular)
                .foregroundColor(.white)
            
            Spacer()
            
            Text("$\(String(format: "%.2f", abs(amount)))")
                .font(isTotal ? .headline : .body)
                .fontWeight(isTotal ? .bold : .semibold)
                .foregroundColor(isTotal ? Color("TreeShopGreen") : 
                               (isDiscount ? .green : .white))
        }
        .padding(isTotal ? 12 : 0)
        .background(
            isTotal ? 
            RoundedRectangle(cornerRadius: 8)
                .fill(Color("TreeShopGreen").opacity(0.1))
                .stroke(Color("TreeShopGreen").opacity(0.3), lineWidth: 1)
            : nil
        )
    }
}

struct RecordPaymentView: View {
    @Binding var invoice: Invoice
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var invoiceManager: InvoiceManager
    
    @State private var paymentType: PaymentType = .deposit
    @State private var paymentAmount: Double = 0.0
    @State private var paymentMethod: PaymentMethod = .check
    @State private var paymentDate = Date()
    @State private var notes = ""
    
    enum PaymentType: String, CaseIterable {
        case deposit = "Deposit"
        case balance = "Balance"
        case partial = "Partial Payment"
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                Color("TreeShopBlack").ignoresSafeArea()
                
                VStack(spacing: 20) {
                    // Payment type
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Payment Type")
                            .font(.headline)
                            .foregroundColor(.white)
                        
                        Picker("Payment Type", selection: $paymentType) {
                            ForEach(PaymentType.allCases, id: \.self) { type in
                                Text(type.rawValue).tag(type)
                            }
                        }
                        .pickerStyle(SegmentedPickerStyle())
                        .onChange(of: paymentType) { type in
                            switch type {
                            case .deposit:
                                paymentAmount = invoice.depositAmount
                            case .balance:
                                paymentAmount = invoice.balanceAmount
                            case .partial:
                                paymentAmount = 0.0
                            }
                        }
                    }
                    
                    // Amount
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Payment Amount")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(.white)
                        
                        TextField("$0.00", value: $paymentAmount, format: .currency(code: "USD"))
                            .foregroundColor(.white)
                            .keyboardType(.decimalPad)
                            .padding(12)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Color.white.opacity(0.1))
                                    .stroke(Color.white.opacity(0.2), lineWidth: 1)
                            )
                    }
                    
                    // Payment method
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Payment Method")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(.white)
                        
                        Picker("Payment Method", selection: $paymentMethod) {
                            ForEach(PaymentMethod.allCases, id: \.self) { method in
                                HStack {
                                    Image(systemName: method.systemImage)
                                    Text(method.rawValue)
                                }
                                .tag(method)
                            }
                        }
                        .pickerStyle(MenuPickerStyle())
                        .padding(.horizontal, 12)
                        .padding(.vertical, 10)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color.white.opacity(0.1))
                                .stroke(Color.white.opacity(0.2), lineWidth: 1)
                        )
                    }
                    
                    // Date
                    DatePicker("Payment Date", selection: $paymentDate, displayedComponents: .date)
                        .foregroundColor(.white)
                        .padding(12)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color.white.opacity(0.1))
                                .stroke(Color.white.opacity(0.2), lineWidth: 1)
                        )
                    
                    Spacer()
                    
                    // Save button
                    Button(action: recordPayment) {
                        Text("Record Payment")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(Color("TreeShopGreen"))
                            .cornerRadius(12)
                    }
                    .disabled(paymentAmount <= 0)
                }
                .padding()
            }
            .navigationTitle("Record Payment")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(
                leading: Button("Cancel") {
                    presentationMode.wrappedValue.dismiss()
                }
                .foregroundColor(.white)
            )
        }
        .onAppear {
            // Set default payment amount based on what's owed
            if !invoice.depositPaid {
                paymentType = .deposit
                paymentAmount = invoice.depositAmount
            } else if !invoice.balancePaid {
                paymentType = .balance
                paymentAmount = invoice.balanceAmount
            }
        }
    }
    
    private func recordPayment() {
        switch paymentType {
        case .deposit:
            invoice.depositPaid = true
            invoice.depositPaidDate = paymentDate
        case .balance:
            invoice.balancePaid = true
            invoice.balancePaidDate = paymentDate
        case .partial:
            // For partial payments, we'd need more complex logic
            break
        }
        
        invoice.paymentMethod = paymentMethod
        invoiceManager.updateInvoice(invoice)
        presentationMode.wrappedValue.dismiss()
    }
}

#Preview {
    InvoiceDetailView(invoice: Invoice(
        customerName: "John Doe",
        customerEmail: "john@example.com",
        projectTitle: "5 Acre Land Clearing",
        landSize: 5.0,
        originalAmount: 12500.0
    ))
    .environmentObject(InvoiceManager())
}