import SwiftUI

struct WebsiteLeadListView: View {
    @EnvironmentObject var leadManager: LeadManager
    @EnvironmentObject var customerManager: CustomerManager
    @EnvironmentObject var proposalManager: ProposalManager
    @StateObject private var websiteLeadSync = WebsiteLeadSyncManager()
    
    @State private var searchText = ""
    @State private var selectedStatus: WebsiteLeadStatus? = nil
    @State private var selectedLead: WebsiteLead? = nil
    @State private var showingLeadDetail = false
    
    var filteredLeads: [WebsiteLead] {
        var leads = websiteLeadSync.websiteLeads
        
        // Filter by status
        if let status = selectedStatus {
            leads = leads.filter { $0.status == status }
        }
        
        // Filter by search text
        if !searchText.isEmpty {
            leads = leads.filter { lead in
                lead.name.localizedCaseInsensitiveContains(searchText) ||
                lead.email.localizedCaseInsensitiveContains(searchText) ||
                lead.phone.localizedCaseInsensitiveContains(searchText) ||
                lead.propertyAddress.localizedCaseInsensitiveContains(searchText)
            }
        }
        
        return leads.sorted { $0.createdDate > $1.createdDate }
    }
    
    var body: some View {
        ZStack {
            Color("TreeShopBlack").ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header with sync status
                headerSection
                
                // Status filter
                statusFilterSection
                
                // Website leads list
                leadsList
            }
        }
        .navigationTitle("Website Leads")
        .navigationBarTitleDisplayMode(.large)
        .navigationBarItems(
            leading: syncButton,
            trailing: syncStatusIndicator
        )
        .sheet(isPresented: $showingLeadDetail) {
            if let lead = selectedLead {
                WebsiteLeadDetailView(websiteLead: lead)
                    .environmentObject(leadManager)
                    .environmentObject(customerManager)
                    .environmentObject(proposalManager)
                    .environmentObject(websiteLeadSync)
            }
        }
        .searchable(text: $searchText, prompt: "Search website leads...")
        .onAppear {
            websiteLeadSync.startSync()
        }
        .onDisappear {
            websiteLeadSync.stopSync()
        }
    }
    
    private var headerSection: some View {
        VStack(spacing: 16) {
            // Website lead stats
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: 3), spacing: 12) {
                StandardStatCard(
                    title: "New Leads",
                    value: "\(websiteLeadSync.websiteLeads.filter { $0.status == .new }.count)",
                    icon: "globe",
                    color: Color("TreeShopBlue")
                )
                
                StandardStatCard(
                    title: "This Week",
                    value: "\(getLeadsThisWeek())",
                    icon: "calendar",
                    color: Color("TreeShopGreen")
                )
                
                StandardStatCard(
                    title: "Total Value",
                    value: "$\(String(format: "%.0f", getTotalLeadValue()))",
                    icon: "dollarsign.circle",
                    color: .orange
                )
            }
            .padding(.horizontal, 20)
        }
        .padding(.top, 20)
    }
    
    private var statusFilterSection: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                WebsiteLeadFilterChip(
                    title: "All",
                    isSelected: selectedStatus == nil
                ) {
                    selectedStatus = nil
                }
                
                ForEach(WebsiteLeadStatus.allCases, id: \.self) { status in
                    WebsiteLeadFilterChip(
                        title: status.rawValue.capitalized,
                        isSelected: selectedStatus == status,
                        color: status.color
                    ) {
                        selectedStatus = selectedStatus == status ? nil : status
                    }
                }
            }
            .padding(.horizontal, 20)
        }
        .padding(.vertical, 16)
    }
    
    private var leadsList: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                if websiteLeadSync.isSyncing && websiteLeadSync.websiteLeads.isEmpty {
                    loadingView
                } else if filteredLeads.isEmpty {
                    emptyStateView
                } else {
                    ForEach(filteredLeads) { lead in
                        WebsiteLeadRowView(lead: lead) {
                            selectedLead = lead
                            showingLeadDetail = true
                        }
                        .contextMenu {
                            Button(action: {
                                Task {
                                    await websiteLeadSync.updateLeadStatus(lead.id, status: .contacted)
                                }
                            }) {
                                Label("Mark Contacted", systemImage: "phone.fill")
                            }
                            
                            if lead.status == .contacted {
                                Button(action: {
                                    Task {
                                        await websiteLeadSync.updateLeadStatus(lead.id, status: .validated)
                                    }
                                }) {
                                    Label("Mark Validated", systemImage: "checkmark.shield.fill")
                                }
                            }
                            
                            if lead.status == .validated {
                                Button(action: {
                                    // Convert to local lead and create proposal
                                    convertToLocalLead(lead)
                                }) {
                                    Label("Create Proposal", systemImage: "arrow.right.circle.fill")
                                }
                            }
                        }
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 100)
        }
    }
    
    private var syncButton: some View {
        Button(action: {
            Task {
                await websiteLeadSync.manualSync()
            }
        }) {
            Image(systemName: websiteLeadSync.isSyncing ? "arrow.clockwise" : "arrow.clockwise.circle")
                .foregroundColor(Color("TreeShopGreen"))
                .rotationEffect(.degrees(websiteLeadSync.isSyncing ? 360 : 0))
                .animation(websiteLeadSync.isSyncing ? .linear(duration: 1).repeatForever(autoreverses: false) : .default, value: websiteLeadSync.isSyncing)
        }
    }
    
    private var syncStatusIndicator: some View {
        HStack {
            if let lastSync = websiteLeadSync.apiService.lastSyncTime {
                Text(lastSync.formatted(date: .omitted, time: .shortened))
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            
            Circle()
                .fill(websiteLeadSync.apiService.isConnected ? Color("TreeShopGreen") : .red)
                .frame(width: 8, height: 8)
        }
    }
    
    private var loadingView: some View {
        VStack(spacing: 16) {
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle(tint: Color("TreeShopGreen")))
            
            Text("Syncing website leads...")
                .font(.subheadline)
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 60)
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: "globe.badge.chevron.backward")
                .font(.system(size: 60))
                .foregroundColor(.gray)
            
            VStack(spacing: 8) {
                Text("No Website Leads Found")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                
                Text(searchText.isEmpty ? "Website leads will appear here automatically" : "No leads match your search")
                    .font(.body)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
            }
            
            if let error = websiteLeadSync.syncError {
                Text("Sync Error: \(error)")
                    .font(.caption)
                    .foregroundColor(.red)
                    .padding()
                    .background(Color.red.opacity(0.1))
                    .cornerRadius(8)
            }
        }
        .padding(.vertical, 60)
    }
    
    private func getLeadsThisWeek() -> Int {
        let oneWeekAgo = Calendar.current.date(byAdding: .day, value: -7, to: Date()) ?? Date()
        return websiteLeadSync.websiteLeads.filter { $0.createdDate >= oneWeekAgo }.count
    }
    
    private func getTotalLeadValue() -> Double {
        return websiteLeadSync.websiteLeads.reduce(0) { $0 + $1.instantQuote }
    }
    
    private func convertToLocalLead(_ websiteLead: WebsiteLead) {
        let localLead = websiteLeadSync.convertToLocalLead(websiteLead)
        leadManager.addLead(localLead)
        
        // Update website lead status
        Task {
            await websiteLeadSync.updateLeadStatus(websiteLead.id, status: .accepted, notes: "Converted to local lead")
        }
    }
}

