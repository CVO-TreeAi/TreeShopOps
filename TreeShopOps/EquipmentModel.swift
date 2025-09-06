import Foundation

// MARK: - Equipment Model

struct Equipment: Codable, Identifiable, Hashable {
    let id: UUID
    var identity: EquipmentIdentity
    var usage: EquipmentUsage
    var financial: EquipmentFinancial
    var calculated: EquipmentCalculation?
    var metadata: EquipmentMetadata
    
    init(
        identity: EquipmentIdentity,
        usage: EquipmentUsage,
        financial: EquipmentFinancial
    ) {
        self.id = UUID()
        self.identity = identity
        self.usage = usage
        self.financial = financial
        self.calculated = EquipmentCalculationEngine.calculateCosts(
            usage: usage,
            financial: financial
        )
        self.metadata = EquipmentMetadata(
            dateAdded: Date(),
            lastModified: Date(),
            status: .active,
            usageHours: 0,
            utilization: 0
        )
    }
}

// MARK: - Equipment Identity

struct EquipmentIdentity: Codable, Hashable {
    var equipmentName: String
    var year: Int
    var make: String
    var model: String
    var serialNumber: String?
    var category: EquipmentCategory
    
    var displayName: String {
        return equipmentName.isEmpty ? "\(year) \(make) \(model)" : equipmentName
    }
    
    var fullDescription: String {
        return "\(year) \(make) \(model)"
    }
}

// MARK: - Equipment Usage

struct EquipmentUsage: Codable, Hashable {
    var daysPerYear: Int
    var hoursPerDay: Double
    var usagePattern: UsagePattern
    
    var annualHours: Double {
        return Double(daysPerYear) * hoursPerDay
    }
}

// MARK: - Equipment Financial

struct EquipmentFinancial: Codable, Hashable {
    var purchasePrice: Double
    var yearsOfService: Int
    var estimatedResaleValue: Double
    var dailyFuelCost: Double
    var maintenanceLevel: MaintenanceLevel
    var customMaintenanceCost: Double?
    var annualInsuranceCost: Double
    
    var annualMaintenance: Double {
        if let custom = customMaintenanceCost, custom > 0 {
            return custom
        }
        return maintenanceLevel.annualCost
    }
}

// MARK: - Equipment Calculation

struct EquipmentCalculation: Codable, Hashable {
    let annualHours: Double
    let annualDepreciation: Double
    let annualFuel: Double
    let annualMaintenance: Double
    let totalAnnualCost: Double
    let hourlyCost: Double
    let recommendedRate: Double
    
    // Additional metrics
    var monthlyOperatingCost: Double {
        return totalAnnualCost / 12
    }
    
    var dailyOperatingCost: Double {
        return hourlyCost * 8 // Assuming 8-hour workday
    }
    
    var profitPerHour: Double {
        return recommendedRate - hourlyCost
    }
    
    var profitMargin: Double {
        guard recommendedRate > 0 else { return 0 }
        return ((recommendedRate - hourlyCost) / recommendedRate) * 100
    }
}

// MARK: - Equipment Metadata

struct EquipmentMetadata: Codable, Hashable {
    var dateAdded: Date
    var lastModified: Date
    var status: EquipmentStatus
    var usageHours: Double
    var utilization: Double
    var performanceRating: Double?
    var lastServiceDate: Date?
    var nextServiceDue: Date?
    
    var age: Int {
        let calendar = Calendar.current
        return calendar.dateComponents([.year], from: dateAdded, to: Date()).year ?? 0
    }
    
    var utilizationCategory: UtilizationCategory {
        if utilization >= 70 { return .high }
        if utilization >= 40 { return .medium }
        return .low
    }
}

// MARK: - Enums

enum EquipmentCategory: String, CaseIterable, Codable {
    case forestryMulcher = "Forestry Mulcher"
    case skidSteer = "Skid Steer"
    case pickupTruck = "Pickup Truck"
    case dumpTruck = "Dump Truck"
    case chipper = "Chipper"
    case stumpGrinder = "Stump Grinder"
    case other = "Other"
    
    var systemImage: String {
        switch self {
        case .forestryMulcher: return "tree.fill"
        case .skidSteer: return "car.fill"
        case .pickupTruck: return "car.side.fill"
        case .dumpTruck: return "truck.box.fill"
        case .chipper: return "leaf.fill"
        case .stumpGrinder: return "hammer.fill"
        case .other: return "gear"
        }
    }
    
    var color: String {
        switch self {
        case .forestryMulcher: return "TreeShopGreen"
        case .skidSteer: return "TreeShopBlue"
        case .pickupTruck, .dumpTruck: return "orange"
        case .chipper: return "green"
        case .stumpGrinder: return "brown"
        case .other: return "gray"
        }
    }
}

enum UsagePattern: String, CaseIterable, Codable {
    case light = "Light"
    case moderate = "Moderate" 
    case heavy = "Heavy"
    case custom = "Custom"
    
    var description: String {
        switch self {
        case .light: return "2-4 hours/day"
        case .moderate: return "4-8 hours/day"
        case .heavy: return "8+ hours/day"
        case .custom: return "Custom usage"
        }
    }
    
    var defaultHoursPerDay: Double {
        switch self {
        case .light: return 3.0
        case .moderate: return 6.0
        case .heavy: return 10.0
        case .custom: return 6.0
        }
    }
    
    var defaultDaysPerYear: Int {
        switch self {
        case .light: return 150
        case .moderate: return 200
        case .heavy: return 250
        case .custom: return 200
        }
    }
}

enum MaintenanceLevel: String, CaseIterable, Codable {
    case minimal = "Minimal"
    case standard = "Standard"
    case intense = "Intense"
    case custom = "Custom"
    
