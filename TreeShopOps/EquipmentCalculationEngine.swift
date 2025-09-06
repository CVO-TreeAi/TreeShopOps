import Foundation

// MARK: - Equipment Calculation Engine

struct EquipmentCalculationEngine {
    
    // MARK: - Main Calculation Function
    
    static func calculateCosts(usage: EquipmentUsage, financial: EquipmentFinancial) -> EquipmentCalculation {
        let annualHours = usage.annualHours
        let annualDepreciation = calculateAnnualDepreciation(financial: financial)
        let annualFuel = calculateAnnualFuel(financial: financial, usage: usage)
        let annualMaintenance = financial.annualMaintenance
        let totalAnnualCost = annualDepreciation + annualFuel + annualMaintenance + financial.annualInsuranceCost
        let hourlyCost = totalAnnualCost / annualHours
        let recommendedRate = hourlyCost * Constants.recommendedMarkup
        
        return EquipmentCalculation(
            annualHours: annualHours,
            annualDepreciation: annualDepreciation,
            annualFuel: annualFuel,
            annualMaintenance: annualMaintenance,
            totalAnnualCost: totalAnnualCost,
            hourlyCost: hourlyCost,
            recommendedRate: recommendedRate
        )
    }
    
    // MARK: - Individual Calculations
    
    static func calculateAnnualHours(daysPerYear: Int, hoursPerDay: Double) -> Double {
        return Double(daysPerYear) * hoursPerDay
    }
    
    static func calculateAnnualDepreciation(financial: EquipmentFinancial) -> Double {
        let depreciation = (financial.purchasePrice - financial.estimatedResaleValue) / Double(financial.yearsOfService)
        return max(0, depreciation)
    }
    
    static func calculateAnnualFuel(financial: EquipmentFinancial, usage: EquipmentUsage) -> Double {
        return financial.dailyFuelCost * Double(usage.daysPerYear)
    }
    
    static func calculateHourlyCost(totalAnnualCost: Double, annualHours: Double) -> Double {
        guard annualHours > 0 else { return 0 }
        return totalAnnualCost / annualHours
    }
    
    static func calculateRecommendedRate(hourlyCost: Double) -> Double {
        return hourlyCost * Constants.recommendedMarkup
    }
    
    static func calculateEstimatedResale(purchasePrice: Double, percentage: Double = Constants.defaultResalePercentage) -> Double {
        return purchasePrice * percentage
    }
    
    // MARK: - Validation and Quality Checks
    
    static func validateEquipmentData(equipment: Equipment) -> [EquipmentAlert] {
        var alerts: [EquipmentAlert] = []
        
        guard let calculated = equipment.calculated else {
            alerts.append(EquipmentAlert(type: .error, message: "Calculation failed"))
            return alerts
        }
        
        // Check for unrealistic costs
        if calculated.hourlyCost < 10 {
            alerts.append(EquipmentAlert(type: .warning, message: "Hourly cost seems low - verify inputs"))
        }
        
        if calculated.hourlyCost > 200 {
            alerts.append(EquipmentAlert(type: .warning, message: "Hourly cost seems high - check fuel/maintenance"))
        }
        
        if calculated.recommendedRate < 25 {
            alerts.append(EquipmentAlert(type: .error, message: "Rate may be unprofitable"))
        }
        
        if calculated.annualHours < 400 {
            alerts.append(EquipmentAlert(type: .info, message: "Low utilization - asset may be underused"))
        }
        
        // Check equipment age vs cost
        let currentYear = Calendar.current.component(.year, from: Date())
        let equipmentAge = currentYear - equipment.identity.year
        if equipmentAge > 15 && calculated.hourlyCost > 100 {
            alerts.append(EquipmentAlert(type: .warning, message: "Consider replacement - old equipment with high operating cost"))
        }
        
        return alerts
    }
    
    // MARK: - Cost Analysis
    
    static func analyzeCostBreakdown(calculation: EquipmentCalculation) -> CostBreakdown {
        let totalCost = calculation.totalAnnualCost
        
        return CostBreakdown(
            depreciationPercentage: (calculation.annualDepreciation / totalCost) * 100,
            fuelPercentage: (calculation.annualFuel / totalCost) * 100,
            maintenancePercentage: (calculation.annualMaintenance / totalCost) * 100,
            insurancePercentage: ((totalCost - calculation.annualDepreciation - calculation.annualFuel - calculation.annualMaintenance) / totalCost) * 100
        )
    }
}

// MARK: - Supporting Structures

struct EquipmentAlert {
    let type: AlertType
    let message: String
    
    enum AlertType: String, CaseIterable {
        case info = "Info"
        case warning = "Warning"
        case error = "Error"
        
        var color: String {
            switch self {
            case .info: return "blue"
            case .warning: return "orange"
            case .error: return "red"
            }
        }
        
        var systemImage: String {
            switch self {
            case .info: return "info.circle.fill"
            case .warning: return "exclamationmark.triangle.fill"
            case .error: return "xmark.octagon.fill"
            }
        }
    }
}

struct CostBreakdown {
    let depreciationPercentage: Double
    let fuelPercentage: Double
    let maintenancePercentage: Double
    let insurancePercentage: Double
    
    var dominantCostFactor: String {
        let costs = [
            ("Depreciation", depreciationPercentage),
            ("Fuel", fuelPercentage),
            ("Maintenance", maintenancePercentage),
            ("Insurance", insurancePercentage)
        ]
        
        let dominant = costs.max { $0.1 < $1.1 }
        return dominant?.0 ?? "Unknown"
    }
}

// MARK: - Constants

private struct Constants {
    static let recommendedMarkup: Double = 1.3
    static let defaultResalePercentage: Double = 0.2
}

// MARK: - Extensions for Formatting

extension Double {
    var asCurrency: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = Locale.current
        formatter.maximumFractionDigits = 0
        return formatter.string(from: NSNumber(value: self)) ?? "$0"
    }
    
    var asCurrencyWithCents: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = Locale.current
        formatter.maximumFractionDigits = 2
        return formatter.string(from: NSNumber(value: self)) ?? "$0.00"
    }
    
    var asPercentage: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .percent
        formatter.maximumFractionDigits = 1
        return formatter.string(from: NSNumber(value: self / 100)) ?? "0%"
    }
    
    var asHours: String {
        return String(format: "%.1f hrs", self)
    }
    
    var asDecimalHours: String {
        let hours = Int(self)
        let minutes = Int((self - Double(hours)) * 60)
        if minutes == 0 {
            return "\(hours)h"
        }
        return "\(hours)h \(minutes)m"
    }
}