import SwiftUI

struct MenuView: View {
    @ObservedObject var pricingModel: PricingModel
    @EnvironmentObject var leadManager: LeadManager
    @EnvironmentObject var proposalManager: ProposalManager
    @EnvironmentObject var workOrderManager: WorkOrderManager
    @EnvironmentObject var invoiceManager: InvoiceManager
    @StateObject private var userProfile = UserProfileManager()
    
    @State private var showingUserProfile = false
    @State private var showingBusinessProfile = false
    @State private var showingPricingSettings = false
    
    var body: some View {
        ZStack {
            Color("TreeShopBlack").ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 24) {
                    // User header
                    userHeaderSection
                    
                    // Pipeline overview dashboard
                    pipelineOverview
                    
                    // Quick actions
                    quickActionsSection
                    
                    // Business management
                    businessManagementSection
                    
                    // System and app info
                    systemSection
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 100)
            }
        }
        .navigationTitle("Menu")
        .navigationBarTitleDisplayMode(.large)
        .sheet(isPresented: $showingUserProfile) {
            UserProfileView()
        }
        .sheet(isPresented: $showingBusinessProfile) {
            BusinessProfileView(pricingModel: pricingModel)
        }
        .sheet(isPresented: $showingPricingSettings) {
            SettingsView(pricingModel: pricingModel)
        }
    }
    
    private var userHeaderSection: some View {
        HStack(spacing: 16) {
            // Profile picture
            Circle()
                .fill(Color("TreeShopGreen"))
                .frame(width: 60, height: 60)
                .overlay(
                    Text(userProfile.initials.isEmpty ? "U" : userProfile.initials)
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                )
            
            VStack(alignment: .leading, spacing: 4) {
                Text(userProfile.fullName.isEmpty ? "Welcome to TreeShop Ops" : "Welcome, \(userProfile.firstName)")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                
                Text(userProfile.role.isEmpty ? "Tap profile to configure" : userProfile.role)
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            Button(action: {
                showingUserProfile = true
            }) {
                Image(systemName: "person.circle")
                    .font(.title2)
                    .foregroundColor(Color("TreeShopGreen"))
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
    
    private var pipelineOverview: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "chart.bar.fill")
                    .foregroundColor(Color("TreeShopGreen"))
                
                Text("Pipeline Overview")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
            }
            
            // Pipeline stats grid
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 12) {
                PipelineStatCard(
                    title: "Leads",
                    value: "\(leadManager.leads.count)",
                    subtitle: "\(leadManager.getLeadsByStatus(.new).count) new",
                    icon: "person.crop.circle.badge.plus",
                    color: Color("TreeShopBlue")
                )
                
                PipelineStatCard(
                    title: "Proposals",
                    value: "\(proposalManager.proposals.count)",
                    subtitle: "\(proposalManager.getProposalsByStatus(.sent).count) sent",
                    icon: "doc.text.fill",
                    color: .purple
                )
                
                PipelineStatCard(
                    title: "Work Orders",
                    value: "\(workOrderManager.workOrders.count)",
                    subtitle: "\(workOrderManager.getWorkOrdersByStatus(.inProgress).count) active",
                    icon: "hammer.fill",
                    color: .orange
                )
                
                PipelineStatCard(
                    title: "Revenue",
                    value: "$\(String(format: "%.0f", invoiceManager.getTotalRevenue()))",
                    subtitle: "$\(String(format: "%.0f", invoiceManager.getOutstandingAmount())) pending",
                    icon: "dollarsign.circle.fill",
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
                    // Navigate to add lead
                }
                
                QuickActionButton(
                    title: "New Proposal", 
                    icon: "doc.badge.plus",
                    color: .purple
                ) {
                    // Navigate to add proposal
                }
                
                QuickActionButton(
                    title: "Schedule Work",
                    icon: "calendar.badge.plus",
                    color: .orange
                ) {
                    // Navigate to add work order
                }
                
                QuickActionButton(
                    title: "Create Invoice",
                    icon: "dollarsign.square.fill",
                    color: Color("TreeShopGreen")
                ) {
                    // Navigate to add invoice
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
    
    private var businessManagementSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "building.2.fill")
                    .foregroundColor(Color("TreeShopGreen"))
                
                Text("Business Management")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
            }
            
            VStack(spacing: 8) {
                MenuRowButton(
                    title: "Business Profile",
                    subtitle: "Company info, contact details",
                    icon: "building.columns.fill",
                    color: Color("TreeShopBlue")
                ) {
                    showingBusinessProfile = true
                }
                
                MenuRowButton(
                    title: "Pricing Settings", 
                    subtitle: "Package rates, costs, markup",
                    icon: "dollarsign.circle.fill",
                    color: Color("TreeShopGreen")
                ) {
                    showingPricingSettings = true
                }
                
                MenuRowButton(
                    title: "Export Data",
                    subtitle: "Backup leads, proposals, invoices",
                    icon: "square.and.arrow.up.fill",
                    color: .gray
                ) {
                    // Export functionality
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
    
    private var systemSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "tree.fill")
                    .foregroundColor(Color("TreeShopGreen"))
                
                Text("TreeShop Ops")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
            }
            
            VStack(alignment: .leading, spacing: 8) {
                Text("Forestry Mulching & Land Clearing Operations")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                
                Text("Version 1.0.0")
                    .font(.caption)
                    .foregroundColor(.gray)
                
                Text("Built for professional land clearing operations")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            
            Divider()
                .background(Color.white.opacity(0.2))
            
            HStack {
                Text("Pipeline Status")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.white)
                
                Spacer()
                
                if getAllPipelineCount() > 0 {
                    Text("\(getAllPipelineCount()) total items")
                        .font(.caption)
                        .foregroundColor(Color("TreeShopGreen"))
                } else {
                    Text("Ready to go")
                        .font(.caption)
                        .foregroundColor(.gray)
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
    
    private func getAllPipelineCount() -> Int {
        return leadManager.leads.count + 
               proposalManager.proposals.count + 
               workOrderManager.workOrders.count + 
               invoiceManager.invoices.count
    }
}

struct PipelineStatCard: View {
    let title: String
    let value: String
    let subtitle: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundColor(color)
                
                Spacer()
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text(value)
                    .font(.title2)
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

struct MenuRowButton: View {
    let title: String
    let subtitle: String
    let icon: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundColor(color)
                    .frame(width: 24)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                    
                    Text(subtitle)
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
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
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    NavigationView {
        MenuView(pricingModel: PricingModel())
            .environmentObject(LeadManager())
            .environmentObject(ProposalManager())
            .environmentObject(WorkOrderManager())
            .environmentObject(InvoiceManager())
    }
}