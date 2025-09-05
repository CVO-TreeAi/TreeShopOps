import SwiftUI

struct ProposalListView: View {
    @EnvironmentObject var proposalManager: ProposalManager
    @State private var searchText = ""
    @State private var selectedStatus: ProposalStatus? = nil
    @State private var showingAddProposal = false
    @State private var selectedProposal: Proposal? = nil
    @State private var showingProposalDetail = false
    
    var filteredProposals: [Proposal] {
        var proposals = proposalManager.searchProposals(searchText)
        
        if let status = selectedStatus {
            proposals = proposals.filter { $0.status == status }
        }
        
        return proposals.sorted { $0.dateUpdated > $1.dateUpdated }
    }
    
    var body: some View {
        ZStack {
            Color("TreeShopBlack").ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header with search and filter
                headerSection
                
                // Status filter chips
                statusFilterSection
                
                // Proposals list
                proposalsList
            }
        }
        .navigationTitle("Proposals")
        .navigationBarTitleDisplayMode(.large)
        .navigationBarItems(
            trailing: Button(action: {
                showingAddProposal = true
            }) {
                Image(systemName: "plus.circle.fill")
                    .font(.title2)
                    .foregroundColor(Color("TreeShopGreen"))
            }
        )
        .sheet(isPresented: $showingAddProposal) {
            AddEditProposalView()
                .environmentObject(proposalManager)
        }
        .sheet(isPresented: $showingProposalDetail) {
            if let proposal = selectedProposal {
                ProposalDetailView(proposal: proposal)
                    .environmentObject(proposalManager)
            }
        }
        .searchable(text: $searchText, prompt: "Search proposals...")
    }
    
    private var headerSection: some View {
        VStack(spacing: 16) {
            // Stats cards
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: 3), spacing: 12) {
                StandardStatCard(
                    title: "Total",
                    value: "\(proposalManager.proposals.count)",
                    icon: "doc.text",
                    color: .gray
                )
                
                StandardStatCard(
                    title: "Sent",
                    value: "\(proposalManager.getProposalsByStatus(.sent).count)",
                    icon: "paperplane",
                    color: Color("TreeShopBlue")
                )
                
                StandardStatCard(
                    title: "Accepted",
                    value: "\(proposalManager.getProposalsByStatus(.accepted).count)",
                    icon: "checkmark.circle",
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
                FilterChip(
                    title: "All",
                    isSelected: selectedStatus == nil
                ) {
                    selectedStatus = nil
                }
                
                ForEach(ProposalStatus.allCases, id: \.self) { status in
                    FilterChip(
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
    
    private var proposalsList: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                if filteredProposals.isEmpty {
                    emptyStateView
                } else {
                    ForEach(filteredProposals) { proposal in
                        ProposalRowView(proposal: proposal) {
                            selectedProposal = proposal
                            showingProposalDetail = true
                        }
                        .contextMenu {
                            Button(action: {
                                selectedProposal = proposal
                                showingAddProposal = true
                            }) {
                                Label("Edit", systemImage: "pencil")
                            }
                            
                            Button(role: .destructive, action: {
                                withAnimation(.spring()) {
                                    proposalManager.deleteProposal(proposal)
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
            Image(systemName: "doc.text.magnifyingglass")
                .font(.system(size: 60))
                .foregroundColor(.gray)
            
            VStack(spacing: 8) {
                Text("No Proposals Found")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                
                Text(searchText.isEmpty ? "Create your first proposal to get started" : "No proposals match your search")
                    .font(.body)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
            }
            
            if searchText.isEmpty {
                Button(action: {
                    showingAddProposal = true
                }) {
                    HStack {
                        Image(systemName: "plus.circle.fill")
                        Text("Create Proposal")
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

struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 10) {
            Image(systemName: icon)
                .font(.title)
                .foregroundColor(color)
            
            VStack(spacing: 4) {
                Text(value)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                Text(title)
                    .font(.caption)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
            }
        }
        .frame(maxWidth: .infinity)
        .frame(height: 80)
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white.opacity(0.05))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(color.opacity(0.2), lineWidth: 1)
                )
        )
    }
}

struct FilterChip: View {
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

struct ProposalRowView: View {
    let proposal: Proposal
    let onTap: () -> Void
    
    private var isExpiredSoon: Bool {
        Calendar.current.dateInterval(of: .day, for: Date())?.contains(proposal.validUntil) ?? false ||
        proposal.validUntil < Date()
    }
    
    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 12) {
                // Header row
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(proposal.projectTitle.isEmpty ? "Untitled Proposal" : proposal.projectTitle)
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .lineLimit(2)
                        
                        Text(proposal.customerName)
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing, spacing: 4) {
                        // Status badge
                        HStack(spacing: 4) {
                            Image(systemName: proposal.status.systemImage)
                                .font(.caption)
                            Text(proposal.status.rawValue)
                                .font(.caption)
                                .fontWeight(.medium)
                        }
                        .foregroundColor(proposal.status.color)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(
                            RoundedRectangle(cornerRadius: 6)
                                .fill(proposal.status.color.opacity(0.2))
                        )
                        
                        // Amount
                        Text("$\(proposal.totalAmount, specifier: "%.2f")")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(Color("TreeShopGreen"))
                    }
                }
                
                // Details row
                HStack {
                    Label(proposal.dateUpdated.formatted(date: .abbreviated, time: .omitted), 
                          systemImage: "calendar")
                        .font(.caption)
                        .foregroundColor(.gray)
                    
                    Spacer()
                    
                    if isExpiredSoon {
                        Label("Expires Soon", systemImage: "exclamationmark.triangle.fill")
                            .font(.caption)
                            .foregroundColor(.orange)
                    }
                }
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
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    NavigationView {
        ProposalListView()
            .environmentObject(ProposalManager())
    }
}