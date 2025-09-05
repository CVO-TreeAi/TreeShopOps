import SwiftUI

struct SettingsMainView: View {
    @ObservedObject var pricingModel: PricingModel
    @StateObject private var userProfile = UserProfileManager()
    @State private var showingUserProfile = false
    @State private var showingBusinessProfile = false
    @State private var showingPricingSettings = false
    
    var body: some View {
        ZStack {
            Color("TreeShopBlack").ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 20) {
                    // User profile section
                    userSection
                    
                    // Business management
                    businessSection
                    
                    // App settings
                    appSection
                    
                    // About section
                    aboutSection
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 100)
            }
        }
        .navigationTitle("Settings")
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
    
    private var userSection: some View {
        SettingsSection(title: "User Profile", icon: "person.circle.fill") {
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
                                    .foregroundColor(.white)
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
    
    private var businessSection: some View {
        SettingsSection(title: "Business Management", icon: "building.2.fill") {
            VStack(spacing: 12) {
                SettingsRowButton(
                    title: "Business Profile",
                    subtitle: "Company info, contact details",
                    icon: "building.columns.fill",
                    color: Color("TreeShopBlue")
                ) {
                    showingBusinessProfile = true
                }
                
                SettingsRowButton(
                    title: "Pricing Settings",
                    subtitle: "Package rates, costs, markup",
                    icon: "dollarsign.circle.fill",
                    color: Color("TreeShopGreen")
                ) {
                    showingPricingSettings = true
                }
            }
        }
    }
    
    private var appSection: some View {
        SettingsSection(title: "App Settings", icon: "gearshape.fill") {
            VStack(spacing: 12) {
                SettingsToggleRow(
                    title: "Dark Mode",
                    subtitle: "Always enabled for TreeShop Ops",
                    icon: "moon.fill",
                    isOn: .constant(true)
                )
                .disabled(true)
                
                SettingsToggleRow(
                    title: "Notifications",
                    subtitle: "Follow-ups and overdue alerts",
                    icon: "bell.fill",
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
        SettingsSection(title: "About", icon: "info.circle.fill") {
            VStack(spacing: 12) {
                HStack {
                    Image(systemName: "tree.fill")
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

struct SettingsSection<Content: View>: View {
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

struct SettingsRowButton: View {
    let title: String
    let subtitle: String
    let icon: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
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
                    .fill(Color.white.opacity(0.05))
                    .stroke(Color.white.opacity(0.1), lineWidth: 1)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct SettingsToggleRow: View {
    let title: String
    let subtitle: String
    let icon: String
    @Binding var isOn: Bool
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(Color("TreeShopGreen"))
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
            
            Toggle("", isOn: $isOn)
                .labelsHidden()
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.white.opacity(0.05))
                .stroke(Color.white.opacity(0.1), lineWidth: 1)
        )
    }
}

#Preview {
    NavigationView {
        SettingsMainView(pricingModel: PricingModel())
    }
}