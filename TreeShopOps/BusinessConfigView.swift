import SwiftUI

struct BusinessConfigView: View {
    @StateObject private var businessConfig = BusinessConfigManager()
    @Environment(\.presentationMode) var presentationMode
    
    @State private var tempCompanyName: String = ""
    @State private var tempBusinessType: String = ""
    
    @State private var showingPresets = false
    
    var body: some View {
        NavigationView {
            ZStack {
                Color("TreeShopBlack").ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Company Branding Section
                        brandingSection
                        
                        // Preset Templates Section
                        presetTemplatesSection
                        
                        // Save Button
                        saveButton
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 100)
                }
            }
            .navigationTitle("Business Configuration")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(
                leading: Button("Cancel") {
                    presentationMode.wrappedValue.dismiss()
                }
                .foregroundColor(.white),
                
                trailing: Button("Save") {
                    saveConfiguration()
                    presentationMode.wrappedValue.dismiss()
                }
                .foregroundColor(Color("TreeShopGreen"))
            )
            .onAppear {
                loadCurrentConfig()
            }
        }
    }
    
    private var brandingSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            SectionHeader(title: "Company Branding", icon: "building.2")
            
            VStack(spacing: 16) {
                CustomTextField(
                    title: "Company Name",
                    text: $tempCompanyName,
                    placeholder: "Your Forestry Company"
                )
                
                CustomTextField(
                    title: "Business Type",
                    text: $tempBusinessType,
                    placeholder: "Forestry Services Description"
                )
            }
        }
        .sectionStyle()
    }
    
    
    private var presetTemplatesSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            SectionHeader(title: "Quick Setup Templates", icon: "wand.and.stars")
            
            VStack(spacing: 12) {
                PresetButton(
                    title: "Forest Management",
                    description: "Professional forestry & land management services",
                    icon: "tree.circle.fill",
                    color: Color(hex: "#228B22")
                ) {
                    applyPreset(BusinessConfigManager.forestryPreset())
                }
                
                PresetButton(
                    title: "Land Clearing",
                    description: "Land clearing & site preparation services",
                    icon: "hammer.circle.fill",
                    color: Color(hex: "#FF6B35")
                ) {
                    applyPreset(BusinessConfigManager.landClearingPreset())
                }
                
                PresetButton(
                    title: "Mulching Services",
                    description: "Professional mulching & brush removal",
                    icon: "leaf.circle.fill",
                    color: Color(hex: "#8B4513")
                ) {
                    applyPreset(BusinessConfigManager.mulchingPreset())
                }
            }
        }
        .sectionStyle()
    }
    
    private var saveButton: some View {
        Button(action: {
            saveConfiguration()
            presentationMode.wrappedValue.dismiss()
        }) {
            HStack {
                Image(systemName: "checkmark.circle.fill")
                Text("Save Configuration")
            }
            .font(.headline)
            .foregroundColor(.black)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(Color("TreeShopGreen"))
            .cornerRadius(12)
        }
    }
    
    private func loadCurrentConfig() {
        tempCompanyName = businessConfig.config.companyName
        tempBusinessType = businessConfig.config.businessType
    }
    
    private func saveConfiguration() {
        businessConfig.updateCompanyName(tempCompanyName)
        businessConfig.updateBusinessType(tempBusinessType)
    }
    
    private func applyPreset(_ preset: BusinessConfig) {
        tempCompanyName = preset.companyName
        tempBusinessType = preset.businessType
    }
}

struct SectionHeader: View {
    let title: String
    let icon: String
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(Color("TreeShopGreen"))
            
            Text(title)
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(.white)
        }
    }
}

struct CustomTextField: View {
    let title: String
    @Binding var text: String
    let placeholder: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(.gray)
            
            TextField(placeholder, text: $text)
                .textFieldStyle(PlainTextFieldStyle())
                .foregroundColor(.white)
                .padding(12)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.white.opacity(0.05))
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.white.opacity(0.1), lineWidth: 1)
                        )
                )
        }
    }
}

struct PresetButton: View {
    let title: String
    let description: String
    let icon: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(color)
                    .frame(width: 32)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                    
                    Text(description)
                        .font(.caption)
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
                    .fill(Color.white.opacity(0.03))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(color.opacity(0.2), lineWidth: 1)
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

extension View {
    func sectionStyle() -> some View {
        self
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

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

#Preview {
    BusinessConfigView()
}