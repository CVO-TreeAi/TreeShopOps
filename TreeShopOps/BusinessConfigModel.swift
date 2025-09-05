import Foundation

// MARK: - Business Configuration Model

struct BusinessConfig: Codable {
    var companyName: String = "TreeShop Ops"
    var businessType: String = "Forestry Mulching & Land Clearing"
    var primaryColor: String = "#00FF41" // TreeShopGreen
    var accentColor: String = "#1c4c9c" // TreeShopBlue
    var logoIcon: String = "tree.fill"
    
    // Convex Integration Settings
    var convexEnabled: Bool = false
    var convexURL: String = ""
    var convexEnvironment: ConvexEnvironment = .development
}

enum ConvexEnvironment: String, CaseIterable, Codable {
    case development = "development"
    case production = "production"
    
    var displayName: String {
        switch self {
        case .development:
            return "Development"
        case .production:
            return "Production"
        }
    }
}

// MARK: - Business Configuration Manager

class BusinessConfigManager: ObservableObject {
    @Published var config = BusinessConfig()
    
    private let userDefaults = UserDefaults.standard
    private let configKey = "BusinessConfig"
    
    init() {
        loadConfig()
    }
    
    func loadConfig() {
        if let data = userDefaults.data(forKey: configKey),
           let loadedConfig = try? JSONDecoder().decode(BusinessConfig.self, from: data) {
            self.config = loadedConfig
        }
    }
    
    func saveConfig() {
        if let data = try? JSONEncoder().encode(config) {
            userDefaults.set(data, forKey: configKey)
        }
    }
    
    func updateCompanyName(_ name: String) {
        config.companyName = name
        saveConfig()
    }
    
    func updateBusinessType(_ type: String) {
        config.businessType = type
        saveConfig()
    }
    
    func updateColors(primary: String, accent: String) {
        config.primaryColor = primary
        config.accentColor = accent
        saveConfig()
    }
    
    func updateConvexSettings(enabled: Bool, url: String, environment: ConvexEnvironment) {
        config.convexEnabled = enabled
        config.convexURL = url
        config.convexEnvironment = environment
        saveConfig()
    }
    
    // MARK: - Helper Properties
    
    var displayName: String {
        return config.companyName.isEmpty ? "Forestry Management" : config.companyName
    }
    
    var businessDescription: String {
        return config.businessType.isEmpty ? "Land Management Services" : config.businessType
    }
    
    var isTreeShopBranded: Bool {
        return config.companyName.contains("TreeShop") || config.companyName.contains("Tree Shop")
    }
}

// MARK: - Preset Configurations

extension BusinessConfigManager {
    
    static func forestryPreset() -> BusinessConfig {
        return BusinessConfig(
            companyName: "Forest Pro Services",
            businessType: "Professional Forestry & Land Management",
            primaryColor: "#228B22", // Forest Green
            accentColor: "#8B4513", // Saddle Brown
            logoIcon: "tree.circle.fill"
        )
    }
    
    static func landClearingPreset() -> BusinessConfig {
        return BusinessConfig(
            companyName: "ClearLand Solutions",
            businessType: "Land Clearing & Site Preparation",
            primaryColor: "#FF6B35", // Orange Red
            accentColor: "#004225", // Dark Green
            logoIcon: "hammer.circle.fill"
        )
    }
    
    static func mulchingPreset() -> BusinessConfig {
        return BusinessConfig(
            companyName: "Mulch Masters",
            businessType: "Professional Mulching Services",
            primaryColor: "#8B4513", // Saddle Brown
            accentColor: "#228B22", // Forest Green
            logoIcon: "leaf.circle.fill"
        )
    }
    
    func applyPreset(_ preset: BusinessConfig) {
        self.config = preset
        saveConfig()
    }
}