import Foundation
import SwiftUI
import MapKit
import CoreLocation

// MARK: - Package Types
enum PackageType: String, CaseIterable, Identifiable, Codable {
    case small = "small"
    case medium = "medium"
    case large = "large"
    case xlarge = "xlarge"
    case maxLight = "maxLight"
    case maxMedium = "maxMedium"
    case maxHeavy = "maxHeavy"
    
    var id: String { rawValue }
    
    var displayName: String {
        switch self {
        case .small: return "Small (4\" DBH)"
        case .medium: return "Medium (6\" DBH)"
        case .large: return "Large (8\" DBH)"
        case .xlarge: return "X-Large (10\" DBH)"
        case .maxLight: return "Max - Light Density"
        case .maxMedium: return "Max - Medium Density"
        case .maxHeavy: return "Max - Heavy Density"
        }
    }
    
    var densityDescription: String {
        switch self {
        case .maxLight: return "10\" and under trees (most projects)"
        case .maxMedium: return "Up to 15\" trees, 3-4 days"
        case .maxHeavy: return "15\"+ trees, 7+ days"
        default: return ""
        }
    }
}

// MARK: - Pricing Model
class PricingModel: ObservableObject {
    
    // MARK: - Published Properties
    @Published var landSize: Double = 2.5
    @Published var selectedPackage: PackageType = .medium
    @Published var projectZipCode: String = ""
    @Published var transportHours: Double = 2.0
    @Published var isCalculatingDistance: Bool = false
    @Published var debrisYards: Double = 0.0
    
    // MARK: - Pricing Rates (Adjustable in Settings)  
    @Published var packageRates: [PackageType: Double] = [
        .small: 2125.0,      // Will be auto-calculated from medium
        .medium: 2500.0,     // BASE RATE - 6" DBH default
        .large: 3375.0,      // Will be auto-calculated from medium
        .xlarge: 4250.0,     // Will be auto-calculated from medium
        .maxLight: 8000.0,   // 10" and under (most projects) - ~4 days @ $2000/day
        .maxMedium: 12000.0, // Up to 15" trees - 3-4 days @ $2000/day + complexity
        .maxHeavy: 18000.0   // 15"+ trees - 7+ days @ $2000/day + equipment wear
    ]
    
    // Auto-adjustment multipliers
    private let packageMultipliers: [PackageType: Double] = [
        .small: 0.85,   // -15% of medium
        .medium: 1.0,   // Base rate (100%)
        .large: 1.35,   // +35% of medium  
        .xlarge: 1.70   // +70% of medium
    ]
    
    // Track which rates are manually overridden
    @Published var manuallyOverriddenRates: Set<PackageType> = []
    
    @Published var transportRatePerHour: Double = 150.0
    @Published var debrisRatePerYard: Double = 20.0  // Updated to $20/yard
    @Published var finalMarkupMultiplier: Double = 1.15
    @Published var depositPercentage: Double = 0.25
    
    // Business Information
    @Published var businessName: String = "TreeShop"
    @Published var baseLocationAddress: String = ""
    @Published var businessPhone: String = ""
    @Published var businessEmail: String = ""
    
    // Debris estimation (yards per acre for Max packages)
    @Published var debrisEstimates: [PackageType: Double] = [
        .maxLight: 500.0,   // 500 yards/acre for light density
        .maxMedium: 750.0,  // 750 yards/acre for medium (your average)
        .maxHeavy: 1000.0   // 1000+ yards/acre for heavy density
    ]
    
    // MARK: - Computed Properties
    var baseCost: Double {
        landSize * (packageRates[selectedPackage] ?? 0)
    }
    
    var transportCost: Double {
        transportHours * transportRatePerHour
    }
    
    var debrisCost: Double {
        // For Max packages, auto-calculate debris based on density
        let totalDebris = isMaxPackage ? estimatedDebrisYards + debrisYards : debrisYards
        return totalDebris * debrisRatePerYard
    }
    
    var estimatedDebrisYards: Double {
        if isMaxPackage {
            return landSize * (debrisEstimates[selectedPackage] ?? 0)
        }
        return 0
    }
    
    var isMaxPackage: Bool {
        [.maxLight, .maxMedium, .maxHeavy].contains(selectedPackage)
    }
    
    var subtotal: Double {
        baseCost + transportCost + debrisCost
    }
    
    var finalPrice: Double {
        subtotal * finalMarkupMultiplier
    }
    
    var depositAmount: Double {
        finalPrice * depositPercentage
    }
    
    var balanceDue: Double {
        finalPrice - depositAmount
    }
    
    // MARK: - UserDefaults Keys
    private let userDefaults = UserDefaults.standard
    
    init() {
        loadSettings()
        // Auto-calculate dependent rates on initialization
        updateDependentRates(basedOn: .medium, newRate: packageRates[.medium] ?? 2500.0)
    }
    
