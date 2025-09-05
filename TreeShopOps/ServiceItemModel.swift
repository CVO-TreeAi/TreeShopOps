import Foundation
import SwiftUI

// MARK: - Service Item Core Models

struct ServiceItem: Identifiable, Codable {
    var id = UUID()
    var name: String
    var description: String
    var category: ServiceCategory
    var unitType: UnitType
    var basePrice: Double
    var minimumQuantity: Double
    var maximumQuantity: Double?
    
    // Pricing Rules
    var pricingModel: ServicePricingType
    var discountEligible: Bool
    var taxable: Bool
    var taxCategory: TaxCategory
    
    // Business Logic
    var isActive: Bool
    var skillRequirements: [String]
    var equipmentRequired: [String]
    var estimatedDuration: TimeInterval // in hours
    var seasonalAvailable: Bool
    
    // Metadata
    var dateCreated: Date
    var dateUpdated: Date
    var createdBy: String
    var notes: String
    
    init(
        name: String = "",
        description: String = "",
        category: ServiceCategory = .forestryMulching,
        unitType: UnitType = .perAcre,
        basePrice: Double = 0.0,
        minimumQuantity: Double = 0.1,
        maximumQuantity: Double? = nil,
        pricingModel: ServicePricingType = .fixed,
        discountEligible: Bool = true,
        taxable: Bool = true,
        taxCategory: TaxCategory = .services,
        isActive: Bool = true,
        skillRequirements: [String] = [],
        equipmentRequired: [String] = [],
        estimatedDuration: TimeInterval = 8.0,
        seasonalAvailable: Bool = true,
        createdBy: String = "",
        notes: String = ""
    ) {
        self.name = name
        self.description = description
        self.category = category
        self.unitType = unitType
        self.basePrice = basePrice
        self.minimumQuantity = minimumQuantity
        self.maximumQuantity = maximumQuantity
        self.pricingModel = pricingModel
        self.discountEligible = discountEligible
        self.taxable = taxable
        self.taxCategory = taxCategory
        self.isActive = isActive
        self.skillRequirements = skillRequirements
        self.equipmentRequired = equipmentRequired
        self.estimatedDuration = estimatedDuration
        self.seasonalAvailable = seasonalAvailable
        self.dateCreated = Date()
        self.dateUpdated = Date()
        self.createdBy = createdBy
        self.notes = notes
    }
}

struct LineItem: Identifiable, Codable {
    var id = UUID()
    var serviceItemId: UUID
    var serviceName: String
    var description: String
    var quantity: Double
    var unitPrice: Double
    var discountPercentage: Double
    var taxRate: Double
    var parentDocumentId: UUID
    var parentDocumentType: DocumentType
    
    // Calculated properties
    var lineTotal: Double {
        let subtotal = quantity * unitPrice
        let discountAmount = subtotal * (discountPercentage / 100)
        return subtotal - discountAmount
    }
    
    var taxAmount: Double {
        return lineTotal * (taxRate / 100)
    }
    
    var totalWithTax: Double {
        return lineTotal + taxAmount
    }
    
    init(
        serviceItemId: UUID,
        serviceName: String,
        description: String = "",
        quantity: Double = 1.0,
        unitPrice: Double = 0.0,
        discountPercentage: Double = 0.0,
        taxRate: Double = 8.75,
        parentDocumentId: UUID,
        parentDocumentType: DocumentType
    ) {
        self.serviceItemId = serviceItemId
        self.serviceName = serviceName
        self.description = description
        self.quantity = quantity
        self.unitPrice = unitPrice
        self.discountPercentage = discountPercentage
        self.taxRate = taxRate
        self.parentDocumentId = parentDocumentId
        self.parentDocumentType = parentDocumentType
    }
}

// MARK: - Service Categories

