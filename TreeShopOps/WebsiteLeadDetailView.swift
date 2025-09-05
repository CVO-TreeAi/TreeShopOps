import SwiftUI

struct WebsiteLeadDetailView: View {
    let websiteLead: WebsiteLead
    @EnvironmentObject var leadManager: LeadManager
    @EnvironmentObject var customerManager: CustomerManager
    @EnvironmentObject var proposalManager: ProposalManager
    @EnvironmentObject var websiteLeadSync: WebsiteLeadSyncManager
    @Environment(\.presentationMode) var presentationMode
    
    @State private var showingStatusUpdate = false
    @State private var showingValidation = false
    @State private var showingConvertConfirm = false
    @State private var notes = ""
    @State private var wetlandsChecked = false
    @State private var siteMapUrl = ""
    @State private var parcelId = ""
    
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
                        
                        // Property details
                        propertyCard
                        
                        // Business details
                        businessCard
                        
                        // Timeline
                        timelineCard
                        
                        // Action buttons
                        actionButtons
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 100)
                }
            }
            .navigationTitle("Website Lead")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(
                leading: Button("Close") {
                    presentationMode.wrappedValue.dismiss()
                }
                .foregroundColor(.white),
                
                trailing: Menu {
                    Button(action: {
                        showingStatusUpdate = true
                    }) {
                        Label("Update Status", systemImage: "arrow.clockwise")
                    }
                    
                    if websiteLead.status == .contacted {
                        Button(action: {
                            showingValidation = true
                        }) {
                            Label("Validate Lead", systemImage: "checkmark.shield")
                        }
                    }
                    
                    if websiteLead.status == .validated || websiteLead.status == .quoted {
                        Button(action: {
                            showingConvertConfirm = true
                        }) {
                            Label("Convert to Local Lead", systemImage: "arrow.right.circle")
                        }
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                        .foregroundColor(Color("TreeShopGreen"))
                }
            )
        }
        .confirmationDialog("Update Status", isPresented: $showingStatusUpdate) {
            ForEach(WebsiteLeadStatus.allCases, id: \.self) { status in
                Button(status.rawValue.capitalized) {
                    updateStatus(status)
                }
            }
            Button("Cancel", role: .cancel) { }
        }
        .sheet(isPresented: $showingValidation) {
            ValidationSheet(
                wetlandsChecked: $wetlandsChecked,
                siteMapUrl: $siteMapUrl,
                parcelId: $parcelId,
                onValidate: {
                    validateLead()
                }
            )
        }
        .alert("Convert to Local Lead", isPresented: $showingConvertConfirm) {
            Button("Cancel", role: .cancel) { }
            Button("Convert") {
                convertToLocalLead()
            }
        } message: {
            Text("This will create a local lead, customer, and proposal from this website lead.")
        }
    }
    
    private var headerCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 8) {
                    Text(websiteLead.name)
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    HStack(spacing: 4) {
                        Image(systemName: websiteLead.source.systemImage)
                            .font(.caption)
                            .foregroundColor(Color("TreeShopBlue"))
                        Text(websiteLead.source.displayName)
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 8) {
                    HStack(spacing: 6) {
                        Image(systemName: websiteLead.status.systemImage)
                            .font(.caption)
                        Text(websiteLead.status.rawValue.capitalized)
                            .font(.caption)
                            .fontWeight(.semibold)
                    }
                    .foregroundColor(websiteLead.status.color)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(websiteLead.status.color.opacity(0.2))
                    )
                    
                    Text("$\(String(format: "%.0f", websiteLead.instantQuote))")
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(Color("TreeShopGreen"))
                }
            }
        }
        .cardStyle()
    }
    
    private var customerCard: some View {
        DetailCard(title: "Customer Information", icon: "person.fill") {
            VStack(alignment: .leading, spacing: 12) {
                WebsiteLeadDetailRow(title: "Email", value: websiteLead.email, isLink: true)
                WebsiteLeadDetailRow(title: "Phone", value: websiteLead.phone, isLink: true)
                WebsiteLeadDetailRow(title: "Property Address", value: websiteLead.propertyAddress)
                
                if let details = websiteLead.additionalDetails, !details.isEmpty {
                    WebsiteLeadDetailRow(title: "Additional Details", value: details)
                }
            }
        }
    }
    
    private var propertyCard: some View {
        DetailCard(title: "Property Details", icon: "map.fill") {
            VStack(alignment: .leading, spacing: 12) {
                WebsiteLeadDetailRow(title: "Package Type", value: websiteLead.packageType.description)
                
                if let acreage = websiteLead.estimatedAcreage, acreage > 0 {
                    WebsiteLeadDetailRow(title: "Estimated Acreage", value: String(format: "%.1f acres", acreage))
                }
                
                if let siteMap = websiteLead.siteMapUrl, !siteMap.isEmpty {
                    WebsiteLeadDetailRow(title: "Site Map", value: siteMap, isLink: true)
                }
                
                if let parcel = websiteLead.parcelId, !parcel.isEmpty {
                    WebsiteLeadDetailRow(title: "Parcel ID", value: parcel)
                }
                
                if let wetlands = websiteLead.wetlandsChecked {
                    WebsiteLeadDetailRow(title: "Wetlands Check", value: wetlands ? "Completed" : "Required")
                }
            }
        }
    }
    
    private var businessCard: some View {
        DetailCard(title: "Business Information", icon: "dollarsign.circle.fill") {
            VStack(alignment: .leading, spacing: 12) {
                WebsiteLeadDetailRow(title: "Instant Quote", value: "$\(String(format: "%.2f", websiteLead.instantQuote))")
                WebsiteLeadDetailRow(title: "Package Type", value: websiteLead.packageType.rawValue)
                
                if let assignedTo = websiteLead.assignedTo, !assignedTo.isEmpty {
                    WebsiteLeadDetailRow(title: "Assigned To", value: assignedTo)
                }
            }
        }
    }
    
    private var timelineCard: some View {
        DetailCard(title: "Timeline", icon: "clock.fill") {
            VStack(alignment: .leading, spacing: 12) {
                WebsiteLeadDetailRow(title: "Created", value: websiteLead.createdDate.formatted(date: .long, time: .shortened))
                WebsiteLeadDetailRow(title: "Last Updated", value: websiteLead.updatedDate.formatted(date: .long, time: .shortened))
                
                if let followUp = websiteLead.followUpDate {
                    WebsiteLeadDetailRow(title: "Follow-up", value: followUp.formatted(date: .long, time: .shortened))
                }
                
                if let validation = websiteLead.validationDate {
                    WebsiteLeadDetailRow(title: "Validated", value: validation.formatted(date: .long, time: .shortened))
                }
            }
        }
    }
    
    private var actionButtons: some View {
        VStack(spacing: 12) {
            if websiteLead.status == .new {
                Button(action: {
                    updateStatus(.contacted)
                }) {
                    HStack {
                        Image(systemName: "phone.fill")
                        Text("Mark Contacted")
                    }
                    .font(.headline)
                    .foregroundColor(.black)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(Color("TreeShopGreen"))
                    .cornerRadius(12)
                }
            } else if websiteLead.status == .contacted {
                Button(action: {
                    showingValidation = true
                }) {
                    HStack {
                        Image(systemName: "checkmark.shield.fill")
                        Text("Validate Lead")
                    }
                    .font(.headline)
                    .foregroundColor(.black)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(Color("TreeShopGreen"))
                    .cornerRadius(12)
                }
            } else if websiteLead.status == .validated || websiteLead.status == .quoted {
                Button(action: {
                    showingConvertConfirm = true
                }) {
                    HStack {
                        Image(systemName: "arrow.right.circle.fill")
                        Text("Convert to Local Lead")
                    }
                    .font(.headline)
                    .foregroundColor(.black)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(Color("TreeShopGreen"))
                    .cornerRadius(12)
                }
            }
        }
        .padding(.top, 10)
    }
    
    private func updateStatus(_ status: WebsiteLeadStatus) {
        Task {
            await websiteLeadSync.updateLeadStatus(websiteLead.id, status: status, notes: notes)
        }
    }
    
    private func validateLead() {
        Task {
            await websiteLeadSync.validateLead(websiteLead.id, wetlandsChecked: wetlandsChecked, siteMapUrl: siteMapUrl, parcelId: parcelId)
        }
    }
    
    private func convertToLocalLead() {
        let localLead = websiteLeadSync.convertToLocalLead(websiteLead)
        leadManager.addLead(localLead)
        
        // Update website lead status
        Task {
            await websiteLeadSync.updateLeadStatus(websiteLead.id, status: .accepted, notes: "Converted to local lead and proposal system")
        }
        
        presentationMode.wrappedValue.dismiss()
    }
}