    var description: String {
        switch self {
        case .minimal: return "Basic oil changes, filters"
        case .standard: return "Regular service schedule"
        case .intense: return "Heavy-duty operations, frequent repairs"
        case .custom: return "Custom maintenance plan"
        }
    }
    
    var annualCost: Double {
        switch self {
        case .minimal: return 1300
        case .standard: return 2600
        case .intense: return 4550
        case .custom: return 0 // Will use custom cost
        }
    }
}

enum EquipmentStatus: String, CaseIterable, Codable {
    case active = "Active"
    case maintenance = "Maintenance"
    case retired = "Retired"
    case sold = "Sold"
    
    var color: String {
        switch self {
        case .active: return "TreeShopGreen"
        case .maintenance: return "orange"
        case .retired: return "gray"
        case .sold: return "red"
        }
    }
    
    var systemImage: String {
        switch self {
        case .active: return "checkmark.circle.fill"
        case .maintenance: return "wrench.and.screwdriver.fill"
        case .retired: return "pause.circle.fill"
        case .sold: return "dollarsign.circle.fill"
        }
    }
}

enum UtilizationCategory: String, CaseIterable, Codable {
    case high = "High"
    case medium = "Medium"
    case low = "Low"
    
    var color: String {
        switch self {
        case .high: return "TreeShopGreen"
        case .medium: return "orange" 
        case .low: return "red"
        }
    }
    
    var threshold: Double {
        switch self {
        case .high: return 70
        case .medium: return 40
        case .low: return 0
        }
    }
}

// MARK: - Equipment Manager

class EquipmentManager: ObservableObject {
    @Published var equipment: [Equipment] = []
    
    private let equipmentKey = "SavedEquipment"
    
    init() {
        loadEquipment()
    }
    
    // MARK: - CRUD Operations
    
    func addEquipment(_ equipment: Equipment) {
        self.equipment.append(equipment)
        saveEquipment()
    }
    
    func updateEquipment(_ equipment: Equipment) {
        if let index = self.equipment.firstIndex(where: { $0.id == equipment.id }) {
            var updatedEquipment = equipment
            updatedEquipment.metadata.lastModified = Date()
            updatedEquipment.calculated = EquipmentCalculationEngine.calculateCosts(
                usage: equipment.usage,
                financial: equipment.financial
            )
            self.equipment[index] = updatedEquipment
            saveEquipment()
        }
    }
    
    func deleteEquipment(_ equipment: Equipment) {
        self.equipment.removeAll { $0.id == equipment.id }
        saveEquipment()
    }
    
    func getEquipment(by id: UUID) -> Equipment? {
        return equipment.first { $0.id == id }
    }
    
    // MARK: - Filtering and Search
    
    func getEquipmentByCategory(_ category: EquipmentCategory) -> [Equipment] {
        return equipment.filter { $0.identity.category == category }
    }
    
    func getEquipmentByStatus(_ status: EquipmentStatus) -> [Equipment] {
        return equipment.filter { $0.metadata.status == status }
    }
    
    func searchEquipment(_ searchTerm: String) -> [Equipment] {
        guard !searchTerm.isEmpty else { return equipment }
        
        let lowercasedTerm = searchTerm.lowercased()
        return equipment.filter {
            $0.identity.equipmentName.lowercased().contains(lowercasedTerm) ||
            $0.identity.make.lowercased().contains(lowercasedTerm) ||
            $0.identity.model.lowercased().contains(lowercasedTerm) ||
            $0.identity.category.rawValue.lowercased().contains(lowercasedTerm)
        }
    }
    
    // MARK: - Statistics
    
    func getFleetStats() -> EquipmentFleetStats {
        let totalCount = equipment.count
        let activeCount = equipment.filter { $0.metadata.status == .active }.count
        let totalValue = equipment.reduce(0) { $0 + $1.financial.purchasePrice }
        let averageHourlyCost = equipment.isEmpty ? 0 : 
            equipment.reduce(0) { $0 + ($1.calculated?.hourlyCost ?? 0) } / Double(totalCount)
        
        return EquipmentFleetStats(
            totalCount: totalCount,
            activeCount: activeCount,
            totalFleetValue: totalValue,
            averageHourlyCost: averageHourlyCost,
            highUtilizationCount: equipment.filter { $0.metadata.utilizationCategory == .high }.count,
            needsAttentionCount: equipment.filter { needsAttention($0) }.count
        )
    }
    
    private func needsAttention(_ equipment: Equipment) -> Bool {
        guard let calculated = equipment.calculated else { return false }
        
        return calculated.hourlyCost > 150 || // High cost
               equipment.metadata.utilization < 30 || // Low utilization
               equipment.metadata.age > 10 // Old equipment
    }
    
    // MARK: - Data Persistence
    
    private func saveEquipment() {
        if let encoded = try? JSONEncoder().encode(equipment) {
            UserDefaults.standard.set(encoded, forKey: equipmentKey)
        }
    }
    
    private func loadEquipment() {
        if let data = UserDefaults.standard.data(forKey: equipmentKey),
           let decoded = try? JSONDecoder().decode([Equipment].self, from: data) {
            self.equipment = decoded
        }
    }
}

// MARK: - Fleet Statistics

struct EquipmentFleetStats {
    let totalCount: Int
    let activeCount: Int
    let totalFleetValue: Double
    let averageHourlyCost: Double
    let highUtilizationCount: Int
    let needsAttentionCount: Int
    
    var utilizationRate: Double {
        guard totalCount > 0 else { return 0 }
        return Double(activeCount) / Double(totalCount) * 100
    }
    
    var totalMonthlyOperating: Double {
        return averageHourlyCost * 160 * Double(activeCount) // Assuming 160 hours/month per equipment
    }
}