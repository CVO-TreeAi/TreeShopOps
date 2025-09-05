import SwiftUI

struct AddEditInvoiceView: View {
    @EnvironmentObject var invoiceManager: InvoiceManager
    @Environment(\.presentationMode) var presentationMode
    
    @State private var invoice: Invoice
    @State private var isEditing: Bool
    
    // Form sections
    @State private var selectedSection = 0
    private let sections = ["Customer", "Project", "Financial", "Payment"]
    
    init(invoice: Invoice? = nil) {
        if let existingInvoice = invoice {
            _invoice = State(initialValue: existingInvoice)
            _isEditing = State(initialValue: true)
        } else {
            _invoice = State(initialValue: Invoice())
            _isEditing = State(initialValue: false)
        }
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                Color("TreeShopBlack").ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Section picker
                    sectionPicker
                    
                    // Form content
                    ScrollView {
                        VStack(spacing: 20) {
                            switch selectedSection {
                            case 0:
                                customerSection
                            case 1:
                                projectSection
                            case 2:
                                financialSection
                            case 3:
                                paymentSection
                            default:
                                EmptyView()
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.bottom, 100)
                    }
                    .onTapGesture {
                        hideKeyboard()
                    }
                }
            }
            .navigationTitle(isEditing ? "Edit Invoice" : "New Invoice")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(
                leading: Button("Cancel") {
                    presentationMode.wrappedValue.dismiss()
                }
                .foregroundColor(.white),
                
                trailing: Button("Save") {
                    saveInvoice()
                }
                .foregroundColor(Color("TreeShopGreen"))
                .fontWeight(.semibold)
            )
        }
    }
    
    private var sectionPicker: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 16) {
                ForEach(0..<sections.count, id: \.self) { index in
                    Button(action: {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            selectedSection = index
                        }
                    }) {
                        VStack(spacing: 4) {
                            Text(sections[index])
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundColor(selectedSection == index ? Color("TreeShopGreen") : .gray)
                            
                            Rectangle()
                                .fill(selectedSection == index ? Color("TreeShopGreen") : Color.clear)
                                .frame(height: 2)
                        }
                    }
                }
            }
            .padding(.horizontal, 20)
        }
        .padding(.vertical, 16)
        .background(Color.white.opacity(0.05))
    }
    
    private var customerSection: some View {
        VStack(spacing: 20) {
            InvoiceFormSection(title: "Customer Information") {
                VStack(spacing: 16) {
                    InvoiceFormField(title: "Invoice #", text: $invoice.invoiceNumber, placeholder: "INV-12345")
                    InvoiceFormField(title: "Customer Name", text: $invoice.customerName, placeholder: "Customer name")
                    InvoiceFormField(title: "Email", text: $invoice.customerEmail, placeholder: "customer@email.com")
                    InvoiceFormField(title: "Phone", text: $invoice.customerPhone, placeholder: "(555) 123-4567")
                    InvoiceFormField(title: "Billing Address", text: $invoice.billingAddress, placeholder: "Billing address", axis: .vertical)
                }
            }
        }
    }
    
    private var projectSection: some View {
        VStack(spacing: 20) {
            InvoiceFormSection(title: "Project Details") {
                VStack(spacing: 16) {
                    InvoiceFormField(title: "Project Title", text: $invoice.projectTitle, placeholder: "Land clearing project")
                    InvoiceFormField(title: "Description", text: $invoice.projectDescription, placeholder: "Project details...", axis: .vertical)
                    
                    HStack(spacing: 12) {
                        InvoiceDoubleField(title: "Land Size (Acres)", value: $invoice.landSize)
                        InvoiceFormField(title: "Package Type", text: $invoice.packageType, placeholder: "medium")
                    }
                    
                    if let completedDate = invoice.workCompletedDate {
                        DatePicker("Work Completed", 
                                  selection: Binding(
                                    get: { completedDate },
                                    set: { invoice.workCompletedDate = $0 }
                                  ), 
                                  displayedComponents: .date)
                            .foregroundColor(.white)
                            .padding(12)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Color.white.opacity(0.1))
                                    .stroke(Color.white.opacity(0.2), lineWidth: 1)
                            )
                    }
                }
            }
        }
    }
    
    private var financialSection: some View {
        VStack(spacing: 20) {
            InvoiceFormSection(title: "Pricing") {
                VStack(spacing: 16) {
                    InvoiceDoubleField(title: "Original Amount", value: $invoice.originalAmount)
                    InvoiceDoubleField(title: "Additional Costs", value: $invoice.additionalCosts)
                    InvoiceDoubleField(title: "Discount Amount", value: $invoice.discountAmount)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Tax Rate (%)")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(.white)
                        
                        TextField("8.75", value: Binding(
                            get: { invoice.taxRate * 100 },
                            set: { invoice.taxRate = $0 / 100 }
                        ), format: .number)
                            .foregroundColor(.white)
                            .keyboardType(.decimalPad)
                            .padding(12)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Color.white.opacity(0.1))
                                    .stroke(Color.white.opacity(0.2), lineWidth: 1)
                            )
                    }
                    
                    Divider()
                        .background(Color.white.opacity(0.3))
                    
                    // Calculated totals
                    VStack(spacing: 8) {
                        HStack {
                            Text("Subtotal")
                                .foregroundColor(.white)
                            Spacer()
                            Text("$\(String(format: "%.2f", calculateSubtotal()))")
                                .foregroundColor(.white)
                        }
                        
                        HStack {
                            Text("Tax")
                                .foregroundColor(.white)
                            Spacer()
                            Text("$\(String(format: "%.2f", calculateTax()))")
                                .foregroundColor(.white)
                        }
                        
                        HStack {
                            Text("Total")
                                .font(.headline)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                            Spacer()
                            Text("$\(String(format: "%.2f", calculateTotal()))")
                                .font(.headline)
                                .fontWeight(.bold)
                                .foregroundColor(Color("TreeShopGreen"))
                        }
                    }
                    .padding(12)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color("TreeShopGreen").opacity(0.1))
                            .stroke(Color("TreeShopGreen").opacity(0.3), lineWidth: 1)
                    )
                }
            }
        }
    }
    
    private var paymentSection: some View {
        VStack(spacing: 20) {
            InvoiceFormSection(title: "Payment Information") {
                VStack(spacing: 16) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Payment Terms")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(.white)
                        
                        Picker("Payment Terms", selection: $invoice.paymentTerms) {
                            ForEach(PaymentTerms.allCases, id: \.self) { terms in
                                HStack {
                                    Image(systemName: terms.systemImage)
                                    Text(terms.rawValue)
                                }
                                .tag(terms)
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
                    
                    DatePicker("Due Date", 
                              selection: $invoice.dueDate, 
                              displayedComponents: .date)
                        .foregroundColor(.white)
                        .padding(12)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color.white.opacity(0.1))
                                .stroke(Color.white.opacity(0.2), lineWidth: 1)
                        )
                    
                    Toggle("Deposit Paid", isOn: $invoice.depositPaid)
                        .foregroundColor(.white)
                        .padding(12)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color.white.opacity(0.1))
                                .stroke(Color.white.opacity(0.2), lineWidth: 1)
                        )
                        .onChange(of: invoice.depositPaid) { isPaid in
                            if isPaid && invoice.depositPaidDate == nil {
                                invoice.depositPaidDate = Date()
                            } else if !isPaid {
                                invoice.depositPaidDate = nil
                            }
                        }
                    
                    Toggle("Balance Paid", isOn: $invoice.balancePaid)
                        .foregroundColor(.white)
                        .padding(12)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color.white.opacity(0.1))
                                .stroke(Color.white.opacity(0.2), lineWidth: 1)
                        )
                        .onChange(of: invoice.balancePaid) { isPaid in
                            if isPaid && invoice.balancePaidDate == nil {
                                invoice.balancePaidDate = Date()
                            } else if !isPaid {
                                invoice.balancePaidDate = nil
                            }
                        }
                }
            }
        }
    }
    
    private func calculateSubtotal() -> Double {
        return invoice.originalAmount + invoice.additionalCosts - invoice.discountAmount
    }
    
    private func calculateTax() -> Double {
        return calculateSubtotal() * invoice.taxRate
    }
    
    private func calculateTotal() -> Double {
        return calculateSubtotal() + calculateTax()
    }
    
    private func saveInvoice() {
        // Update calculated values
        invoice.subtotal = calculateSubtotal()
        invoice.taxAmount = calculateTax()
        invoice.totalAmount = calculateTotal()
        invoice.depositAmount = invoice.totalAmount * 0.25
        invoice.balanceAmount = invoice.totalAmount - invoice.depositAmount
        invoice.dateUpdated = Date()
        
        if isEditing {
            invoiceManager.updateInvoice(invoice)
        } else {
            invoiceManager.addInvoice(invoice)
        }
        
        presentationMode.wrappedValue.dismiss()
    }
}