    // MARK: - Settings Persistence
    func saveSettings() {
        userDefaults.set(packageRates[.small], forKey: "smallRate")
        userDefaults.set(packageRates[.medium], forKey: "mediumRate")
        userDefaults.set(packageRates[.large], forKey: "largeRate")
        userDefaults.set(packageRates[.xlarge], forKey: "xlargeRate")
        userDefaults.set(packageRates[.maxLight], forKey: "maxLightRate")
        userDefaults.set(packageRates[.maxMedium], forKey: "maxMediumRate")
        userDefaults.set(packageRates[.maxHeavy], forKey: "maxHeavyRate")
        userDefaults.set(transportRatePerHour, forKey: "transportRate")
        userDefaults.set(debrisRatePerYard, forKey: "debrisRate")
        userDefaults.set(finalMarkupMultiplier, forKey: "markupMultiplier")
        userDefaults.set(depositPercentage, forKey: "depositPercentage")
        userDefaults.set(businessName, forKey: "businessName")
        userDefaults.set(baseLocationAddress, forKey: "baseLocationAddress")
        userDefaults.set(businessPhone, forKey: "businessPhone")
        userDefaults.set(businessEmail, forKey: "businessEmail")
        
        // Save manually overridden rates
        let overriddenArray = Array(manuallyOverriddenRates.map { $0.rawValue })
        userDefaults.set(overriddenArray, forKey: "manuallyOverriddenRates")
    }
    
    private func loadSettings() {
        if userDefaults.object(forKey: "smallRate") != nil {
            packageRates[.small] = userDefaults.double(forKey: "smallRate")
            packageRates[.medium] = userDefaults.double(forKey: "mediumRate")
            packageRates[.large] = userDefaults.double(forKey: "largeRate")
            packageRates[.xlarge] = userDefaults.double(forKey: "xlargeRate")
            packageRates[.maxLight] = userDefaults.double(forKey: "maxLightRate")
            packageRates[.maxMedium] = userDefaults.double(forKey: "maxMediumRate")
            packageRates[.maxHeavy] = userDefaults.double(forKey: "maxHeavyRate")
            transportRatePerHour = userDefaults.double(forKey: "transportRate")
            debrisRatePerYard = userDefaults.double(forKey: "debrisRate")
            finalMarkupMultiplier = userDefaults.double(forKey: "markupMultiplier")
            depositPercentage = userDefaults.double(forKey: "depositPercentage")
        }
        
        // Load business information (always load these, even if empty)
        businessName = userDefaults.string(forKey: "businessName") ?? "TreeShop"
        baseLocationAddress = userDefaults.string(forKey: "baseLocationAddress") ?? ""
        businessPhone = userDefaults.string(forKey: "businessPhone") ?? ""
        businessEmail = userDefaults.string(forKey: "businessEmail") ?? ""
        
        // Load manually overridden rates
        if let overriddenArray = userDefaults.array(forKey: "manuallyOverriddenRates") as? [String] {
            manuallyOverriddenRates = Set(overriddenArray.compactMap { PackageType(rawValue: $0) })
        }
    }
    
    // MARK: - Dynamic Pricing Logic
    func updateDependentRates(basedOn basePackage: PackageType, newRate: Double) {
        guard basePackage == .medium else { return } // Only medium drives other rates
        
        let mediumRate = newRate
        packageRates[.medium] = mediumRate
        
        // Update dependent rates only if they haven't been manually overridden
        for (packageType, multiplier) in packageMultipliers {
            if packageType != .medium && !manuallyOverriddenRates.contains(packageType) {
                packageRates[packageType] = mediumRate * multiplier
            }
        }
    }
    
    func markAsManuallyOverridden(_ packageType: PackageType) {
        manuallyOverriddenRates.insert(packageType)
    }
    
    func resetToAutoCalculated(_ packageType: PackageType) {
        guard packageType != .medium else { return }
        manuallyOverriddenRates.remove(packageType)
        
        // Recalculate based on current medium rate
        if let multiplier = packageMultipliers[packageType] {
            packageRates[packageType] = (packageRates[.medium] ?? 2500.0) * multiplier
        }
    }
    
    func isRateManuallyOverridden(_ packageType: PackageType) -> Bool {
        return manuallyOverriddenRates.contains(packageType)
    }
    
    // MARK: - Transport Calculation
    func calculateTransportTime(for zipCode: String) {
        guard !zipCode.isEmpty && !baseLocationAddress.isEmpty else { return }
        
        isCalculatingDistance = true
        
        let baseGeocoder = CLGeocoder()
        let projectGeocoder = CLGeocoder()
        
        // Geocode base location
        baseGeocoder.geocodeAddressString(baseLocationAddress) { [weak self] baseLocations, baseError in
            guard let baseLocation = baseLocations?.first?.location else {
                DispatchQueue.main.async {
                    self?.isCalculatingDistance = false
                }
                return
            }
            
            // Geocode project zip code
            projectGeocoder.geocodeAddressString(zipCode) { [weak self] projectLocations, projectError in
                guard let projectLocation = projectLocations?.first?.location else {
                    DispatchQueue.main.async {
                        self?.isCalculatingDistance = false
                    }
                    return
                }
                
                // Calculate driving directions
                let request = MKDirections.Request()
                request.source = MKMapItem(placemark: MKPlacemark(coordinate: baseLocation.coordinate))
                request.destination = MKMapItem(placemark: MKPlacemark(coordinate: projectLocation.coordinate))
                request.transportType = .automobile
                
                let directions = MKDirections(request: request)
                directions.calculate { [weak self] response, error in
                    DispatchQueue.main.async {
                        self?.isCalculatingDistance = false
                        
                        if let route = response?.routes.first {
                            // Convert travel time to hours and round trip
                            let oneWayHours = route.expectedTravelTime / 3600.0
                            let roundTripHours = oneWayHours * 2
                            
                            // Round to nearest 0.5 hour
                            self?.transportHours = (roundTripHours * 2).rounded() / 2
                        }
                    }
                }
            }
        }
    }
    
    // MARK: - Formatting
    func formatCurrency(_ amount: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = Locale(identifier: "en_US")
        return formatter.string(from: NSNumber(value: amount)) ?? "$0.00"
    }
}