enum ServiceCategory: String, CaseIterable, Codable {
    case forestryMulching = "Forestry Mulching"
    case landClearing = "Land Clearing" 
    case sitePreparation = "Site Preparation"
    case brushClearing = "Brush Clearing"
    case firebreakCreation = "Firebreak Creation"
    case rightOfWayClearing = "Right-of-Way Clearing"
    case erosionControl = "Erosion Control"
    case accessRoadClearing = "Access Road Clearing"
    case consultation = "Consultation & Assessment"
    case emergency = "Emergency Services"
    
    var systemImage: String {
        switch self {
        case .forestryMulching:
            return "leaf.fill"
        case .landClearing:
            return "rectangle.on.rectangle.angled"
        case .sitePreparation:
            return "building.2"
        case .brushClearing:
            return "tree"
        case .firebreakCreation:
            return "flame"
        case .rightOfWayClearing:
            return "road.lanes"
        case .erosionControl:
            return "water.waves"
        case .accessRoadClearing:
            return "road.lanes.curved.right"
        case .consultation:
            return "person.badge.clock"
        case .emergency:
            return "exclamationmark.triangle"
        }
    }
    
    var color: Color {
        switch self {
        case .forestryMulching:
            return Color("TreeShopGreen")
        case .landClearing:
            return Color("TreeShopBlue")
        case .sitePreparation:
            return .orange
        case .brushClearing:
            return .green
        case .firebreakCreation:
            return .red
        case .rightOfWayClearing:
            return .purple
        case .erosionControl:
            return .blue
        case .accessRoadClearing:
            return .brown
        case .consultation:
            return .yellow
        case .emergency:
            return .pink
        }
    }
}

enum UnitType: String, CaseIterable, Codable {
    case perAcre = "Per Acre"
    case perHour = "Per Hour"
    case perDay = "Per Day"
    case fixedPrice = "Fixed Price"
    case perTree = "Per Tree"
    case perLinearFoot = "Per Linear Foot"
    case perSquareFoot = "Per Square Foot"
    case perTon = "Per Ton"
    case perYard = "Per Yard"
    
    var shortName: String {
        switch self {
        case .perAcre: return "/acre"
        case .perHour: return "/hr"
        case .perDay: return "/day"
        case .fixedPrice: return "fixed"
        case .perTree: return "/tree"
        case .perLinearFoot: return "/ft"
        case .perSquareFoot: return "/sq ft"
        case .perTon: return "/ton"
        case .perYard: return "/yard"
        }
    }
}

enum ServicePricingType: String, CaseIterable, Codable {
    case fixed = "Fixed Price"
    case tiered = "Tiered Pricing"
    case volumeDiscount = "Volume Discount"
    case seasonal = "Seasonal Pricing"
    case customQuote = "Custom Quote Required"
    
    var description: String {
        switch self {
        case .fixed:
            return "Standard fixed rate per unit"
        case .tiered:
            return "Price varies by quantity tiers"
        case .volumeDiscount:
            return "Discounts for large quantities"
        case .seasonal:
            return "Price varies by season/weather"
        case .customQuote:
            return "Requires custom estimation"
        }
    }
}

enum TaxCategory: String, CaseIterable, Codable {
    case services = "Services"
    case materials = "Materials"
    case equipment = "Equipment Rental"
    case labor = "Labor"
    case exempt = "Tax Exempt"
    
    var defaultRate: Double {
        switch self {
        case .services: return 8.75
        case .materials: return 8.75
        case .equipment: return 8.75
        case .labor: return 8.75
        case .exempt: return 0.0
        }
    }
}

enum DocumentType: String, Codable {
    case proposal = "Proposal"
    case workOrder = "Work Order"
    case invoice = "Invoice"
    case estimate = "Estimate"
}

// MARK: - Service Item Manager

class ServiceItemManager: ObservableObject {
    @Published var serviceItems: [ServiceItem] = []
    @Published var lineItems: [LineItem] = []
    
    private let serviceItemsKey = "ServiceItems"
    private let lineItemsKey = "LineItems"
    
    init() {
        loadServiceItems()
        loadLineItems()
        createDefaultServices()
    }
    
    // MARK: - Service Item CRUD
    
    func addServiceItem(_ serviceItem: ServiceItem) {
        serviceItems.append(serviceItem)
        saveServiceItems()
    }
    
