import SwiftUI

struct MenuView: View {
    @ObservedObject var pricingModel: PricingModel
    @StateObject private var serviceItemManager = ServiceItemManager()
    @StateObject private var userProfile = UserProfileManager()
    
    @State private var showingUserProfile = false
    @State private var showingBusinessProfile = false
    @State private var showingPricingSettings = false
    @State private var showingServiceItems = false
    
    var body: some View {
        ZStack {
            Color("TreeShopBlack").ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 24) {
                    // Business management at top
                    businessManagementSection
                    
                    // App settings
                    appSettingsSection
                    
                    // User profile at bottom  
                    userProfileSection
                    
                    // About section
                    aboutSection
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
        .sheet(isPresented: $showingServiceItems) {
            NavigationView {
                ServiceItemListView()
                    .environmentObject(serviceItemManager)
            }
        }
    }
    
    private var userProfileSection: some View {
        SettingsSection(title: "User Profile", icon: "person.circle") {
            VStack(spacing: 12) {
                // User profile card
                Button(action: {
                    showingUserProfile = true
                }) {
                    HStack(spacing: 16) {
                        Circle()
                            .fill(Color("TreeShopGreen"))
                            .frame(width: 50, height: 50)
                            .overlay(
                                Text(userProfile.initials.isEmpty ? "U" : userProfile.initials)
                                    .font(.headline)
                                    .fontWeight(.bold)
                                    .foregroundColor(.black)
                            )
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text(userProfile.fullName.isEmpty ? "Set up your profile" : userProfile.fullName)
                                .font(.headline)
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                            
                            Text(userProfile.role.isEmpty ? "Tap to configure" : userProfile.role)
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                        
                        Spacer()
                        
                        Image(systemName: "chevron.right")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    .padding(16)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.white.opacity(0.05))
                            .stroke(Color.white.opacity(0.1), lineWidth: 1)
                    )
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
    }
    
    private var appSettingsSection: some View {
        SettingsSection(title: "App Settings", icon: "gearshape") {
            VStack(spacing: 12) {
                SettingsToggleRow(
                    title: "Dark Mode",
                    subtitle: "Always enabled for TreeShop Ops",
                    icon: "moon",
                    isOn: .constant(true)
                )
                .disabled(true)
                
                SettingsToggleRow(
                    title: "Notifications",
                    subtitle: "Follow-ups and overdue alerts",
                    icon: "bell",
                    isOn: $userProfile.notificationsEnabled
                )
                
                SettingsToggleRow(
                    title: "Auto-save Drafts",
                    subtitle: "Automatically save work in progress",
                    icon: "doc.badge.plus",
                    isOn: $userProfile.autoSaveDrafts
                )
            }
        }
    }
    
    private var aboutSection: some View {
        SettingsSection(title: "About", icon: "info.circle") {
            VStack(spacing: 12) {
                HStack {
                    Image(systemName: "tree")
                        .font(.title2)
                        .foregroundColor(Color("TreeShopGreen"))
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("TreeShop Ops")
                            .font(.headline)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                        
                        Text("Forestry Mulching & Land Clearing Operations")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                        
                        Text("Version 1.0.0")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    
                    Spacer()
                }
                .padding(16)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.white.opacity(0.05))
                        .stroke(Color.white.opacity(0.1), lineWidth: 1)
                )
            }
        }
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
                    title: "Service Items",
                    subtitle: "Manage forestry mulching and land clearing services",
                    icon: "list.bullet.rectangle.fill",
                    color: Color("TreeShopGreen")
                ) {
                    showingServiceItems = true
                }
                
                MenuRowButton(
                    title: "Pricing Settings", 
                    subtitle: "Package rates, costs, markup",
                    icon: "dollarsign.circle.fill",
                    color: Color("TreeShopBlue")
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