import SwiftUI

struct LeadListView: View {
    @EnvironmentObject var leadManager: LeadManager
    @State private var searchText = ""
    @State private var selectedStatus: LeadStatus? = nil
    @State private var showingAddLead = false
    @State private var selectedLead: Lead? = nil
    @State private var showingLeadDetail = false
    
    var filteredLeads: [Lead] {
        var leads = leadManager.searchLeads(searchText)
        
        if let status = selectedStatus {
            leads = leads.filter { $0.status == status }
        }
        
        return leads.sorted { $0.dateUpdated > $1.dateUpdated }
    }
    
    var body: some View {
        ZStack {
            Color("TreeShopBlack").ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header with stats
                headerSection
                
                // Status filter chips
                statusFilterSection
                
                // Leads list
                leadsList
            }
        }
        .navigationTitle("Leads")
        .navigationBarTitleDisplayMode(.large)
        .navigationBarItems(
            trailing: Button(action: {
                showingAddLead = true
            }) {
                Image(systemName: "plus.circle.fill")
                    .font(.title2)
                    .foregroundColor(Color("TreeShopGreen"))
            }
        )
        .sheet(isPresented: $showingAddLead) {
            AddEditLeadView()
                .environmentObject(leadManager)
        }
        .sheet(isPresented: $showingLeadDetail) {
            if let lead = selectedLead {
                LeadDetailView(lead: lead)
                    .environmentObject(leadManager)
            }
        }
        .searchable(text: $searchText, prompt: "Search leads...")
    }
    
    private var headerSection: some View {
        VStack(spacing: 16) {
            // Stats cards
            HStack(spacing: 12) {
                LeadStatCard(
                    title: "Total",
                    value: "\(leadManager.leads.count)",
                    icon: "person.fill",
                    color: .gray
                )
                
                LeadStatCard(
                    title: "New",
                    value: "\(leadManager.getLeadsByStatus(.new).count)",
                    icon: "star.fill",
                    color: Color("TreeShopBlue")
                )
                
                LeadStatCard(
                    title: "Qualified",
                    value: "\(leadManager.getLeadsByStatus(.qualified).count)",
                    icon: "checkmark.circle.fill",
                    color: Color("TreeShopGreen")
                )
            }
            .padding(.horizontal, 20)
        }
        .padding(.top, 20)
    }
    
    private var statusFilterSection: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                LeadFilterChip(
                    title: "All",
                    isSelected: selectedStatus == nil
                ) {
                    selectedStatus = nil
                }
                
                ForEach(LeadStatus.allCases, id: \.self) { status in
                    LeadFilterChip(
                        title: status.rawValue,
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
                if filteredLeads.isEmpty {
                    emptyStateView
                } else {
                    ForEach(filteredLeads) { lead in
                        LeadRowView(lead: lead) {
                            selectedLead = lead
                            showingLeadDetail = true
                        }
                        .contextMenu {
                            Button(action: {
                                selectedLead = lead
                                showingAddLead = true
                            }) {
                                Label("Edit", systemImage: "pencil")
                            }
                            
                            if lead.status == .qualified {
                                Button(action: {
                                    // Convert to proposal
                                }) {
                                    Label("Convert to Proposal", systemImage: "arrow.right.circle")
                                }
                            }
                            
                            Button(role: .destructive, action: {
                                withAnimation(.spring()) {
                                    leadManager.deleteLead(lead)
                                }
                            }) {
                                Label("Delete", systemImage: "trash")
                            }
                        }
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 100)
        }
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: "person.crop.circle.badge.plus")
                .font(.system(size: 60))
                .foregroundColor(.gray)
            
            VStack(spacing: 8) {
                Text("No Leads Found")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                
                Text(searchText.isEmpty ? "Add your first lead to get started" : "No leads match your search")
                    .font(.body)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
            }
            
            if searchText.isEmpty {
                Button(action: {
                    showingAddLead = true
                }) {
                    HStack {
                        Image(systemName: "plus.circle.fill")
                        Text("Add Lead")
                    }
                    .font(.headline)
                    .foregroundColor(.black)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                    .background(Color("TreeShopGreen"))
                    .cornerRadius(12)
                }
            }
        }
        .padding(.vertical, 60)
    }
}

struct LeadStatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(color)
                
                Spacer()
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text(value)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                Text(title)
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(16)
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

struct LeadFilterChip: View {
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
                .foregroundColor(isSelected ? .white : .gray)
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

struct LeadRowView: View {
    let lead: Lead
    let onTap: () -> Void
    
    private var isUrgent: Bool {
        lead.urgency == .urgent || lead.urgency == .high
    }
    
    private var needsFollowUp: Bool {
        if let followUpDate = lead.followUpDate {
            return followUpDate <= Date()
        }
        return false
    }
    
    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 12) {
                // Header row
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(lead.fullName.isEmpty ? "New Lead" : lead.fullName)
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .lineLimit(1)
                        
                        Text(lead.projectDescription.isEmpty ? "Land clearing project" : lead.projectDescription)
                            .font(.subheadline)
                            .foregroundColor(.gray)
                            .lineLimit(2)
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing, spacing: 4) {
                        // Status badge
                        HStack(spacing: 4) {
                            Image(systemName: lead.status.systemImage)
                                .font(.caption)
                            Text(lead.status.rawValue)
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
                        
                        // Estimated value
                        if lead.estimatedValue > 0 {
                            Text("~$\(String(format: "%.0f", lead.estimatedValue))")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .foregroundColor(Color("TreeShopGreen"))
                        }
                    }
                }
                
                // Details row
                HStack {
                    Label(lead.dateCreated.formatted(date: .abbreviated, time: .omitted), 
                          systemImage: "calendar")
                        .font(.caption)
                        .foregroundColor(.gray)
                    
                    if lead.landSize > 0 {
                        Label(String(format: "%.1f acres", lead.landSize), 
                              systemImage: "leaf.fill")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    
                    Spacer()
                    
                    if needsFollowUp {
                        Label("Follow up due", systemImage: "bell.fill")
                            .font(.caption)
                            .foregroundColor(.orange)
                    } else if isUrgent {
                        Label(lead.urgency.rawValue, systemImage: lead.urgency.systemImage)
                            .font(.caption)
                            .foregroundColor(lead.urgency.color)
                    }
                }
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.white.opacity(0.05))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(isUrgent ? lead.urgency.color.opacity(0.5) : Color.white.opacity(0.1), lineWidth: isUrgent ? 2 : 1)
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    NavigationView {
        LeadListView()
            .environmentObject(LeadManager())
    }
}