struct InvoiceFormSection<Content: View>: View {
    let title: String
    let content: Content
    
    init(title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(title)
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(.white)
            
            content
        }
        .padding(20)
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

struct InvoiceFormField: View {
    let title: String
    @Binding var text: String
    let placeholder: String
    let axis: Axis
    
    init(title: String, text: Binding<String>, placeholder: String, axis: Axis = .horizontal) {
        self.title = title
        self._text = text
        self.placeholder = placeholder
        self.axis = axis
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(.white)
            
            TextField(placeholder, text: $text, axis: axis)
                .textFieldStyle(PlainTextFieldStyle())
                .foregroundColor(.white)
                .padding(12)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.white.opacity(0.1))
                        .stroke(Color.white.opacity(0.2), lineWidth: 1)
                )
                .lineLimit(axis == .vertical ? 4 : 1)
        }
    }
}

struct InvoiceDoubleField: View {
    let title: String
    @Binding var value: Double
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(.white)
            
            TextField("$0.00", value: $value, format: .currency(code: "USD"))
                .textFieldStyle(PlainTextFieldStyle())
                .foregroundColor(.white)
                .keyboardType(.decimalPad)
                .padding(12)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.white.opacity(0.1))
                        .stroke(Color.white.opacity(0.2), lineWidth: 1)
                )
        }
    }
}

#Preview {
    AddEditInvoiceView()
        .environmentObject(InvoiceManager())
}