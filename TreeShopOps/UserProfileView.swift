import SwiftUI

struct UserProfileView: View {
    @StateObject private var userProfile = UserProfileManager()
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            ZStack {
                Color("TreeShopBlack").ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 20) {
                        // Profile header
                        profileHeader
                        
                        // Personal information
                        personalInfoSection
                        
                        // App preferences
                        preferencesSection
                        
                        // Account actions
                        accountActionsSection
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 100)
                }
            }
            .navigationTitle("User Profile")
            .navigationBarTitleDisplayMode(.large)
            .navigationBarItems(
                leading: Button("Cancel") {
                    presentationMode.wrappedValue.dismiss()
                }
                .foregroundColor(.white),
                
                trailing: Button("Save") {
                    userProfile.saveProfile()
                    presentationMode.wrappedValue.dismiss()
                }
                .foregroundColor(Color("TreeShopGreen"))
                .fontWeight(.semibold)
            )
        }
    }
    
    private var profileHeader: some View {
        VStack(spacing: 16) {
            // Profile picture placeholder
            Circle()
                .fill(Color("TreeShopGreen"))
                .frame(width: 80, height: 80)
                .overlay(
                    Text(userProfile.initials)
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                )
            
            VStack(spacing: 4) {
                Text(userProfile.fullName)
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                
                Text(userProfile.role)
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
        }
        .frame(maxWidth: .infinity)
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
    
    private var personalInfoSection: some View {
        ProfileSection(title: "Personal Information", icon: "person.fill") {
            VStack(spacing: 16) {
                ProfileField(title: "First Name", text: $userProfile.firstName, placeholder: "First name")
                ProfileField(title: "Last Name", text: $userProfile.lastName, placeholder: "Last name")
                ProfileField(title: "Email", text: $userProfile.email, placeholder: "user@email.com")
                ProfileField(title: "Phone", text: $userProfile.phone, placeholder: "(555) 123-4567")
                ProfileField(title: "Role/Title", text: $userProfile.role, placeholder: "Operations Manager")
            }
        }
    }
    
    private var preferencesSection: some View {
        ProfileSection(title: "App Preferences", icon: "gearshape.fill") {
            VStack(spacing: 16) {
                Toggle("Enable Notifications", isOn: $userProfile.notificationsEnabled)
                    .foregroundColor(.white)
                    .padding(12)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.white.opacity(0.1))
                            .stroke(Color.white.opacity(0.2), lineWidth: 1)
                    )
                
                Toggle("Auto-save Drafts", isOn: $userProfile.autoSaveDrafts)
                    .foregroundColor(.white)
                    .padding(12)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.white.opacity(0.1))
                            .stroke(Color.white.opacity(0.2), lineWidth: 1)
                    )
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Default Follow-up Days")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.white)
                    
                    Stepper(value: $userProfile.defaultFollowUpDays, in: 1...30) {
                        Text("\(userProfile.defaultFollowUpDays) days")
                            .foregroundColor(.white)
                    }
                    .padding(12)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.white.opacity(0.1))
                            .stroke(Color.white.opacity(0.2), lineWidth: 1)
                    )
                }
            }
        }
    }
    
    private var accountActionsSection: some View {
        ProfileSection(title: "Account", icon: "shield.fill") {
            VStack(spacing: 12) {
                Button(action: {
                    // Export data
                }) {
                    HStack {
                        Image(systemName: "square.and.arrow.up")
                        Text("Export Data")
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    .foregroundColor(.white)
                    .padding(12)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.white.opacity(0.1))
                            .stroke(Color.white.opacity(0.2), lineWidth: 1)
                    )
                }
                
                Button(action: {
                    // Clear cache
                }) {
                    HStack {
                        Image(systemName: "trash.circle")
                        Text("Clear App Cache")
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    .foregroundColor(.white)
                    .padding(12)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.white.opacity(0.1))
                            .stroke(Color.white.opacity(0.2), lineWidth: 1)
                    )
                }
            }
        }
    }
}

struct ProfileSection<Content: View>: View {
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

struct ProfileField: View {
    let title: String
    @Binding var text: String
    let placeholder: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(.white)
            
            TextField(placeholder, text: $text)
                .textFieldStyle(PlainTextFieldStyle())
                .foregroundColor(.white)
                .padding(12)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.white.opacity(0.1))
                        .stroke(Color.white.opacity(0.2), lineWidth: 1)
                )
        }
    }
}

class UserProfileManager: ObservableObject {
    @Published var firstName: String = ""
    @Published var lastName: String = ""
    @Published var email: String = ""
    @Published var phone: String = ""
    @Published var role: String = "Operations Manager"
    @Published var notificationsEnabled: Bool = true
    @Published var autoSaveDrafts: Bool = true
    @Published var defaultFollowUpDays: Int = 3
    
    var fullName: String {
        "\(firstName) \(lastName)".trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    var initials: String {
        let names = [firstName, lastName].filter { !$0.isEmpty }
        return names.map { String($0.prefix(1).uppercased()) }.joined()
    }
    
    private let userProfileKey = "UserProfile"
    
    init() {
        loadProfile()
    }
    
    func saveProfile() {
        let profileData: [String: Any] = [
            "firstName": firstName,
            "lastName": lastName,
            "email": email,
            "phone": phone,
            "role": role,
            "notificationsEnabled": notificationsEnabled,
            "autoSaveDrafts": autoSaveDrafts,
            "defaultFollowUpDays": defaultFollowUpDays
        ]
        
        UserDefaults.standard.set(profileData, forKey: userProfileKey)
    }
    
    private func loadProfile() {
        if let data = UserDefaults.standard.dictionary(forKey: userProfileKey) {
            firstName = data["firstName"] as? String ?? ""
            lastName = data["lastName"] as? String ?? ""
            email = data["email"] as? String ?? ""
            phone = data["phone"] as? String ?? ""
            role = data["role"] as? String ?? "Operations Manager"
            notificationsEnabled = data["notificationsEnabled"] as? Bool ?? true
            autoSaveDrafts = data["autoSaveDrafts"] as? Bool ?? true
            defaultFollowUpDays = data["defaultFollowUpDays"] as? Int ?? 3
        }
    }
}

#Preview {
    UserProfileView()
}