import SwiftUI

struct AddEditLeadView: View {
    @EnvironmentObject var leadManager: LeadManager
    @Environment(\.presentationMode) var presentationMode
    
    @State private var lead: Lead
    @State private var isEditing: Bool
    
    // Form sections
    @State private var selectedSection = 0
    private let sections = ["Contact", "Project", "Details"]
    
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
                
                VStack(spacing: 0) {
                    // Section picker
                    sectionPicker
                    
                    // Form content
                    ScrollView {
                        VStack(spacing: 20) {
                            switch selectedSection {
                            case 0:
                                contactSection
                            case 1:
                                projectSection
                            case 2:
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
    
    private var contactSection: some View {
        VStack(spacing: 20) {
            LeadFormSection(title: "Customer Contact") {
                VStack(spacing: 16) {
                    HStack(spacing: 12) {
                        LeadFormField(title: "First Name", text: $lead.customerFirstName, placeholder: "First name")
                        LeadFormField(title: "Last Name", text: $lead.customerLastName, placeholder: "Last name")
                    }
                    LeadFormField(title: "Email", text: $lead.customerEmail, placeholder: "customer@email.com")
                    LeadFormField(title: "Phone", text: $lead.customerPhone, placeholder: "(555) 123-4567")
                    LeadFormField(title: "Address", text: $lead.customerAddress, placeholder: "Street address")
                    HStack(spacing: 12) {
                        LeadFormField(title: "City", text: $lead.customerCity, placeholder: "City")
                        LeadFormField(title: "State", text: $lead.customerState, placeholder: "State")
                        LeadFormField(title: "Zip", text: $lead.customerZipCode, placeholder: "12345")
                    }
                }
            }
        }
    }
    
    private var projectSection: some View {
        VStack(spacing: 20) {
            LeadFormSection(title: "Project Information") {
                VStack(spacing: 16) {
                    LeadFormField(title: "Project Location", text: $lead.projectLocation, placeholder: "Property address or description")
                    LeadFormField(title: "Project Description", text: $lead.projectDescription, placeholder: "Describe the land clearing or forestry mulching needed...", axis: .vertical)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Land Size (Acres)")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(.white)
                        
                        TextField("0.0", value: $lead.landSize, format: .number)
                            .foregroundColor(.white)
                            .keyboardType(.decimalPad)
                            .padding(12)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Color.white.opacity(0.1))
                                    .stroke(Color.white.opacity(0.2), lineWidth: 1)
                            )
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Estimated Value")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(.white)
                        
                        TextField("$0.00", value: $lead.estimatedValue, format: .currency(code: "USD"))
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
        }
    }
    
    private var detailsSection: some View {
        VStack(spacing: 20) {
            LeadFormSection(title: "Lead Details") {
                VStack(spacing: 16) {
                    // Status picker
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Status")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(.white)
                        
                        Picker("Status", selection: $lead.status) {
                            ForEach(LeadStatus.allCases, id: \.self) { status in
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
                    
                    // Urgency picker
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Urgency")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(.white)
                        
                        Picker("Urgency", selection: $lead.urgency) {
                            ForEach(LeadUrgency.allCases, id: \.self) { urgency in
                                HStack {
                                    Image(systemName: urgency.systemImage)
                                    Text(urgency.rawValue)
                                }
                                .tag(urgency)
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
                    
                    // Lead source picker
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Lead Source")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(.white)
                        
                        Picker("Lead Source", selection: $lead.leadSource) {
                            ForEach(LeadSource.allCases, id: \.self) { source in
                                HStack {
                                    Image(systemName: source.systemImage)
                                    Text(source.rawValue)
                                }
                                .tag(source)
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
                    
                    // Follow up date picker
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
                                        .fill(Color.white.opacity(0.1))
                                        .stroke(Color.white.opacity(0.2), lineWidth: 1)
                                )
                        }
                    }
                    
                    LeadFormField(title: "Notes", text: $lead.notes, placeholder: "Additional notes about this lead...", axis: .vertical)
                }
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

struct LeadFormSection<Content: View>: View {
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

struct LeadFormField: View {
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

#Preview {
    AddEditLeadView()
        .environmentObject(LeadManager())
}