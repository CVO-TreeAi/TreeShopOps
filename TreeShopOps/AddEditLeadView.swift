import SwiftUI

struct AddEditLeadView: View {
    @EnvironmentObject var leadManager: LeadManager
    @Environment(\.presentationMode) var presentationMode
    
    @State private var lead: Lead
    @State private var isEditing: Bool
    @State private var customerAddressResult: AddressResult?
    @State private var projectAddressResult: AddressResult?
    
    init(lead: Lead? = nil) {
        if let existingLead = lead {
            _lead = State(initialValue: existingLead)
            _isEditing = State(initialValue: true)
        } else {
            _lead = State(initialValue: Lead())
            _isEditing = State(initialValue: false)
        }
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                Color("TreeShopBlack").ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 16) {
                        // Customer info section
                        QuickFormSection(title: "Customer Info", icon: "person.circle.fill") {
                            VStack(spacing: 16) {
                                HStack(spacing: 12) {
                                    QuickTextField(title: "First Name", text: $lead.customerFirstName, placeholder: "John")
                                    QuickTextField(title: "Last Name", text: $lead.customerLastName, placeholder: "Smith")
                                }
                                
                                QuickTextField(title: "Email", text: $lead.customerEmail, placeholder: "john@email.com")
                                QuickTextField(title: "Phone", text: $lead.customerPhone, placeholder: "(555) 123-4567")
                                
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Customer Address")
                                        .font(.subheadline)
                                        .fontWeight(.medium)
                                        .foregroundColor(.white)
                                    
                                    AddressAutocompleteField(
                                        result: $customerAddressResult,
                                        placeholder: "Search customer address..."
                                    ) { result in
                                        lead.customerAddress = result.street
                                        lead.customerCity = result.city
                                        lead.customerState = result.state
                                        lead.customerZipCode = result.zipCode
                                    }
                                }
                            }
                        }
                        
