import Foundation

// MARK: - Loadout Model

struct Loadout: Codable, Identifiable, Hashable {
    let id: UUID
    var info: LoadoutInfo
    var crew: LoadoutCrew
    var pricing: LoadoutPricing
    var calculated: LoadoutCalculation?
    var metadata: LoadoutMetadata
    
    init(
        info: LoadoutInfo,
        crew: LoadoutCrew,
        pricing: LoadoutPricing
    ) {
        self.id = UUID()
        self.info = info
        self.crew = crew
        self.pricing = pricing
        self.calculated = LoadoutCalculationEngine.calculateLoadout(
            crew: crew,
            pricing: pricing
        )
        self.metadata = LoadoutMetadata(
            dateCreated: Date(),
            lastModified: Date(),
            status: .active,
            timesUsed: 0,
            totalRevenue: 0,
            averageJobDuration: 0
        )
    }
}

// MARK: - Loadout Info

struct LoadoutInfo: Codable, Hashable {
    var name: String
    var category: LoadoutCategory
    var description: String?
    var assignedServices: [ServiceType]
    var primaryLocation: String?
    
    var displayName: String {
        return name.isEmpty ? "Untitled Loadout" : name
    }
}

// MARK: - Loadout Crew

struct LoadoutCrew: Codable, Hashable {
    var employees: [UUID] // Employee IDs
    var equipment: [UUID] // Equipment IDs
    var notes: String?
    
    var isEmpty: Bool {
        return employees.isEmpty && equipment.isEmpty
    }
    
    var memberCount: Int {
        return employees.count + equipment.count
    }
}

// MARK: - Loadout Pricing

struct LoadoutPricing: Codable, Hashable {
    var markupMultiplier: Double // 1.5x - 4.0x
    var hourlyMinimum: Double?
    var dayRateMultiplier: Double?
    var emergencyMultiplier: Double?
    var seasonalAdjustment: Double?
    var customRateOverride: Double?
    
    var hasCustomPricing: Bool {
        return customRateOverride != nil && (customRateOverride ?? 0) > 0
    }
}

// MARK: - Loadout Calculation

struct LoadoutCalculation: Codable, Hashable {
    let totalEmployeeCost: Double
    let totalEquipmentCost: Double
    let totalOperatingCost: Double
    let billingRate: Double
    let profitMargin: Double
    let dailyRevenue: Double // 8-hour day
    let weeklyRevenue: Double // 40-hour week
    let monthlyRevenue: Double // 160-hour month
    
    // Performance metrics
    var costEfficiencyRatio: Double {
        guard totalOperatingCost > 0 else { return 0 }
        return billingRate / totalOperatingCost
    }
    
    var hourlyProfit: Double {
        return billingRate - totalOperatingCost
    }
    
    var dailyProfit: Double {
        return hourlyProfit * 8
    }
    
    var isprofitable: Bool {
        return profitMargin > 20 // 20% minimum margin
    }
    
    var profitabilityCategory: ProfitabilityCategory {
        if profitMargin >= 50 { return .excellent }
        if profitMargin >= 35 { return .good }
        if profitMargin >= 20 { return .acceptable }
        return .poor
    }
}

// MARK: - Loadout Metadata

struct LoadoutMetadata: Codable, Hashable {
    var dateCreated: Date
    var lastModified: Date
    var status: LoadoutStatus
    var timesUsed: Int
    var totalRevenue: Double
    var averageJobDuration: Double
    var lastUsed: Date?
    var customerFeedback: Double?
    var efficiencyRating: Double?
    
    var age: Int {
        let calendar = Calendar.current
        return calendar.dateComponents([.day], from: dateCreated, to: Date()).day ?? 0
    }
    
    var averageRevenuePerUse: Double {
        guard timesUsed > 0 else { return 0 }
        return totalRevenue / Double(timesUsed)
    }
    
    var utilizationCategory: UtilizationCategory {
        if timesUsed >= 20 { return .high }
        if timesUsed >= 10 { return .medium }
        return .low
    }
}

// MARK: - Enums

enum LoadoutCategory: String, CaseIterable, Codable {
    case treeRemoval = "Tree Removal"
    case treePruning = "Tree Pruning" 
    case landClearing = "Land Clearing"
    case forestryMulching = "Forestry Mulching"
    case stumpGrinding = "Stump Grinding"
    case emergencyResponse = "Emergency Response"
    case landscaping = "Landscaping"
    case maintenance = "Maintenance"
    case consultation = "Consultation"
    case specialtyServices = "Specialty Services"
    case custom = "Custom"
    