struct WebsiteLeadDetailRow: View {
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
                } else if title == "Site Map" {
                    Link("View Site Map", destination: URL(string: value)!)
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

struct ValidationSheet: View {
    @Binding var wetlandsChecked: Bool
    @Binding var siteMapUrl: String
    @Binding var parcelId: String
    let onValidate: () -> Void
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            ZStack {
                Color("TreeShopBlack").ignoresSafeArea()
                
                VStack(spacing: 20) {
                    Toggle("Wetlands Check Completed", isOn: $wetlandsChecked)
                        .foregroundColor(.white)
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color.white.opacity(0.1))
                        )
                    
                    TextField("Site Map URL", text: $siteMapUrl)
                        .textFieldStyle(PlainTextFieldStyle())
                        .foregroundColor(.white)
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color.white.opacity(0.1))
                        )
                    
                    TextField("Parcel ID", text: $parcelId)
                        .textFieldStyle(PlainTextFieldStyle())
                        .foregroundColor(.white)
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color.white.opacity(0.1))
                        )
                    
                    Spacer()
                    
                    Button(action: {
                        onValidate()
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Text("Validate Lead")
                            .font(.headline)
                            .foregroundColor(.black)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color("TreeShopGreen"))
                            .cornerRadius(12)
                    }
                }
                .padding()
            }
            .navigationTitle("Validate Lead")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(
                leading: Button("Cancel") {
                    presentationMode.wrappedValue.dismiss()
                }
                .foregroundColor(.white)
            )
        }
    }
}

#Preview {
    WebsiteLeadDetailView(websiteLead: WebsiteLead(
        id: "1",
        name: "John Doe",
        email: "john@example.com",
        phone: "555-123-4567",
        propertyAddress: "123 Forest Lane, Orlando, FL",
        source: .fltreeshopCom,
        status: .new,
        createdAt: Date().timeIntervalSince1970 * 1000,
        updatedAt: Date().timeIntervalSince1970 * 1000,
        packageType: .medium,
        instantQuote: 4500.0,
        estimatedAcreage: 2.5,
        additionalDetails: "Need clearing for new construction",
        assignedTo: nil,
        followedUpAt: nil,
        validatedAt: nil,
        wetlandsChecked: nil,
        siteMapUrl: nil,
        parcelId: nil
    ))
    .environmentObject(LeadManager())
    .environmentObject(CustomerManager())
    .environmentObject(ProposalManager())
    .environmentObject(WebsiteLeadSyncManager())
}