struct WebsiteLeadFilterChip: View {
    let title: String
    let isSelected: Bool
    let color: Color
    let action: () -> Void
    
    init(title: String, isSelected: Bool, color: Color = Color("TreeShopGreen"), action: @escaping () -> Void) {
        self.title = title
        self.isSelected = isSelected
        self.color = color
        self.action = action
    }
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(isSelected ? .black : .gray)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(isSelected ? color : Color.white.opacity(0.1))
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(isSelected ? color : Color.white.opacity(0.2), lineWidth: 1)
                        )
                )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct WebsiteLeadRowView: View {
    let lead: WebsiteLead
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 12) {
                // Header row
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(lead.name)
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                        
                        Text(lead.email)
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing, spacing: 4) {
                        // Status badge
                        HStack(spacing: 4) {
                            Image(systemName: lead.status.systemImage)
                                .font(.caption)
                            Text(lead.status.rawValue.capitalized)
                                .font(.caption)
                                .fontWeight(.medium)
                        }
                        .foregroundColor(lead.status.color)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(
                            RoundedRectangle(cornerRadius: 6)
                                .fill(lead.status.color.opacity(0.2))
                        )
                        
                        // Quote amount
                        Text("$\(String(format: "%.0f", lead.instantQuote))")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(Color("TreeShopGreen"))
                    }
                }
                
                // Details row
                HStack {
                    Label(lead.source.displayName, systemImage: lead.source.systemImage)
                        .font(.caption)
                        .foregroundColor(.gray)
                    
                    Label(lead.packageType.rawValue, systemImage: "tree")
                        .font(.caption)
                        .foregroundColor(.gray)
                    
                    if let acreage = lead.estimatedAcreage, acreage > 0 {
                        Label(String(format: "%.1f acres", acreage), systemImage: "leaf")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    
                    Spacer()
                    
                    Text(lead.createdDate.formatted(date: .abbreviated, time: .omitted))
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.white.opacity(0.05))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(lead.source == .fltreeshopCom ? Color("TreeShopGreen").opacity(0.3) : Color.white.opacity(0.1), lineWidth: 1)
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    NavigationView {
        WebsiteLeadListView()
            .environmentObject(LeadManager())
            .environmentObject(CustomerManager())
            .environmentObject(ProposalManager())
    }
}