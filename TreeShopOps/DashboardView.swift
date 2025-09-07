import SwiftUI

struct DashboardView: View {
    @EnvironmentObject var appState: AppStateManager
    @StateObject private var userProfile = UserProfileManager()
    @StateObject private var businessConfig = BusinessConfigManager()
    
    // Computed properties for better performance
    private var leadManager: LeadManager { appState.leadManager }
    private var proposalManager: ProposalManager { appState.proposalManager }
    private var workOrderManager: WorkOrderManager { appState.workOrderManager }
    private var invoiceManager: InvoiceManager { appState.invoiceManager }
    private var customerManager: CustomerManager { appState.customerManager }
    
    @State private var showingAddLead = false
    @State private var showingAddProposal = false
    @State private var showingAddWorkOrder = false
    @State private var showingAddInvoice = false
    
    var body: some View {
        ZStack {
            Color("TreeShopBlack").ignoresSafeArea()
            
            ScrollView {
                LazyVStack(spacing: 24) {
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
            NavigationView {
                AddEditLeadView()
                    .environmentObject(appState.leadManager)
                    .environmentObject(appState.customerManager)
            }
        }
        .sheet(isPresented: $showingAddProposal) {
            NavigationView {
                AddEditProposalView()
                    .environmentObject(appState.proposalManager)
                    .environmentObject(appState.leadManager)
                    .environmentObject(appState.customerManager)
            }
        }
        .sheet(isPresented: $showingAddWorkOrder) {
            NavigationView {
                AddEditWorkOrderView()
                    .environmentObject(appState.workOrderManager)
                    .environmentObject(appState.proposalManager)
                    .environmentObject(appState.customerManager)
            }
        }
        .sheet(isPresented: $showingAddInvoice) {
            NavigationView {
                AddEditInvoiceView()
                    .environmentObject(appState.invoiceManager)
                    .environmentObject(appState.workOrderManager)
                    .environmentObject(appState.customerManager)
            }
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
            
            // Pipeline stats grid - Real data
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
                OptimizedQuickActionButton(
                    title: "New Lead",
                    icon: "person.crop.circle.badge.plus",
                    color: Color("TreeShopBlue")
                ) {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        showingAddLead = true
                    }
                }
                
                OptimizedQuickActionButton(
                    title: "New Proposal", 
                    icon: "doc.badge.plus",
                    color: .purple
                ) {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        showingAddProposal = true
                    }
                }
                
                OptimizedQuickActionButton(
                    title: "Schedule Work",
                    icon: "calendar.badge.plus",
                    color: .orange
                ) {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        showingAddWorkOrder = true
                    }
                }
                
                OptimizedQuickActionButton(
                    title: "Create Invoice",
                    icon: "dollarsign.square",
                    color: Color("TreeShopGreen")
                ) {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        showingAddInvoice = true
                    }
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

// MARK: - Optimized Components for Performance

struct OptimizedStatsGrid: View {
    let leadManager: LeadManager
    let proposalManager: ProposalManager
    let workOrderManager: WorkOrderManager
    let invoiceManager: InvoiceManager
    
    // Memoized computed properties to prevent excessive recalculation
    private var leadStats: (total: Int, new: Int) {
        let leads = leadManager.leads
        return (total: leads.count, new: leads.filter { $0.status == .new }.count)
    }
    
    private var proposalStats: (total: Int, sent: Int) {
        let proposals = proposalManager.proposals
        return (total: proposals.count, sent: proposals.filter { $0.status == .sent }.count)
    }
    
    private var workOrderStats: (total: Int, active: Int) {
        let workOrders = workOrderManager.workOrders
        return (total: workOrders.count, active: workOrders.filter { $0.status == .inProgress }.count)
    }
    
    private var revenueStats: (total: Double, outstanding: Double) {
        return (total: invoiceManager.getTotalRevenue(), outstanding: invoiceManager.getOutstandingAmount())
    }
    
    var body: some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 12) {
            DashboardStatCard(
                title: "Leads",
                value: "\(leadStats.total)",
                subtitle: "\(leadStats.new) new",
                icon: "person.crop.circle.badge.plus",
                color: Color("TreeShopBlue")
            )
            
            DashboardStatCard(
                title: "Proposals",
                value: "\(proposalStats.total)",
                subtitle: "\(proposalStats.sent) sent",
                icon: "doc.text",
                color: .purple
            )
            
            DashboardStatCard(
                title: "Work Orders",
                value: "\(workOrderStats.total)",
                subtitle: "\(workOrderStats.active) active",
                icon: "hammer",
                color: .orange
            )
            
            DashboardStatCard(
                title: "Revenue",
                value: "$\(String(format: "%.0f", revenueStats.total))",
                subtitle: "$\(String(format: "%.0f", revenueStats.outstanding)) pending",
                icon: "dollarsign.circle",
                color: Color("TreeShopGreen")
            )
        }
    }
}

struct OptimizedQuickActionButton: View {
    let title: String
    let icon: String
    let color: Color
    let action: () -> Void
    
    @State private var isPressed = false
    
    var body: some View {
        Button(action: {
            // Haptic feedback for better UX
            let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
            impactFeedback.impactOccurred()
            action()
        }) {
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
                    .fill(Color.white.opacity(isPressed ? 0.15 : 0.05))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(color.opacity(0.3), lineWidth: 1)
                    )
            )
            .scaleEffect(isPressed ? 0.95 : 1.0)
        }
        .buttonStyle(PlainButtonStyle())
        .onLongPressGesture(minimumDuration: 0, maximumDistance: .infinity, pressing: { pressing in
            withAnimation(.easeInOut(duration: 0.1)) {
                isPressed = pressing
            }
        }, perform: {})
    }
}

#Preview {
    NavigationView {
        DashboardView()
            .environmentObject(AppStateManager())
    }
}