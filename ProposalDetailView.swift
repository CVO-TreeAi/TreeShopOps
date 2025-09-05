import SwiftUI

struct ProposalDetailView: View {
    @EnvironmentObject var proposalManager: ProposalManager
    @Environment(\.presentationMode) var presentationMode
    
    @State var proposal: Proposal
    @State private var showingEditProposal = false
    @State private var showingDeleteAlert = false
    @State private var showingStatusUpdate = false
    
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
                        
                        // Services breakdown
                        servicesCard
                        
                        // Pricing breakdown
                        pricingCard
                        
                        // Additional details
                        if !proposal.notes.isEmpty {
                            notesCard
                        }
                        
                        // Action buttons
                        actionButtons
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 100)
                }
            }
            .navigationTitle("Proposal Details")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(
                leading: Button("Close") {
                    presentationMode.wrappedValue.dismiss()
                }
                .foregroundColor(.white),
                
                trailing: Menu {
                    Button(action: {
                        showingEditProposal = true
                    }) {
                        Label("Edit", systemImage: "pencil")
                    }
                    
                    Button(action: {
                        showingStatusUpdate = true
                    }) {
                        Label("Update Status", systemImage: "arrow.clockwise")
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
        .sheet(isPresented: $showingEditProposal) {
            AddEditProposalView(proposal: proposal)
                .environmentObject(proposalManager)
                .onDisappear {
                    // Refresh the proposal data
                    if let updatedProposal = proposalManager.getProposal(by: proposal.id) {
                        proposal = updatedProposal
                    }
                }
        }
        .confirmationDialog("Update Status", isPresented: $showingStatusUpdate) {
            ForEach(ProposalStatus.allCases, id: \.self) { status in
                Button(status.rawValue) {
                    updateProposalStatus(status)
                }
            }
            Button("Cancel", role: .cancel) { }
        }
        .alert("Delete Proposal", isPresented: $showingDeleteAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                proposalManager.deleteProposal(proposal)
                presentationMode.wrappedValue.dismiss()
            }
        } message: {
            Text("Are you sure you want to delete this proposal? This action cannot be undone.")
        }
    }
    
    private var headerCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 8) {
                    Text(proposal.projectTitle.isEmpty ? "Untitled Proposal" : proposal.projectTitle)
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    Text("Created \(proposal.dateCreated.formatted(date: .abbreviated, time: .omitted))")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                
                Spacer()
                
                // Status badge
                VStack(alignment: .trailing, spacing: 8) {
                    HStack(spacing: 6) {
                        Image(systemName: proposal.status.systemImage)
                            .font(.caption)
                        Text(proposal.status.rawValue)
                            .font(.caption)
                            .fontWeight(.semibold)
                    }
                    .foregroundColor(proposal.status.color)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(proposal.status.color.opacity(0.2))
                    )
                    
                    // Total amount
                    Text("$\(proposal.totalAmount, specifier: "%.2f")")
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(Color("TreeShopGreen"))
                }
            }
            
            // Valid until warning
            if Calendar.current.dateInterval(of: .day, for: Date())?.contains(proposal.validUntil) ?? false ||
               proposal.validUntil < Date() {
                HStack {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundColor(.orange)
                    Text("Expires \(proposal.validUntil.formatted(date: .abbreviated, time: .omitted))")
                        .font(.subheadline)
                        .foregroundColor(.orange)
                }
                .padding(12)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.orange.opacity(0.1))
                        .stroke(Color.orange.opacity(0.3), lineWidth: 1)
                )
            }
        }
        .cardStyle()
    }
    
    private var customerCard: some View {
        DetailCard(title: "Customer Information", icon: "person.fill") {
            VStack(alignment: .leading, spacing: 12) {
                if !proposal.customerName.isEmpty {
                    DetailRow(title: "Name", value: proposal.customerName)
                }
                if !proposal.customerEmail.isEmpty {
                    DetailRow(title: "Email", value: proposal.customerEmail, isLink: true)
                }
                if !proposal.customerPhone.isEmpty {
                    DetailRow(title: "Phone", value: proposal.customerPhone, isLink: true)
                }
                if !proposal.customerAddress.isEmpty {
                    DetailRow(title: "Address", value: proposal.customerAddress)
                }
                if !proposal.projectZipCode.isEmpty {
                    DetailRow(title: "Zip Code", value: proposal.projectZipCode)
                }
            }
        }
    }
    
    private var projectCard: some View {
        DetailCard(title: "Project Details", icon: "hammer.fill") {
            VStack(alignment: .leading, spacing: 12) {
                if !proposal.projectDescription.isEmpty {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Description")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(.gray)
                        Text(proposal.projectDescription)
                            .font(.body)
                            .foregroundColor(.white)
                    }
                }
                
                DetailRow(title: "Valid Until", value: proposal.validUntil.formatted(date: .long, time: .omitted))
                
                if proposal.termsAccepted {
                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(Color("TreeShopGreen"))
                        Text("Terms Accepted")
                            .font(.subheadline)
                            .foregroundColor(Color("TreeShopGreen"))
                    }
                }
            }
        }
    }
    
    private var servicesCard: some View {
        DetailCard(title: "Services", icon: "list.bullet") {
            VStack(spacing: 8) {
                if proposal.treeRemovalCount > 0 {
                    ServiceRow(service: "Tree Removal", count: proposal.treeRemovalCount)
                }
                if proposal.stumpRemovalCount > 0 {
                    ServiceRow(service: "Stump Removal", count: proposal.stumpRemovalCount)
                }
                if proposal.treePruningCount > 0 {
                    ServiceRow(service: "Tree Pruning", count: proposal.treePruningCount)
                }
                if proposal.emergencyServiceCount > 0 {
                    ServiceRow(service: "Emergency Service", count: proposal.emergencyServiceCount)
                }
                if proposal.consultationCount > 0 {
                    ServiceRow(service: "Consultation", count: proposal.consultationCount)
                }
                
                if proposal.treeRemovalCount == 0 && proposal.stumpRemovalCount == 0 &&
                   proposal.treePruningCount == 0 && proposal.emergencyServiceCount == 0 &&
                   proposal.consultationCount == 0 {
                    Text("No services specified")
                        .font(.body)
                        .foregroundColor(.gray)
                        .italic()
                }
            }
        }
    }
    
    private var pricingCard: some View {
        DetailCard(title: "Pricing Breakdown", icon: "dollarsign.circle.fill") {
            VStack(spacing: 12) {
                PricingRow(title: "Subtotal", amount: proposal.subtotal)
                
                if proposal.discount > 0 {
                    PricingRow(title: "Discount", amount: -proposal.discount, isDiscount: true)
                }
                
                PricingRow(title: "Tax", amount: proposal.taxAmount)
                
                Divider()
                    .background(Color.white.opacity(0.3))
                
                PricingRow(title: "Total", amount: proposal.totalAmount, isTotal: true)
            }
        }
    }
    
    private var notesCard: some View {
        DetailCard(title: "Notes", icon: "note.text") {
            Text(proposal.notes)
                .font(.body)
                .foregroundColor(.white)
        }
    }
    
    private var actionButtons: some View {
        VStack(spacing: 12) {
            if proposal.status == .draft {
                Button(action: {
                    updateProposalStatus(.sent)
                }) {
                    HStack {
                        Image(systemName: "paperplane.fill")
                        Text("Send Proposal")
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
                showingEditProposal = true
            }) {
                HStack {
                    Image(systemName: "pencil")
                    Text("Edit Proposal")
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
    
    private func updateProposalStatus(_ status: ProposalStatus) {
        proposal.status = status
        proposal.dateUpdated = Date()
        proposalManager.updateProposal(proposal)
    }
}

struct DetailCard<Content: View>: View {
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

struct DetailRow: View {
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
                Text(value)
                    .font(.body)
                    .foregroundColor(.white)
            }
        }
    }
}

struct ServiceRow: View {
    let service: String
    let count: Int
    
    var body: some View {
        HStack {
            Text(service)
                .font(.body)
                .foregroundColor(.white)
            
            Spacer()
            
            Text("\(count)")
                .font(.body)
                .fontWeight(.semibold)
                .foregroundColor(Color("TreeShopGreen"))
        }
    }
}

struct PricingRow: View {
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
            
            Text("$\(abs(amount), specifier: "%.2f")")
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

extension View {
    func cardStyle() -> some View {
        self
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

#Preview {
    ProposalDetailView(proposal: Proposal(
        customerName: "John Doe",
        customerEmail: "john@example.com",
        projectTitle: "Backyard Tree Removal",
        treeRemovalCount: 3,
        totalAmount: 1500.0
    ))
    .environmentObject(ProposalManager())
}