    func updateServiceItem(_ serviceItem: ServiceItem) {
        if let index = serviceItems.firstIndex(where: { $0.id == serviceItem.id }) {
            var updated = serviceItem
            updated.dateUpdated = Date()
            serviceItems[index] = updated
            saveServiceItems()
        }
    }
    
    func deleteServiceItem(_ serviceItem: ServiceItem) {
        serviceItems.removeAll { $0.id == serviceItem.id }
        saveServiceItems()
    }
    
    func getActiveServiceItems() -> [ServiceItem] {
        return serviceItems.filter { $0.isActive }
    }
    
    func getServiceItemsByCategory(_ category: ServiceCategory) -> [ServiceItem] {
        return serviceItems.filter { $0.category == category }
    }
    
    // MARK: - Line Item CRUD
    
    func addLineItem(_ lineItem: LineItem) {
        lineItems.append(lineItem)
        saveLineItems()
    }
    
    func updateLineItem(_ lineItem: LineItem) {
        if let index = lineItems.firstIndex(where: { $0.id == lineItem.id }) {
            lineItems[index] = lineItem
            saveLineItems()
        }
    }
    
    func deleteLineItem(_ lineItem: LineItem) {
        lineItems.removeAll { $0.id == lineItem.id }
        saveLineItems()
    }
    
    func getLineItems(for documentId: UUID, type: DocumentType) -> [LineItem] {
        return lineItems.filter { 
            $0.parentDocumentId == documentId && $0.parentDocumentType == type 
        }
    }
    
    // MARK: - Business Logic
    
    func calculatePrice(serviceItem: ServiceItem, quantity: Double, customerTier: CustomerTier = .standard, isEmergency: Bool = false) -> Double {
        var price = serviceItem.basePrice
        
        // Apply pricing model logic
        switch serviceItem.pricingModel {
        case .tiered:
            price = applyTieredPricing(basePrice: price, quantity: quantity)
        case .volumeDiscount:
            price = applyVolumeDiscount(basePrice: price, quantity: quantity)
        case .seasonal:
            price = applySeasonalPricing(basePrice: price)
        case .fixed, .customQuote:
            break
        }
        
        // Apply customer tier discount
        switch customerTier {
        case .standard:
            break
        case .preferred:
            price *= 0.95 // 5% discount
        case .premium:
            price *= 0.90 // 10% discount
        }
        
        // Emergency multiplier
        if isEmergency {
            price *= 1.5 // 50% emergency surcharge
        }
        
        return price * quantity
    }
    
    private func applyTieredPricing(basePrice: Double, quantity: Double) -> Double {
        if quantity >= 10.0 {
            return basePrice * 0.85 // 15% discount for 10+ acres
        } else if quantity >= 5.0 {
            return basePrice * 0.92 // 8% discount for 5+ acres
        }
        return basePrice
    }
    
    private func applyVolumeDiscount(basePrice: Double, quantity: Double) -> Double {
        let discountTiers: [(threshold: Double, discount: Double)] = [
            (50.0, 0.20), // 20% off for 50+ acres
            (20.0, 0.15), // 15% off for 20+ acres
            (10.0, 0.10), // 10% off for 10+ acres
            (5.0, 0.05)   // 5% off for 5+ acres
        ]
        
        for tier in discountTiers {
            if quantity >= tier.threshold {
                return basePrice * (1.0 - tier.discount)
            }
        }
        return basePrice
    }
    
    private func applySeasonalPricing(basePrice: Double) -> Double {
        let calendar = Calendar.current
        let month = calendar.component(.month, from: Date())
        
        // Higher prices in peak season (spring/summer)
        switch month {
        case 4...9: // April through September
            return basePrice * 1.15 // 15% premium for peak season
        case 10...12, 1...3: // Off season
            return basePrice * 0.90 // 10% discount for off season
        default:
            return basePrice
        }
    }
    
    // MARK: - Default Services
    
