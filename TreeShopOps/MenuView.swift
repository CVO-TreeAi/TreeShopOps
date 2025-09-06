import SwiftUI

struct MenuView: View {
    @ObservedObject var pricingModel: PricingModel
    @StateObject private var serviceItemManager = ServiceItemManager()
    @StateObject private var userProfile = UserProfileManager()
    
    @State private var showingUserProfile = false
    @State private var showingBusinessProfile = false
    @State private var showingBusinessConfig = false
    @State private var showingPricingSettings = false
    @State private var showingServiceItems = false
    @State private var showingEquipment = false
    @State private var showingEmployees = false
    @State private var showingLoadouts = false
    
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
        .sheet(isPresented: $showingBusinessConfig) {
            BusinessConfigView()
        }
        .sheet(isPresented: $showingEquipment) {
            NavigationView {
                EquipmentListView()
                    .environmentObject(EquipmentManager())
            }
        }
        .sheet(isPresented: $showingEmployees) {
            NavigationView {
                EmployeeListView()
                    .environmentObject(EmployeeManager())
            }
        }
        .sheet(isPresented: $showingLoadouts) {
            NavigationView {
                LoadoutListView()
                    .environmentObject(LoadoutManager())
            }
        }
    }
    
    private var businessManagementSection: some View {
        SettingsSection(title: "Business Management", icon: "building.2") {
            VStack(spacing: 8) {
                MenuRowButton(
                    title: "Business Configuration",
                    subtitle: "Company branding, website integration",
                    icon: "gear.circle",
                    color: Color("TreeShopGreen")
                ) {
                    showingBusinessConfig = true
                }
                
                MenuRowButton(
                    title: "Business Profile",
                    subtitle: "Company info, contact details",
                    icon: "building.columns",
                    color: Color("TreeShopBlue")
                ) {
                    showingBusinessProfile = true
                }
                
                MenuRowButton(
                    title: "Service Items",
                    subtitle: "Manage forestry mulching and land clearing services",
                    icon: "list.bullet.rectangle",
                    color: .orange
                ) {
                    showingServiceItems = true
                }
                
                MenuRowButton(
                    title: "Equipment Directory",
                    subtitle: "Equipment inventory and cost tracking",
                    icon: "gear.circle",
                    color: Color("TreeShopGreen")
                ) {
                    showingEquipment = true
                }
                
                MenuRowButton(
                    title: "Employee Directory",
                    subtitle: "Workforce management and qualification tracking",
                    icon: "person.3.sequence",
                    color: Color("TreeShopBlue")
                ) {
                    showingEmployees = true
                }
                
                MenuRowButton(
                    title: "Loadout Builder",
                    subtitle: "Crew and equipment combinations with pricing",
                    icon: "rectangle.3.group",
                    color: .orange
                ) {
                    showingLoadouts = true
                }
                
                MenuRowButton(
                    title: "Pricing Settings", 
                    subtitle: "Package rates, costs, markup",
                    icon: "dollarsign.circle",
                    color: Color("TreeShopBlue")
                ) {
                    showingPricingSettings = true
                }
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
    }
}