                        // Project info section
                        QuickFormSection(title: "Project Details", icon: "hammer.fill") {
                            VStack(spacing: 16) {
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Project Location")
                                        .font(.subheadline)
                                        .fontWeight(.medium)
                                        .foregroundColor(.white)
                                    
                                    AddressAutocompleteField(
                                        result: $projectAddressResult,
                                        placeholder: "Search project location..."
                                    ) { result in
                                        lead.projectLocation = result.fullAddress
                                    }
                                }
                                
                                QuickTextField(
                                    title: "Project Description", 
                                    text: $lead.projectDescription, 
                                    placeholder: "Land clearing, mulching, etc...",
                                    multiline: true
                                )
                                
                                HStack(spacing: 12) {
                                    VStack(alignment: .leading, spacing: 8) {
                                        Text("Acres")
                                            .font(.subheadline)
                                            .fontWeight(.medium)
                                            .foregroundColor(.white)
                                        
                                        TextField("0.0", value: $lead.landSize, format: .number)
                                            .foregroundColor(.white)
                                            .keyboardType(.decimalPad)
                                            .padding(12)
                                            .background(
                                                RoundedRectangle(cornerRadius: 8)
                                                    .fill(Color.white.opacity(0.05))
                                                    .stroke(Color.white.opacity(0.1), lineWidth: 1)
                                            )
                                    }
                                    
                                    VStack(alignment: .leading, spacing: 8) {
                                        Text("Est. Value")
                                            .font(.subheadline)
                                            .fontWeight(.medium)
                                            .foregroundColor(.white)
                                        
                                        TextField("$0", value: $lead.estimatedValue, format: .currency(code: "USD"))
                                            .foregroundColor(.white)
                                            .keyboardType(.decimalPad)
                                            .padding(12)
                                            .background(
                                                RoundedRectangle(cornerRadius: 8)
                                                    .fill(Color.white.opacity(0.05))
                                                    .stroke(Color.white.opacity(0.1), lineWidth: 1)
                                            )
                                    }
                                }
                            }
                        }
                        
                        // Lead details section
                        QuickFormSection(title: "Lead Details", icon: "info.circle.fill") {
                            VStack(spacing: 16) {
                                HStack(spacing: 12) {
                                    QuickPicker(title: "Status", selection: $lead.status, options: LeadStatus.allCases)
                                    QuickPicker(title: "Urgency", selection: $lead.urgency, options: LeadUrgency.allCases)
                                }
                                
                                QuickPicker(title: "Lead Source", selection: $lead.leadSource, options: LeadSource.allCases)
                                
                                if lead.status == .contacted || lead.status == .quoted {
                                    VStack(alignment: .leading, spacing: 8) {
                                        Text("Follow Up Date")
                                            .font(.subheadline)
                                            .fontWeight(.medium)
                                            .foregroundColor(.white)
                                        
                                        DatePicker("Follow Up", 
                                                  selection: Binding(
                                                    get: { lead.followUpDate ?? Date() },
                                                    set: { lead.followUpDate = $0 }
                                                  ), 
                                                  displayedComponents: .date)
                                            .foregroundColor(.white)
                                            .padding(12)
                                            .background(
                                                RoundedRectangle(cornerRadius: 8)
                                                    .fill(Color.white.opacity(0.05))
                                                    .stroke(Color.white.opacity(0.1), lineWidth: 1)
                                            )
                                    }
                                }
                                
                                QuickTextField(
                                    title: "Notes", 
                                    text: $lead.notes, 
                                    placeholder: "Additional notes...",
                                    multiline: true
                                )
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 2)
                    .padding(.bottom, 100)
                }
            }
            .navigationTitle(isEditing ? "Edit Lead" : "New Lead")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(
                leading: Button("Cancel") {
                    presentationMode.wrappedValue.dismiss()
                }
                .foregroundColor(.white),
                
                trailing: Button("Save") {
                    saveLead()
                }
                .foregroundColor(Color("TreeShopGreen"))
                .fontWeight(.semibold)
                .disabled(lead.customerFirstName.isEmpty || lead.customerLastName.isEmpty)
            )
        }
        .onAppear {
            setupExistingAddresses()
        }
    }
    
    private func setupExistingAddresses() {
        // Setup existing address data if editing
        if isEditing {
            if !lead.customerAddress.isEmpty {
                customerAddressResult = AddressResult(
                    fullAddress: lead.fullAddress,
                    street: lead.customerAddress,
                    city: lead.customerCity,
                    state: lead.customerState,
                    zipCode: lead.customerZipCode,
                    coordinate: nil
                )
            }
            
            if !lead.projectLocation.isEmpty {
                projectAddressResult = AddressResult(
                    fullAddress: lead.projectLocation,
                    street: lead.projectLocation,
                    city: "",
                    state: "",
                    zipCode: "",
                    coordinate: nil
                )
            }
        }
    }
    
    private func saveLead() {
        lead.dateUpdated = Date()
        
        if isEditing {
            leadManager.updateLead(lead)
        } else {
            leadManager.addLead(lead)
        }
        
        presentationMode.wrappedValue.dismiss()
    }
}

// MARK: - Quick Form Components

struct QuickFormSection<Content: View>: View {
    let title: String
    let icon: String
    let content: Content
    
    init(title: String, icon: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.icon = icon
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(Color("TreeShopGreen"))
                    .font(.title3)
                
                Text(title)
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
            }
            
            content
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white.opacity(0.03))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.white.opacity(0.1), lineWidth: 1)
                )
        )
    }
}

struct QuickTextField: View {
    let title: String
    @Binding var text: String
    let placeholder: String
    let multiline: Bool
    
    init(title: String, text: Binding<String>, placeholder: String, multiline: Bool = false) {
        self.title = title
        self._text = text
        self.placeholder = placeholder
        self.multiline = multiline
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(.white)
            
            TextField(placeholder, text: $text, axis: multiline ? .vertical : .horizontal)
                .textFieldStyle(PlainTextFieldStyle())
                .foregroundColor(.white)
                .padding(12)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.white.opacity(0.05))
                        .stroke(Color.white.opacity(0.1), lineWidth: 1)
                )
                .lineLimit(multiline ? 3 : 1)
        }
    }
}

struct QuickPicker<T: CaseIterable & RawRepresentable & Hashable>: View where T.RawValue == String {
    let title: String
    @Binding var selection: T
    let options: [T]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(.white)
            
            Picker(title, selection: $selection) {
                ForEach(options, id: \.self) { option in
                    Text(option.rawValue).tag(option)
                }
            }
            .pickerStyle(MenuPickerStyle())
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.white.opacity(0.05))
                    .stroke(Color.white.opacity(0.1), lineWidth: 1)
            )
        }
    }
}

#Preview {
    AddEditLeadView()
        .environmentObject(LeadManager())
}