import SwiftUI

struct AddEditProposalView: View {
    @EnvironmentObject var proposalManager: ProposalManager
    @Environment(\.presentationMode) var presentationMode
    
    @State private var proposal: Proposal
    @State private var isEditing: Bool
    
    // Form sections
    @State private var selectedSection = 0
    private let sections = ["Customer", "Project", "Services", "Pricing", "Details"]
    
    init(proposal: Proposal? = nil) {
        if let existingProposal = proposal {
            _proposal = State(initialValue: existingProposal)
            _isEditing = State(initialValue: true)
        } else {
            _proposal = State(initialValue: Proposal())
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
                                servicesSection
                            case 3:
                                pricingSection
                            case 4:
                                detailsSection
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
            .navigationTitle(isEditing ? "Edit Proposal" : "New Proposal")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(
                leading: Button("Cancel") {
                    presentationMode.wrappedValue.dismiss()
                }
                .foregroundColor(.white),
                
                trailing: Button("Save") {
                    saveProposal()
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
            FormSection(title: "Customer Information") {
                VStack(spacing: 16) {
                    FormField(title: "Name", text: $proposal.customerName, placeholder: "Customer name")
                    FormField(title: "Email", text: $proposal.customerEmail, placeholder: "customer@email.com")
                    FormField(title: "Phone", text: $proposal.customerPhone, placeholder: "(555) 123-4567")
                    FormField(title: "Address", text: $proposal.customerAddress, placeholder: "Street address", axis: .vertical)
                    FormField(title: "Project Zip Code", text: $proposal.projectZipCode, placeholder: "12345")
                }
            }
        }
    }
    
    private var projectSection: some View {
        VStack(spacing: 20) {
            FormSection(title: "Project Details") {
                VStack(spacing: 16) {
                    FormField(title: "Project Title", text: $proposal.projectTitle, placeholder: "e.g., Backyard Tree Removal")
                    FormField(title: "Description", text: $proposal.projectDescription, placeholder: "Describe the project details...", axis: .vertical)
                    
                    HStack {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Status")
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundColor(.white)
                            
                            Picker("Status", selection: $proposal.status) {
                                ForEach(ProposalStatus.allCases, id: \.self) { status in
                                    HStack {
                                        Image(systemName: status.systemImage)
                                        Text(status.rawValue)
                                    }
                                    .tag(status)
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
                        
                        Spacer()
                    }
                }
            }
        }
    }
    
    private var servicesSection: some View {
        VStack(spacing: 20) {
            FormSection(title: "Services") {
                VStack(spacing: 16) {
                    ServiceCountField(title: "Tree Removal", count: $proposal.treeRemovalCount)
                    ServiceCountField(title: "Stump Removal", count: $proposal.stumpRemovalCount)
                    ServiceCountField(title: "Tree Pruning", count: $proposal.treePruningCount)
                    ServiceCountField(title: "Emergency Service", count: $proposal.emergencyServiceCount)
                    ServiceCountField(title: "Consultation", count: $proposal.consultationCount)
                }
            }
        }
    }
    
    private var pricingSection: some View {
        VStack(spacing: 20) {
            FormSection(title: "Pricing") {
                VStack(spacing: 16) {
                    PricingField(title: "Subtotal", amount: $proposal.subtotal)
                    PricingField(title: "Discount", amount: $proposal.discount)
                    PricingField(title: "Tax Amount", amount: $proposal.taxAmount)
                    
                    Divider()
                        .background(Color.white.opacity(0.3))
                    
                    HStack {
                        Text("Total Amount")
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                        
                        Spacer()
                        
                        Text("$\(proposal.totalAmount, specifier: "%.2f")")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(Color("TreeShopGreen"))
                    }
                    .padding(16)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color("TreeShopGreen").opacity(0.1))
                            .stroke(Color("TreeShopGreen").opacity(0.3), lineWidth: 1)
                    )
                }
            }
        }
    }
    
    private var detailsSection: some View {
        VStack(spacing: 20) {
            FormSection(title: "Additional Details") {
                VStack(spacing: 16) {
                    FormField(title: "Notes", text: $proposal.notes, placeholder: "Additional notes or special instructions...", axis: .vertical)
                    
                    DatePicker("Valid Until", 
                              selection: $proposal.validUntil, 
                              displayedComponents: .date)
                        .foregroundColor(.white)
                        .padding(12)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color.white.opacity(0.1))
                                .stroke(Color.white.opacity(0.2), lineWidth: 1)
                        )
                    
                    Toggle("Terms Accepted", isOn: $proposal.termsAccepted)
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
    
    private func saveProposal() {
        proposal.dateUpdated = Date()
        
        if isEditing {
            proposalManager.updateProposal(proposal)
        } else {
            proposalManager.addProposal(proposal)
        }
        
        presentationMode.wrappedValue.dismiss()
    }
}

struct FormSection<Content: View>: View {
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

struct FormField: View {
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

struct ServiceCountField: View {
    let title: String
    @Binding var count: Int
    
    var body: some View {
        HStack {
            Text(title)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(.white)
            
            Spacer()
            
            HStack(spacing: 12) {
                Button(action: {
                    if count > 0 {
                        count -= 1
                    }
                }) {
                    Image(systemName: "minus.circle.fill")
                        .font(.title2)
                        .foregroundColor(count > 0 ? Color("TreeShopGreen") : .gray)
                }
                .disabled(count <= 0)
                
                Text("\(count)")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .frame(minWidth: 30)
                
                Button(action: {
                    count += 1
                }) {
                    Image(systemName: "plus.circle.fill")
                        .font(.title2)
                        .foregroundColor(Color("TreeShopGreen"))
                }
            }
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.white.opacity(0.1))
                .stroke(Color.white.opacity(0.2), lineWidth: 1)
        )
    }
}

struct PricingField: View {
    let title: String
    @Binding var amount: Double
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(.white)
            
            TextField("0.00", value: $amount, format: .currency(code: "USD"))
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

// Extension to hide keyboard
extension View {
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

#Preview {
    AddEditProposalView()
        .environmentObject(ProposalManager())
}