    private func createDefaultServices() {
        if serviceItems.isEmpty {
            let defaultServices = [
                ServiceItem(
                    name: "Forestry Mulching",
                    description: "Professional forestry mulching to clear vegetation while leaving beneficial mulch",
                    category: .forestryMulching,
                    unitType: .perAcre,
                    basePrice: 2500.0,
                    minimumQuantity: 0.5,
                    pricingModel: .tiered,
                    equipmentRequired: ["Forestry Mulcher", "Skid Steer"],
                    estimatedDuration: 8.0
                ),
                
                ServiceItem(
                    name: "Land Clearing", 
                    description: "Complete land clearing for development or agriculture",
                    category: .landClearing,
                    unitType: .perAcre,
                    basePrice: 3500.0,
                    minimumQuantity: 1.0,
                    pricingModel: .volumeDiscount,
                    equipmentRequired: ["Excavator", "Forestry Mulcher", "Dump Truck"],
                    estimatedDuration: 12.0
                ),
                
                ServiceItem(
                    name: "Brush Clearing",
                    description: "Selective brush and undergrowth removal",
                    category: .brushClearing,
                    unitType: .perAcre,
                    basePrice: 1800.0,
                    minimumQuantity: 0.25,
                    pricingModel: .fixed,
                    equipmentRequired: ["Brush Cutter", "Chainsaw"],
                    estimatedDuration: 6.0
                ),
                
                ServiceItem(
                    name: "Site Assessment",
                    description: "Professional site evaluation and project planning",
                    category: .consultation,
                    unitType: .fixedPrice,
                    basePrice: 350.0,
                    minimumQuantity: 1.0,
                    maximumQuantity: 1.0,
                    pricingModel: .fixed,
                    estimatedDuration: 2.0
                ),
                
                ServiceItem(
                    name: "Emergency Clearing",
                    description: "Emergency tree and debris removal services",
                    category: .emergency,
                    unitType: .perHour,
                    basePrice: 450.0,
                    minimumQuantity: 2.0,
                    pricingModel: .fixed,
                    equipmentRequired: ["Excavator", "Chainsaw", "Truck"],
                    estimatedDuration: 4.0
                ),
                
                ServiceItem(
                    name: "Firebreak Creation",
                    description: "Strategic firebreak installation for wildfire protection",
                    category: .firebreakCreation,
                    unitType: .perLinearFoot,
                    basePrice: 12.0,
                    minimumQuantity: 100.0,
                    pricingModel: .tiered,
                    equipmentRequired: ["Forestry Mulcher", "Grader"],
                    estimatedDuration: 10.0
                )
            ]
            
            defaultServices.forEach { addServiceItem($0) }
        }
    }
    
    // MARK: - Persistence
    
    private func saveServiceItems() {
        if let encoded = try? JSONEncoder().encode(serviceItems) {
            UserDefaults.standard.set(encoded, forKey: serviceItemsKey)
        }
    }
    
    private func loadServiceItems() {
        if let data = UserDefaults.standard.data(forKey: serviceItemsKey),
           let decoded = try? JSONDecoder().decode([ServiceItem].self, from: data) {
            serviceItems = decoded
        }
    }
    
    private func saveLineItems() {
        if let encoded = try? JSONEncoder().encode(lineItems) {
            UserDefaults.standard.set(encoded, forKey: lineItemsKey)
        }
    }
    
    private func loadLineItems() {
        if let data = UserDefaults.standard.data(forKey: lineItemsKey),
           let decoded = try? JSONDecoder().decode([LineItem].self, from: data) {
            lineItems = decoded
        }
    }
}

// MARK: - Supporting Enums

enum CustomerTier: String, CaseIterable, Codable {
    case standard = "Standard"
    case preferred = "Preferred"
    case premium = "Premium"
    
    var discountPercentage: Double {
        switch self {
        case .standard: return 0.0
        case .preferred: return 5.0
        case .premium: return 10.0
        }
    }
    
    var color: Color {
        switch self {
        case .standard: return .gray
        case .preferred: return Color("TreeShopBlue")
        case .premium: return Color("TreeShopGreen")
        }
    }
}