    var systemImage: String {
        switch self {
        case .treeRemoval: return "tree.fill"
        case .treePruning: return "scissors.circle"
        case .landClearing: return "hammer.circle"
        case .forestryMulching: return "leaf.circle"
        case .stumpGrinding: return "gear.circle"
        case .emergencyResponse: return "exclamationmark.triangle.fill"
        case .landscaping: return "leaf.arrow.triangle.circlepath"
        case .maintenance: return "wrench.and.screwdriver"
        case .consultation: return "person.2.wave.2"
        case .specialtyServices: return "star.circle"
        case .custom: return "rectangle.3.group"
        }
    }
    
    var color: String {
        switch self {
        case .treeRemoval, .forestryMulching: return "TreeShopGreen"
        case .treePruning, .landscaping: return "green"
        case .landClearing, .stumpGrinding: return "orange"
        case .emergencyResponse: return "red"
        case .maintenance: return "TreeShopBlue"
        case .consultation, .specialtyServices: return "purple"
        case .custom: return "gray"
        }
    }
    
    var typicalMarkup: Double {
        switch self {
        case .treeRemoval: return 2.5
        case .treePruning: return 2.3
        case .landClearing: return 2.2
        case .forestryMulching: return 2.4
        case .stumpGrinding: return 2.6
        case .emergencyResponse: return 3.5
        case .landscaping: return 2.0
        case .maintenance: return 2.8
        case .consultation: return 3.0
        case .specialtyServices: return 3.2
        case .custom: return 2.5
        }
    }
}

enum ServiceType: String, CaseIterable, Codable {
    case treeRemoval = "Tree Removal"
    case treeTrimming = "Tree Trimming"
    case stumpGrinding = "Stump Grinding"
    case landClearing = "Land Clearing"
    case forestryMulching = "Forestry Mulching"
    case emergencyServices = "Emergency Services"
    case consultations = "Consultations"
    case plantHealthCare = "Plant Health Care"
    case cabling = "Cabling & Bracing"
    case firewoodServices = "Firewood Services"
    case lotClearing = "Lot Clearing"
    case rightOfWayClearing = "Right of Way Clearing"
}

enum LoadoutStatus: String, CaseIterable, Codable {
    case active = "Active"
    case inactive = "Inactive"
    case onProject = "On Project"
    case maintenance = "Maintenance"
    case retired = "Retired"
    
    var color: String {
        switch self {
        case .active: return "TreeShopGreen"
        case .inactive: return "gray"
        case .onProject: return "TreeShopBlue"
        case .maintenance: return "orange"
        case .retired: return "red"
        }
    }
    
    var systemImage: String {
        switch self {
        case .active: return "checkmark.circle.fill"
        case .inactive: return "pause.circle.fill"
        case .onProject: return "hammer.circle.fill"
        case .maintenance: return "wrench.and.screwdriver.fill"
        case .retired: return "minus.circle.fill"
        }
    }
}

enum ProfitabilityCategory: String, CaseIterable {
    case excellent = "Excellent"
    case good = "Good"
    case acceptable = "Acceptable"
    case poor = "Poor"
    
    var color: String {
        switch self {
        case .excellent: return "TreeShopGreen"
        case .good: return "green"
        case .acceptable: return "orange"
        case .poor: return "red"
        }
    }
}

// MARK: - Loadout Manager

class LoadoutManager: ObservableObject {
    @Published var loadouts: [Loadout] = []
    
    private let loadoutsKey = "SavedLoadouts"
    
    init() {
        loadLoadouts()
    }
    
    // MARK: - CRUD Operations
    
    func addLoadout(_ loadout: Loadout) {
        self.loadouts.append(loadout)
        saveLoadouts()
    }
    
    func updateLoadout(_ loadout: Loadout) {
        if let index = self.loadouts.firstIndex(where: { $0.id == loadout.id }) {
            var updatedLoadout = loadout
            updatedLoadout.metadata.lastModified = Date()
            updatedLoadout.calculated = LoadoutCalculationEngine.calculateLoadout(
                crew: loadout.crew,
                pricing: loadout.pricing
            )
            self.loadouts[index] = updatedLoadout
            saveLoadouts()
        }
    }
    
    func deleteLoadout(_ loadout: Loadout) {
        self.loadouts.removeAll { $0.id == loadout.id }
        saveLoadouts()
    }
    
    func getLoadout(by id: UUID) -> Loadout? {
        return loadouts.first { $0.id == id }
    }
    
    // MARK: - Filtering and Search
    
    func getLoadoutsByCategory(_ category: LoadoutCategory) -> [Loadout] {
        return loadouts.filter { $0.info.category == category }
    }
    
    func getLoadoutsByStatus(_ status: LoadoutStatus) -> [Loadout] {
        return loadouts.filter { $0.metadata.status == status }
    }
    
    func getAvailableLoadouts() -> [Loadout] {
        return loadouts.filter { $0.metadata.status == .active }
    }
    
