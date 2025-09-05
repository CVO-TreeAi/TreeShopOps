import SwiftUI

struct SaveProposalView: View {
    let pricingModel: PricingModel
    let selectedCustomer: Customer?
    @Binding var proposalTitle: String
    @Binding var proposalDescription: String
    let onSave: (String, String) -> Void
    
    @Environment(\.presentationMode) var presentationMode
    @State private var customerName: String = ""
    @State private var customerEmail: String = ""
    
    init(pricingModel: PricingModel, selectedCustomer: Customer?, proposalTitle: Binding<String>, proposalDescription: Binding<String>, onSave: @escaping (String, String) -> Void) {
        self.pricingModel = pricingModel
        self.selectedCustomer = selectedCustomer
        self._proposalTitle = proposalTitle
        self._proposalDescription = proposalDescription
        self.onSave = onSave
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                Color("TreeShopBlack").ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 20) {
                        // Proposal Details Section
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Proposal Details")
                                .font(.headline)
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                            
                            VStack(spacing: 16) {
                                FormField(title: "Title", text: $proposalTitle, placeholder: "e.g., Backyard Tree Removal")
                                FormField(title: "Description", text: $proposalDescription, placeholder: "Describe the project details...", axis: .vertical)
                            }
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
                        
                        // Customer Information Section
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Customer Information")
                                .font(.headline)
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                            
                            if let customer = selectedCustomer {
                                VStack(alignment: .leading, spacing: 12) {
                                    DetailRow(title: "Name", value: customer.name)
                                    DetailRow(title: "Email", value: customer.email)
                                    DetailRow(title: "Phone", value: customer.phone)
                                    DetailRow(title: "Address", value: customer.address)
                                }
                            } else {
                                VStack(spacing: 16) {
                                    FormField(title: "Name", text: $customerName, placeholder: "Customer name")
                                    FormField(title: "Email", text: $customerEmail, placeholder: "customer@email.com")
                                }
                            }
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
                        
                        // Pricing Summary
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Pricing Summary")
                                .font(.headline)
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                            
                            VStack(spacing: 8) {
                                PricingRow(title: "Subtotal", amount: pricingModel.subtotal)
                                PricingRow(title: "Tax", amount: pricingModel.tax)
                                
                                Divider()
                                    .background(Color.white.opacity(0.3))
                                
                                PricingRow(title: "Total", amount: pricingModel.total, isTotal: true)
                            }
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
                        
                        // Save Button
                        Button(action: {
                            if proposalTitle.isEmpty {
                                proposalTitle = "Tree Service Proposal"
                            }
                            onSave(proposalTitle, proposalDescription)
                        }) {
                            HStack {
                                Image(systemName: "doc.badge.plus")
                                Text("Save Proposal")
                            }
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(Color("TreeShopGreen"))
                            .cornerRadius(12)
                        }
                        .disabled(proposalTitle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 100)
                }
                .onTapGesture {
                    hideKeyboard()
                }
            }
            .navigationTitle("Save Proposal")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(
                leading: Button("Cancel") {
                    presentationMode.wrappedValue.dismiss()
                }
                .foregroundColor(.white)
            )
        }
        .onAppear {
            if proposalTitle.isEmpty {
                proposalTitle = "Tree Service Proposal"
            }
            if selectedCustomer == nil {
                customerName = ""
                customerEmail = ""
            }
        }
    }
}

struct DetailRow: View {
    let title: String
    let value: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(.gray)
            Text(value.isEmpty ? "Not specified" : value)
                .font(.body)
                .foregroundColor(value.isEmpty ? .gray : .white)
        }
    }
}

struct PricingRow: View {
    let title: String
    let amount: Double
    let isTotal: Bool
    
    init(title: String, amount: Double, isTotal: Bool = false) {
        self.title = title
        self.amount = amount
        self.isTotal = isTotal
    }
    
    var body: some View {
        HStack {
            Text(title)
                .font(isTotal ? .headline : .body)
                .fontWeight(isTotal ? .bold : .regular)
                .foregroundColor(.white)
            
            Spacer()
            
            Text("$\(amount, specifier: "%.2f")")
                .font(isTotal ? .headline : .body)
                .fontWeight(isTotal ? .bold : .semibold)
                .foregroundColor(isTotal ? Color("TreeShopGreen") : .white)
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

#Preview {
    SaveProposalView(
        pricingModel: PricingModel(),
        selectedCustomer: nil,
        proposalTitle: .constant(""),
        proposalDescription: .constant(""),
        onSave: { _, _ in }
    )
}