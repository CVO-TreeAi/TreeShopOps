import SwiftUI

struct LeadDetailView: View {
    @EnvironmentObject var leadManager: LeadManager
    @EnvironmentObject var proposalManager: ProposalManager
    @EnvironmentObject var customerManager: CustomerManager
    @Environment(\.presentationMode) var presentationMode
    
    @State var lead: Lead
    @State private var showingEditLead = false
    @State private var showingDeleteAlert = false
    @State private var showingStatusUpdate = false
    @State private var showingConvertToProposal = false
    
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
                        
                        // Lead tracking
                        trackingCard
                        
                        // Action buttons
                        actionButtons
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 100)
                }
            }
            .navigationTitle("Lead Details")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(
                leading: Button("Close") {
                    presentationMode.wrappedValue.dismiss()
                }
                .foregroundColor(.white),
                
                trailing: Menu {
                    Button(action: {
                        showingEditLead = true
                    }) {
                        Label("Edit", systemImage: "pencil")
                    }
                    
                    Button(action: {
                        showingStatusUpdate = true
                    }) {
                        Label("Update Status", systemImage: "arrow.clockwise")
                    }
                    
                    if lead.status == .qualified {
                        Button(action: {
                            showingConvertToProposal = true
                        }) {
                            Label("Convert to Proposal", systemImage: "arrow.right.circle")
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
        .sheet(isPresented: $showingEditLead) {
            AddEditLeadView(lead: lead)
                .environmentObject(leadManager)
                .onDisappear {
                    // Refresh the lead data
                    if let updatedLead = leadManager.getLead(by: lead.id) {
                        lead = updatedLead
                    }
                }
        }
        .confirmationDialog("Update Status", isPresented: $showingStatusUpdate) {
            ForEach(LeadStatus.allCases, id: \.self) { status in
                Button(status.rawValue) {
                    updateLeadStatus(status)
                }
            }
            Button("Cancel", role: .cancel) { }
        }
        .alert("Convert to Proposal", isPresented: $showingConvertToProposal) {
            Button("Cancel", role: .cancel) { }
            Button("Convert") {
                convertToProposal()
            }
        } message: {
            Text("This will create a new proposal from this qualified lead and mark the lead as converted.")
        }
        .alert("Delete Lead", isPresented: $showingDeleteAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                leadManager.deleteLead(lead)
                presentationMode.wrappedValue.dismiss()
            }
        } message: {
            Text("Are you sure you want to delete this lead? This action cannot be undone.")
        }
    }
    
    private var headerCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 8) {
                    Text(lead.fullName.isEmpty ? "New Lead" : lead.fullName)
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    Text("Created \(lead.dateCreated.formatted(date: .abbreviated, time: .omitted))")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                
                Spacer()
                
                // Status badge
                VStack(alignment: .trailing, spacing: 8) {
                    HStack(spacing: 6) {
                        Image(systemName: lead.status.systemImage)
                            .font(.caption)
                        Text(lead.status.rawValue)
                            .font(.caption)
                            .fontWeight(.semibold)
                    }
                    .foregroundColor(lead.status.color)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(lead.status.color.opacity(0.2))
                    )
                    
                    // Estimated value
                    if lead.estimatedValue > 0 {
                        Text("~$\(String(format: "%.0f", lead.estimatedValue))")
                            .font(.title3)
                            .fontWeight(.bold)
                            .foregroundColor(Color("TreeShopGreen"))
                    }
                }
            }
            
            // Urgency indicator
            if lead.urgency != .normal {
                HStack {
                    Image(systemName: lead.urgency.systemImage)
                        .foregroundColor(lead.urgency.color)
                    Text("\(lead.urgency.rawValue) Priority")
                        .font(.subheadline)
                        .foregroundColor(lead.urgency.color)
                }
                .padding(12)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(lead.urgency.color.opacity(0.1))
                        .stroke(lead.urgency.color.opacity(0.3), lineWidth: 1)
                )
            }
        }
        .cardStyle()
    }
    
    private var customerCard: some View {
        LeadDetailCard(title: "Customer Information", icon: "person.fill") {
            VStack(alignment: .leading, spacing: 12) {
                if !lead.customerEmail.isEmpty {
                    LeadDetailRow(title: "Email", value: lead.customerEmail, isLink: true)
                }
                if !lead.customerPhone.isEmpty {
                    LeadDetailRow(title: "Phone", value: lead.customerPhone, isLink: true)
                }
                if !lead.fullAddress.isEmpty {
                    LeadDetailRow(title: "Address", value: lead.fullAddress)
                }
            }
        }
    }
    
    private var projectCard: some View {
        LeadDetailCard(title: "Project Details", icon: "leaf.fill") {
            VStack(alignment: .leading, spacing: 12) {
                if !lead.projectLocation.isEmpty {
                    LeadDetailRow(title: "Location", value: lead.projectLocation)
                }
                if !lead.projectDescription.isEmpty {
                    LeadDetailRow(title: "Description", value: lead.projectDescription)
                }
                if lead.landSize > 0 {
                    LeadDetailRow(title: "Land Size", value: String(format: "%.1f acres", lead.landSize))
                }
            }
        }
    }
    
    private var trackingCard: some View {
        LeadDetailCard(title: "Lead Tracking", icon: "chart.line.uptrend.xyaxis") {
            VStack(alignment: .leading, spacing: 12) {
                LeadDetailRow(title: "Source", value: lead.leadSource.rawValue)
                
                if let lastContactDate = lead.lastContactDate {
                    LeadDetailRow(title: "Last Contact", value: lastContactDate.formatted(date: .abbreviated, time: .omitted))
                }
                
                if let followUpDate = lead.followUpDate {
                    let isOverdue = followUpDate < Date()
                    HStack {
                        Text("Follow Up:")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(.gray)
                        
                        Text(followUpDate.formatted(date: .abbreviated, time: .omitted))
                            .font(.body)
                            .foregroundColor(isOverdue ? .red : .white)
                        
                        if isOverdue {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .foregroundColor(.red)
                        }
                    }
                }
            }
        }
    }
    
    private var actionButtons: some View {
        VStack(spacing: 12) {
            if lead.status == .qualified {
                Button(action: {
                    showingConvertToProposal = true
                }) {
                    HStack {
                        Image(systemName: "arrow.right.circle.fill")
                        Text("Convert to Proposal")
                    }
                    .font(.headline)
                    .foregroundColor(.black)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(Color("TreeShopGreen"))
                    .cornerRadius(12)
                }
            }
            
            Button(action: {
                showingEditLead = true
            }) {
                HStack {
                    Image(systemName: "pencil")
                    Text("Edit Lead")
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
            
            // Quick status update buttons
            if lead.status == .new {
                Button(action: {
                    updateLeadStatus(.contacted)
                }) {
                    HStack {
                        Image(systemName: "phone.fill")
                        Text("Mark Contacted")
                    }
                    .font(.subheadline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(Color("TreeShopBlue"))
                    .cornerRadius(8)
                }
            }
        }
        .padding(.top, 10)
    }
    
    private func updateLeadStatus(_ status: LeadStatus) {
        lead.status = status
        lead.dateUpdated = Date()
        
        if status == .contacted {
            lead.lastContactDate = Date()
            // Set follow up for 3 days from now
            lead.followUpDate = Calendar.current.date(byAdding: .day, value: 3, to: Date())
        }
        
        leadManager.updateLead(lead)
    }
    
    private func convertToProposal() {
        // 1. Create customer from lead
        let customer = Customer(
            firstName: lead.customerFirstName,
            lastName: lead.customerLastName,
            email: lead.customerEmail,
            phone: lead.customerPhone,
            address: lead.customerAddress,
            city: lead.customerCity,
            state: lead.customerState,
            zipCode: lead.customerZipCode
        )
        customerManager.addCustomer(customer)
        
        // 2. Create proposal linked to customer and lead
        let proposal = Proposal(
            leadId: lead.id,
            customerId: customer.id,
            customerName: lead.fullName,
            customerEmail: lead.customerEmail,
            customerPhone: lead.customerPhone,
            customerAddress: lead.fullAddress,
            projectZipCode: lead.customerZipCode,
            projectTitle: "Forestry Mulching - \(lead.projectLocation)",
            projectDescription: lead.projectDescription,
            landSize: lead.landSize,
            packageType: "medium",
            transportHours: 2.0,
            debrisYards: 0.0,
            subtotal: lead.estimatedValue,
            taxAmount: 0.0,
            totalAmount: lead.estimatedValue,
            discount: 0.0,
            notes: lead.notes
        )
        proposalManager.addProposal(proposal)
        
        // 3. Add project to customer record
        customerManager.addProjectToCustomer(
            customerId: customer.id,
            projectName: proposal.projectTitle,
            landSize: lead.landSize,
            packageType: "medium",
            finalPrice: lead.estimatedValue,
            status: .quoted
        )
        
        // 4. Update lead status to converted
        lead.status = .converted
        lead.dateUpdated = Date()
        leadManager.updateLead(lead)
        
        presentationMode.wrappedValue.dismiss()
    }
}

struct LeadDetailCard<Content: View>: View {
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
                
                Text(title)
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
            }
            
            content
        }
        .cardStyle()
    }
}

struct LeadDetailRow: View {
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

#Preview {
    LeadDetailView(lead: Lead(
        customerFirstName: "John",
        customerLastName: "Doe",
        customerEmail: "john@example.com",
        projectDescription: "5 acre land clearing for development",
        landSize: 5.0,
        estimatedValue: 12500.0
    ))
    .environmentObject(LeadManager())
}