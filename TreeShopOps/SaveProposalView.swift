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
    
    var body: some View {
        NavigationView {
            ZStack {
                Color("TreeShopBlack").ignoresSafeArea()
                
                VStack(spacing: 20) {
                    titleSection
                    customerSection
                    pricingSummarySection
                    saveButtonSection
                    Spacer()
                }
                .padding()
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
    }
    
    private var titleSection: some View {
        VStack(spacing: 12) {
            TextField("Proposal Title", text: $proposalTitle)
                .foregroundColor(.white)
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.white.opacity(0.1))
                )
            
            TextField("Description", text: $proposalDescription, axis: .vertical)
                .foregroundColor(.white)
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.white.opacity(0.1))
                )
        }
    }
    
    private var customerSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Customer")
                .foregroundColor(.white)
                .font(.headline)
            
            if let customer = selectedCustomer {
                Text(customer.fullName)
                    .foregroundColor(.gray)
            } else {
                Text("No customer selected")
                    .foregroundColor(.gray)
            }
        }
    }
    
    private var pricingSummarySection: some View {
        VStack(spacing: 8) {
            Text("Total: $\(pricingModel.finalPrice, specifier: "%.2f")")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(Color("TreeShopGreen"))
        }
    }
    
    private var saveButtonSection: some View {
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
            .padding()
            .background(Color("TreeShopGreen"))
            .cornerRadius(12)
        }
    }
}