    func searchLoadouts(_ searchTerm: String) -> [Loadout] {
        guard !searchTerm.isEmpty else { return loadouts }
        
        let lowercasedTerm = searchTerm.lowercased()
        return loadouts.filter {
            $0.info.name.lowercased().contains(lowercasedTerm) ||
            $0.info.category.rawValue.lowercased().contains(lowercasedTerm) ||
            $0.info.description?.lowercased().contains(lowercasedTerm) == true
        }
    }
    
    // MARK: - Statistics
    
    func getLoadoutStats() -> LoadoutFleetStats {
        let totalCount = loadouts.count
        let activeCount = getLoadoutsByStatus(.active).count
        let totalRevenue = loadouts.reduce(0) { $0 + $1.metadata.totalRevenue }
        let averageMargin = loadouts.isEmpty ? 0 :
            loadouts.compactMap({ $0.calculated?.profitMargin }).reduce(0, +) / Double(loadouts.count)
        let averageBillingRate = loadouts.isEmpty ? 0 :
            loadouts.compactMap({ $0.calculated?.billingRate }).reduce(0, +) / Double(loadouts.count)
        
        return LoadoutFleetStats(
            totalCount: totalCount,
            activeCount: activeCount,
            totalRevenue: totalRevenue,
            averageProfitMargin: averageMargin,
            averageBillingRate: averageBillingRate,
            highPerformingCount: loadouts.filter { isHighPerforming($0) }.count,
            needsOptimizationCount: loadouts.filter { needsOptimization($0) }.count
        )
    }
    
    private func isHighPerforming(_ loadout: Loadout) -> Bool {
        guard let calculated = loadout.calculated else { return false }
        return calculated.profitMargin >= 50 && loadout.metadata.timesUsed >= 10
    }
    
    private func needsOptimization(_ loadout: Loadout) -> Bool {
        guard let calculated = loadout.calculated else { return true }
        return calculated.profitMargin < 20 || loadout.metadata.timesUsed < 5
    }
    
    // MARK: - Data Persistence
    
    private func saveLoadouts() {
        if let encoded = try? JSONEncoder().encode(loadouts) {
            UserDefaults.standard.set(encoded, forKey: loadoutsKey)
        }
    }
    
    private func loadLoadouts() {
        if let data = UserDefaults.standard.data(forKey: loadoutsKey),
           let decoded = try? JSONDecoder().decode([Loadout].self, from: data) {
            self.loadouts = decoded
        }
    }
}

// MARK: - Loadout Fleet Statistics

struct LoadoutFleetStats {
    let totalCount: Int
    let activeCount: Int
    let totalRevenue: Double
    let averageProfitMargin: Double
    let averageBillingRate: Double
    let highPerformingCount: Int
    let needsOptimizationCount: Int
    
    var utilizationRate: Double {
        guard totalCount > 0 else { return 0 }
        return Double(activeCount) / Double(totalCount) * 100
    }
    
    var profitabilityScore: Double {
        return averageProfitMargin
    }
}

// MARK: - Loadout Calculation Engine

struct LoadoutCalculationEngine {
    
    static func calculateLoadout(crew: LoadoutCrew, pricing: LoadoutPricing) -> LoadoutCalculation {
        // For now, we'll use mock calculations since we need actual employee and equipment data
        // In a real implementation, this would fetch the actual Employee and Equipment objects
        
        // Mock calculation based on crew size
        let mockEmployeeCost = Double(crew.employees.count) * 45.0 // $45/hr average
        let mockEquipmentCost = Double(crew.equipment.count) * 85.0 // $85/hr average
        let totalOperatingCost = mockEmployeeCost + mockEquipmentCost
        
        let billingRate = pricing.hasCustomPricing ? 
            pricing.customRateOverride! : 
            totalOperatingCost * pricing.markupMultiplier
            
        let profitMargin = totalOperatingCost > 0 ? 
            ((billingRate - totalOperatingCost) / billingRate) * 100 : 0
        
        return LoadoutCalculation(
            totalEmployeeCost: mockEmployeeCost,
            totalEquipmentCost: mockEquipmentCost,
            totalOperatingCost: totalOperatingCost,
            billingRate: billingRate,
            profitMargin: profitMargin,
            dailyRevenue: billingRate * 8,
            weeklyRevenue: billingRate * 40,
            monthlyRevenue: billingRate * 160
        )
    }
    
