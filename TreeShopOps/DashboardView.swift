import SwiftUI

struct DashboardView: View {
    @EnvironmentObject var leadManager: LeadManager
    @EnvironmentObject var proposalManager: ProposalManager
    @EnvironmentObject var workOrderManager: WorkOrderManager
    @EnvironmentObject var invoiceManager: InvoiceManager
    @EnvironmentObject var customerManager: CustomerManager
    @StateObject private var userProfile = UserProfileManager()
    @StateObject private var businessConfig = BusinessConfigManager()
    
    @State private var showingAddLead = false
    @State private var showingAddProposal = false
    @State private var showingAddWorkOrder = false
    @State private var showingAddInvoice = false
    
    var body: some View {
        ZStack {
            Color("TreeShopBlack").ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 24) {
                    // Welcome header
                    welcomeHeader
                    
                    // Pipeline overview dashboard
                    pipelineOverview
                    
                    // Quick actions
                    quickActionsSection
                    
                    // Recent activity (placeholder for future)
                    recentActivitySection
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 100)
            }
        }
        .navigationTitle("Dashboard")
        .navigationBarTitleDisplayMode(.large)
        .sheet(isPresented: $showingAddLead) {
            AddEditLeadView()
                .environmentObject(leadManager)
                .environmentObject(customerManager)
        }
        .sheet(isPresented: $showingAddProposal) {
            AddEditProposalView()
                .environmentObject(proposalManager)
                .environmentObject(leadManager)
                .environmentObject(customerManager)
        }
        .sheet(isPresented: $showingAddWorkOrder) {
            AddEditWorkOrderView()
                .environmentObject(workOrderManager)
                .environmentObject(proposalManager)
                .environmentObject(customerManager)
        }
        .sheet(isPresented: $showingAddInvoice) {
            AddEditInvoiceView()
                .environmentObject(invoiceManager)
                .environmentObject(workOrderManager)
                .environmentObject(customerManager)
        }
    }
    
    private var welcomeHeader: some View {
        HStack(spacing: 16) {
            // Profile picture
            Circle()
                .fill(Color("TreeShopGreen"))
                .frame(width: 60, height: 60)
                .overlay(
                    Text(userProfile.initials.isEmpty ? "T" : userProfile.initials)
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.black)
                )
            
            VStack(alignment: .leading, spacing: 4) {
                Text(userProfile.fullName.isEmpty ? "Welcome to \(businessConfig.displayName)" : "Welcome, \(userProfile.firstName)")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                
                Text(businessConfig.businessDescription)
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            // TreeShop logo
            Image(systemName: "tree.fill")
                .font(.title)
                .foregroundColor(Color("TreeShopGreen"))
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white.opacity(0.05))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.white.opacity(0.1), lineWidth: 1)
                )
        )
    }
    
    private var pipelineOverview: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "chart.bar.fill")
                    .foregroundColor(Color("TreeShopGreen"))
                
                Text("Business Pipeline")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
            }
            
            // Pipeline stats grid
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 12) {
                DashboardStatCard(
                    title: "Leads",
                    value: "\(leadManager.leads.count)",
                    subtitle: "\(leadManager.getLeadsByStatus(.new).count) new",
                    icon: "person.crop.circle.badge.plus",
                    color: Color("TreeShopBlue")
                )
                
                DashboardStatCard(
                    title: "Proposals",
                    value: "\(proposalManager.proposals.count)",
                    subtitle: "\(proposalManager.getProposalsByStatus(.sent).count) sent",
                    icon: "doc.text",
                    color: .purple
                )
                
                DashboardStatCard(
                    title: "Work Orders",
                    value: "\(workOrderManager.workOrders.count)",
                    subtitle: "\(workOrderManager.getWorkOrdersByStatus(.inProgress).count) active",
                    icon: "hammer",
                    color: .orange
                )
                
                DashboardStatCard(
                    title: "Revenue",
                    value: "$\(String(format: "%.0f", invoiceManager.getTotalRevenue()))",
                    subtitle: "$\(String(format: "%.0f", invoiceManager.getOutstandingAmount())) pending",
                    icon: "dollarsign.circle",
                    color: Color("TreeShopGreen")
                )
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white.opacity(0.05))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.white.opacity(0.1), lineWidth: 1)
                )
        )
    }
    
    private var quickActionsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "bolt.fill")
                    .foregroundColor(Color("TreeShopGreen"))
                
                Text("Quick Actions")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
            }
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 12) {
                QuickActionButton(
                    title: "New Lead",
                    icon: "person.crop.circle.badge.plus",
                    color: Color("TreeShopBlue")
                ) {
                    showingAddLead = true
                }
                
                QuickActionButton(
                    title: "New Proposal", 
                    icon: "doc.badge.plus",
                    color: .purple
                ) {
                    showingAddProposal = true
                }
                
                QuickActionButton(
                    title: "Schedule Work",
                    icon: "calendar.badge.plus",
                    color: .orange
                ) {
                    showingAddWorkOrder = true
                }
                
                QuickActionButton(
                    title: "Create Invoice",
                    icon: "dollarsign.square",
                    color: Color("TreeShopGreen")
                ) {
                    showingAddInvoice = true
                }
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white.opacity(0.05))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.white.opacity(0.1), lineWidth: 1)
                )
        )
    }
    
    private var recentActivitySection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "clock.fill")
                    .foregroundColor(Color("TreeShopGreen"))
                
                Text("Recent Activity")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                
                Spacer()
                
                Text("View All")
                    .font(.caption)
                    .foregroundColor(Color("TreeShopBlue"))
            }
            
            VStack(spacing: 8) {
                ActivityRow(
                    title: "System Ready",
                    subtitle: "TreeShop Ops is configured and ready for business",
                    icon: "checkmark.circle",
                    color: Color("TreeShopGreen"),
                    time: "Now"
                )
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white.opacity(0.05))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.white.opacity(0.1), lineWidth: 1)
                )
        )
    }
}

struct DashboardStatCard: View {
    let title: String
    let value: String
    let subtitle: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(color)
                
                Spacer()
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(value)
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.white)
                
                Text(subtitle)
                    .font(.caption)
                    .foregroundColor(.gray)
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .frame(height: 120)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white.opacity(0.03))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(color.opacity(0.2), lineWidth: 1)
                )
        )
    }
}

struct QuickActionButton: View {
    let title: String
    let icon: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.title)
                    .foregroundColor(color)
                
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 80)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.white.opacity(0.05))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(color.opacity(0.3), lineWidth: 1)
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct ActivityRow: View {
    let title: String
    let subtitle: String
    let icon: String
    let color: Color
    let time: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(color)
                .frame(width: 24)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.white)
                
                Text(subtitle)
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            Text(time)
                .font(.caption)
                .foregroundColor(.gray)
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.white.opacity(0.03))
                .stroke(Color.white.opacity(0.1), lineWidth: 1)
        )
    }
}

#Preview {
    NavigationView {
        DashboardView()
            .environmentObject(LeadManager())
            .environmentObject(ProposalManager())
            .environmentObject(WorkOrderManager())
            .environmentObject(InvoiceManager())
    }
}