    static func calculateWithActualData(
        employees: [Employee],
        equipment: [Equipment],
        pricing: LoadoutPricing
    ) -> LoadoutCalculation {
        
        let totalEmployeeCost = employees.reduce(0) { sum, employee in
            sum + (employee.calculated?.trueHourlyCost ?? 0)
        }
        
        let totalEquipmentCost = equipment.reduce(0) { sum, equipment in
            sum + (equipment.calculated?.hourlyCost ?? 0)
        }
        
        let totalOperatingCost = totalEmployeeCost + totalEquipmentCost
        
        let billingRate = pricing.hasCustomPricing ?
            pricing.customRateOverride! :
            totalOperatingCost * pricing.markupMultiplier
        
        let profitMargin = totalOperatingCost > 0 ?
            ((billingRate - totalOperatingCost) / billingRate) * 100 : 0
        
        return LoadoutCalculation(
            totalEmployeeCost: totalEmployeeCost,
            totalEquipmentCost: totalEquipmentCost,
            totalOperatingCost: totalOperatingCost,
            billingRate: billingRate,
            profitMargin: profitMargin,
            dailyRevenue: billingRate * 8,
            weeklyRevenue: billingRate * 40,
            monthlyRevenue: billingRate * 160
        )
    }
    
    // MARK: - Optimization Suggestions
    
    static func getOptimizationSuggestions(
        for loadout: Loadout,
        employees: [Employee],
        equipment: [Equipment]
    ) -> [LoadoutOptimization] {
        var suggestions: [LoadoutOptimization] = []
        
        guard let calculated = loadout.calculated else { return suggestions }
        
        // Check profit margin
        if calculated.profitMargin < 20 {
            suggestions.append(LoadoutOptimization(
                type: .costReduction,
                priority: .high,
                message: "Profit margin below 20% - consider reducing costs or increasing markup",
                impact: "Improve profitability"
            ))
        }
        
        // Check equipment to employee ratio
        let equipmentRatio = Double(loadout.crew.equipment.count) / Double(max(1, loadout.crew.employees.count))
        if equipmentRatio > 1.5 {
            suggestions.append(LoadoutOptimization(
                type: .balancing,
                priority: .medium,
                message: "High equipment-to-employee ratio - consider adding crew members",
                impact: "Improve efficiency"
            ))
        }
        
        // Check utilization
        if loadout.metadata.timesUsed < 5 {
            suggestions.append(LoadoutOptimization(
                type: .utilization,
                priority: .low,
                message: "Low usage count - promote this loadout for more projects",
                impact: "Increase ROI"
            ))
        }
        
        return suggestions
    }
}

struct LoadoutOptimization {
    let type: OptimizationType
    let priority: Priority
    let message: String
    let impact: String
    
    enum OptimizationType: String, CaseIterable {
        case costReduction = "Cost Reduction"
        case balancing = "Crew Balancing"
        case utilization = "Utilization"
        case pricing = "Pricing Strategy"
    }
    
    enum Priority: String, CaseIterable {
        case high = "High"
        case medium = "Medium"
        case low = "Low"
        
        var color: String {
            switch self {
            case .high: return "red"
            case .medium: return "orange"
            case .low: return "TreeShopBlue"
            }
        }
    }
}

// MARK: - Loadout Templates

struct LoadoutTemplates {
    
    static func getPresetTemplates() -> [LoadoutTemplate] {
        return [
            LoadoutTemplate(
                name: "Tree Removal Crew",
                category: .treeRemoval,
                description: "Standard tree removal with aerial equipment",
                recommendedEmployees: 4,
                recommendedEquipment: 3,
                typicalServices: [.treeRemoval, .stumpGrinding],
                estimatedBillingRate: 450
            ),
            
            LoadoutTemplate(
                name: "Pruning Specialist",
                category: .treePruning,
                description: "Precision pruning with climbing specialists",
                recommendedEmployees: 3,
                recommendedEquipment: 2,
                typicalServices: [.treeTrimming, .plantHealthCare],
                estimatedBillingRate: 320
            ),
            
            LoadoutTemplate(
                name: "Land Clearing Team",
                category: .landClearing,
                description: "Heavy equipment land clearing operations",
                recommendedEmployees: 2,
                recommendedEquipment: 4,
                typicalServices: [.landClearing, .lotClearing],
                estimatedBillingRate: 380
            ),
            
            LoadoutTemplate(
                name: "Emergency Response",
                category: .emergencyResponse,
                description: "24/7 emergency storm cleanup crew",
                recommendedEmployees: 6,
                recommendedEquipment: 4,
                typicalServices: [.emergencyServices, .treeRemoval],
                estimatedBillingRate: 650
            ),
            
            LoadoutTemplate(
                name: "Forestry Mulching",
                category: .forestryMulching,
                description: "Specialized forestry mulching operations",
                recommendedEmployees: 2,
                recommendedEquipment: 3,
                typicalServices: [.forestryMulching, .landClearing],
                estimatedBillingRate: 425
            )
        ]
    }
}

struct LoadoutTemplate {
    let name: String
    let category: LoadoutCategory
    let description: String
    let recommendedEmployees: Int
    let recommendedEquipment: Int
    let typicalServices: [ServiceType]
    let estimatedBillingRate: Double
    
    var systemImage: String {
        return category.systemImage
    }
    
    var color: String {
        return category.color
    }
}