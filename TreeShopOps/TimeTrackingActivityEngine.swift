import Foundation
import SwiftUI

// MARK: - Time Tracking Activity Engine

class TimeTrackingActivityEngine {
    
    // MARK: - Activity Generation
    
    func generateActivities(for qualifications: EmployeeQualifications) -> [TimeTrackingActivity] {
        var activities: [TimeTrackingActivity] = []
        
        // Universal activities (all employees)
        activities.append(contentsOf: getUniversalActivities())
        
        // Role-specific activities
        activities.append(contentsOf: getRoleSpecificActivities(role: qualifications.primaryRole, tier: qualifications.tier))
        
        // Leadership activities
        if qualifications.hasLeadership {
            activities.append(contentsOf: getLeadershipActivities(level: qualifications.leadershipLevel))
        }
        
        // Equipment activities
        for equipmentLevel in qualifications.equipmentCertifications {
            activities.append(contentsOf: getEquipmentActivities(level: equipmentLevel))
        }
        
        // Driver activities
        if let driverClass = qualifications.driverClassification {
            activities.append(contentsOf: getDriverActivities(class: driverClass))
        }
        
        // Professional certification activities
        for cert in qualifications.professionalCertifications {
            activities.append(contentsOf: getCertificationActivities(cert: cert))
        }
        
        // Cross-training activities
        for crossTrain in qualifications.crossTraining {
            activities.append(contentsOf: getCrossTrainingActivities(crossTrain: crossTrain))
        }
        
        // Remove duplicates and sort by category
        let uniqueActivities = Array(Set(activities)).sorted { activity1, activity2 in
            if activity1.category != activity2.category {
                return activity1.category.rawValue < activity2.category.rawValue
            }
            return activity1.name < activity2.name
        }
        
        return uniqueActivities
    }
    
    // MARK: - Universal Activities (All Employees)
    
    private func getUniversalActivities() -> [TimeTrackingActivity] {
        return [
            TimeTrackingActivity(
                name: "Transport/Travel",
                category: .transport,
                billable: true,
                requiresLocation: true,
                requiresEquipment: false,
                safetyLevel: .low,
                icon: "car.fill",
                color: "TreeShopBlue",
                allowedRoles: PrimaryRole.allCases,
                minimumTier: 1,
                requiredCertifications: [],
                requiredEquipment: [],
                requiredLeadership: nil
            ),
            TimeTrackingActivity(
                name: "Setup/Breakdown",
                category: .setup,
                billable: true,
                requiresLocation: true,
                requiresEquipment: true,
                safetyLevel: .medium,
                icon: "wrench.and.screwdriver",
                color: "orange",
                allowedRoles: PrimaryRole.allCases,
                minimumTier: 1,
                requiredCertifications: [],
                requiredEquipment: [],
                requiredLeadership: nil
            ),
            TimeTrackingActivity(
                name: "Safety Briefing",
                category: .safety,
                billable: false,
                requiresLocation: true,
                requiresEquipment: false,
                safetyLevel: .low,
                icon: "shield.checkered",
                color: "red",
                allowedRoles: PrimaryRole.allCases,
                minimumTier: 1,
                requiredCertifications: [],
                requiredEquipment: [],
                requiredLeadership: nil
            ),
            TimeTrackingActivity(
                name: "Equipment Inspection",
                category: .equipment,
                billable: false,
                requiresLocation: false,
                requiresEquipment: true,
                safetyLevel: .low,
                icon: "checkmark.shield",
                color: "green",
                allowedRoles: PrimaryRole.allCases,
                minimumTier: 2,
                requiredCertifications: [],
                requiredEquipment: [],
                requiredLeadership: nil
            ),
            TimeTrackingActivity(
                name: "Documentation/Reporting",
                category: .documentation,
                billable: true,
                requiresLocation: false,
                requiresEquipment: false,
                safetyLevel: .low,
                icon: "doc.text",
                color: "gray",
                allowedRoles: PrimaryRole.allCases,
                minimumTier: 1,
                requiredCertifications: [],
                requiredEquipment: [],
                requiredLeadership: nil
            ),
            TimeTrackingActivity(
                name: "Break Time",
                category: .administrative,
                billable: false,
                requiresLocation: false,
                requiresEquipment: false,
                safetyLevel: .low,
                icon: "cup.and.saucer",
                color: "gray",
                allowedRoles: PrimaryRole.allCases,
                minimumTier: 1,
                requiredCertifications: [],
                requiredEquipment: [],
                requiredLeadership: nil
            ),
            TimeTrackingActivity(
                name: "Weather Delay",
                category: .administrative,
                billable: false,
                requiresLocation: true,
                requiresEquipment: false,
                safetyLevel: .low,
                icon: "cloud.rain",
                color: "blue",
                allowedRoles: PrimaryRole.allCases,
                minimumTier: 1,
                requiredCertifications: [],
                requiredEquipment: [],
                requiredLeadership: nil
            )
        ]
    }
    
    // MARK: - Role-Specific Activities
    
    private func getRoleSpecificActivities(role: PrimaryRole, tier: Int) -> [TimeTrackingActivity] {
        switch role {
        case .ATC:
            return getATCActivities(tier: tier)
        case .TRS:
            return getTRSActivities(tier: tier)
        case .FOR:
            return getFORActivities(tier: tier)
        case .LCL:
            return getLCLActivities(tier: tier)
        case .MUL:
            return getMULActivities(tier: tier)
        case .STG:
            return getSTGActivities(tier: tier)
        case .ESR:
            return getESRActivities(tier: tier)
        case .EQO:
            return getEQOActivities(tier: tier)
        default:
            return []
        }
    }
    
    // MARK: - ATC Activities (Arborist Tree Care)
    
    private func getATCActivities(tier: Int) -> [TimeTrackingActivity] {
        var activities: [TimeTrackingActivity] = [
            TimeTrackingActivity(
                name: "Tree Assessment/Diagnosis",
                category: .coreWork,
                billable: true,
                requiresLocation: true,
                requiresEquipment: false,
                safetyLevel: .low,
                icon: "tree.circle",
                color: "TreeShopGreen",
                allowedRoles: [.ATC],
                minimumTier: 1,
                requiredCertifications: [],
                requiredEquipment: [],
                requiredLeadership: nil
            ),
            TimeTrackingActivity(
                name: "Pruning Operations",
                category: .coreWork,
                billable: true,
                requiresLocation: true,
                requiresEquipment: true,
                safetyLevel: .high,
                icon: "scissors.circle",
                color: "TreeShopGreen",
                allowedRoles: [.ATC],
                minimumTier: 2,
                requiredCertifications: [],
                requiredEquipment: [],
                requiredLeadership: nil
            ),
            TimeTrackingActivity(
                name: "Plant Health Care",
                category: .coreWork,
                billable: true,
                requiresLocation: true,
                requiresEquipment: true,
                safetyLevel: .medium,
                icon: "leaf.fill",
                color: "green",
                allowedRoles: [.ATC],
                minimumTier: 3,
                requiredCertifications: [],
                requiredEquipment: [],
                requiredLeadership: nil
            )
        ]
        
        if tier >= 3 {
            activities.append(contentsOf: [
                TimeTrackingActivity(
                    name: "Soil Testing/Treatment",
                    category: .coreWork,
                    billable: true,
                    requiresLocation: true,
                    requiresEquipment: true,
                    safetyLevel: .medium,
                    icon: "flask.fill",
                    color: "brown",
                    allowedRoles: [.ATC],
                    minimumTier: 3,
                    requiredCertifications: [],
                    requiredEquipment: [],
                    requiredLeadership: nil
                ),
                TimeTrackingActivity(
                    name: "Species Identification",
                    category: .coreWork,
                    billable: true,
                    requiresLocation: true,
                    requiresEquipment: false,
                    safetyLevel: .low,
                    icon: "eye.fill",
                    color: "green",
                    allowedRoles: [.ATC],
                    minimumTier: 3,
                    requiredCertifications: [],
                    requiredEquipment: [],
                    requiredLeadership: nil
                )
            ])
        }
        
        if tier >= 4 {
            activities.append(
                TimeTrackingActivity(
                    name: "Consulting/Client Education",
                    category: .client,
                    billable: true,
                    requiresLocation: false,
                    requiresEquipment: false,
                    safetyLevel: .low,
                    icon: "person.2.wave.2",
                    color: "blue",
                    allowedRoles: [.ATC],
                    minimumTier: 4,
                    requiredCertifications: [],
                    requiredEquipment: [],
                    requiredLeadership: nil
                )
            )
        }
        
        return activities
    }
    
    // MARK: - TRS Activities (Tree Removal Specialist)
    
    private func getTRSActivities(tier: Int) -> [TimeTrackingActivity] {
        var activities: [TimeTrackingActivity] = [
            TimeTrackingActivity(
                name: "Rigging Setup",
                category: .setup,
                billable: true,
                requiresLocation: true,
                requiresEquipment: true,
                safetyLevel: .high,
                icon: "link.circle",
                color: "orange",
                allowedRoles: [.TRS],
                minimumTier: 2,
                requiredCertifications: [],
                requiredEquipment: [],
                requiredLeadership: nil
            ),
            TimeTrackingActivity(
                name: "Climbing Operations",
                category: .coreWork,
                billable: true,
                requiresLocation: true,
                requiresEquipment: true,
                safetyLevel: .extreme,
                icon: "person.fill",
                color: "red",
                allowedRoles: [.TRS],
                minimumTier: 3,
                requiredCertifications: [],
                requiredEquipment: [],
                requiredLeadership: nil
            ),
            TimeTrackingActivity(
                name: "Cutting/Sectioning",
                category: .coreWork,
                billable: true,
                requiresLocation: true,
                requiresEquipment: true,
                safetyLevel: .high,
                icon: "scissors.circle",
                color: "orange",
                allowedRoles: [.TRS],
                minimumTier: 2,
                requiredCertifications: [],
                requiredEquipment: [],
                requiredLeadership: nil
            ),
            TimeTrackingActivity(
                name: "Hazard Assessment",
                category: .safety,
                billable: true,
                requiresLocation: true,
                requiresEquipment: false,
                safetyLevel: .medium,
                icon: "exclamationmark.triangle",
                color: "red",
                allowedRoles: [.TRS],
                minimumTier: 3,
                requiredCertifications: [],
                requiredEquipment: [],
                requiredLeadership: nil
            )
        ]
        
        if tier >= 4 {
            activities.append(
                TimeTrackingActivity(
                    name: "Emergency Response",
                    category: .emergency,
                    billable: true,
                    requiresLocation: true,
                    requiresEquipment: true,
                    safetyLevel: .extreme,
                    icon: "exclamationmark.octagon.fill",
                    color: "red",
                    allowedRoles: [.TRS, .ESR],
                    minimumTier: 4,
                    requiredCertifications: [],
                    requiredEquipment: [],
                    requiredLeadership: nil
                )
            )
        }
        
        return activities
    }
    
    // MARK: - EQO Activities (Equipment Operations)
    
    private func getEQOActivities(tier: Int) -> [TimeTrackingActivity] {
        return [
            TimeTrackingActivity(
                name: "Equipment Operation",
                category: .coreWork,
                billable: true,
                requiresLocation: true,
                requiresEquipment: true,
                safetyLevel: .high,
                icon: "gear.circle",
                color: "purple",
                allowedRoles: [.EQO],
                minimumTier: 1,
                requiredCertifications: [],
                requiredEquipment: [],
                requiredLeadership: nil
            ),
            TimeTrackingActivity(
                name: "Pre-Operation Inspection",
                category: .equipment,
                billable: false,
                requiresLocation: false,
                requiresEquipment: true,
                safetyLevel: .medium,
                icon: "checkmark.circle",
                color: "green",
                allowedRoles: [.EQO],
                minimumTier: 1,
                requiredCertifications: [],
                requiredEquipment: [],
                requiredLeadership: nil
            ),
            TimeTrackingActivity(
                name: "Equipment Maintenance",
                category: .maintenance,
                billable: false,
                requiresLocation: false,
                requiresEquipment: true,
                safetyLevel: .medium,
                icon: "wrench.fill",
                color: "brown",
                allowedRoles: [.EQO, .MNT],
                minimumTier: 2,
                requiredCertifications: [],
                requiredEquipment: [],
                requiredLeadership: nil
            ),
            TimeTrackingActivity(
                name: "Fueling/Servicing",
                category: .maintenance,
                billable: false,
                requiresLocation: false,
                requiresEquipment: true,
                safetyLevel: .medium,
                icon: "fuelpump",
                color: "yellow",
                allowedRoles: [.EQO, .MNT],
                minimumTier: 1,
                requiredCertifications: [],
                requiredEquipment: [],
                requiredLeadership: nil
            ),
            TimeTrackingActivity(
                name: "Troubleshooting",
                category: .maintenance,
                billable: false,
                requiresLocation: false,
                requiresEquipment: true,
                safetyLevel: .low,
                icon: "questionmark.circle",
                color: "orange",
                allowedRoles: [.EQO, .MNT],
                minimumTier: 3,
                requiredCertifications: [],
                requiredEquipment: [],
                requiredLeadership: nil
            )
        ]
    }
    
    // MARK: - FOR Activities (Forestry & Land Management)
    
    private func getFORActivities(tier: Int) -> [TimeTrackingActivity] {
        return [
            TimeTrackingActivity(
                name: "Land Assessment",
                category: .coreWork,
                billable: true,
                requiresLocation: true,
                requiresEquipment: false,
                safetyLevel: .medium,
                icon: "map.fill",
                color: "green",
                allowedRoles: [.FOR],
                minimumTier: 1,
                requiredCertifications: [],
                requiredEquipment: [],
                requiredLeadership: nil
            ),
            TimeTrackingActivity(
                name: "Forest Planning",
                category: .coreWork,
                billable: true,
                requiresLocation: true,
                requiresEquipment: false,
                safetyLevel: .low,
                icon: "tree.circle",
                color: "TreeShopGreen",
                allowedRoles: [.FOR],
                minimumTier: 3,
                requiredCertifications: [],
                requiredEquipment: [],
                requiredLeadership: nil
            ),
            TimeTrackingActivity(
                name: "Habitat Management",
                category: .coreWork,
                billable: true,
                requiresLocation: true,
                requiresEquipment: true,
                safetyLevel: .medium,
                icon: "leaf.circle",
                color: "green",
                allowedRoles: [.FOR],
                minimumTier: 4,
                requiredCertifications: [],
                requiredEquipment: [],
                requiredLeadership: nil
            )
        ]
    }
    
    // MARK: - LCL Activities (Land Clearing & Excavation)
    
    private func getLCLActivities(tier: Int) -> [TimeTrackingActivity] {
        return [
            TimeTrackingActivity(
                name: "Site Preparation",
                category: .coreWork,
                billable: true,
                requiresLocation: true,
                requiresEquipment: true,
                safetyLevel: .high,
                icon: "hammer.fill",
                color: "orange",
                allowedRoles: [.LCL],
                minimumTier: 1,
                requiredCertifications: [],
                requiredEquipment: [],
                requiredLeadership: nil
            ),
            TimeTrackingActivity(
                name: "Excavation Operations",
                category: .coreWork,
                billable: true,
                requiresLocation: true,
                requiresEquipment: true,
                safetyLevel: .high,
                icon: "scoop",
                color: "brown",
                allowedRoles: [.LCL],
                minimumTier: 2,
                requiredCertifications: [],
                requiredEquipment: [.E2],
                requiredLeadership: nil
            ),
            TimeTrackingActivity(
                name: "Grading/Leveling",
                category: .coreWork,
                billable: true,
                requiresLocation: true,
                requiresEquipment: true,
                safetyLevel: .medium,
                icon: "level.fill",
                color: "yellow",
                allowedRoles: [.LCL],
                minimumTier: 3,
                requiredCertifications: [],
                requiredEquipment: [.E3],
                requiredLeadership: nil
            )
        ]
    }
    
    // MARK: - MUL Activities (Mulching & Material Processing)
    
    private func getMULActivities(tier: Int) -> [TimeTrackingActivity] {
        return [
            TimeTrackingActivity(
                name: "Mulching Operations",
                category: .coreWork,
                billable: true,
                requiresLocation: true,
                requiresEquipment: true,
                safetyLevel: .high,
                icon: "leaf.fill",
                color: "brown",
                allowedRoles: [.MUL],
                minimumTier: 1,
                requiredCertifications: [],
                requiredEquipment: [],
                requiredLeadership: nil
            ),
            TimeTrackingActivity(
                name: "Material Processing",
                category: .coreWork,
                billable: true,
                requiresLocation: true,
                requiresEquipment: true,
                safetyLevel: .medium,
                icon: "arrow.3.trianglepath",
                color: "TreeShopGreen",
                allowedRoles: [.MUL],
                minimumTier: 2,
                requiredCertifications: [],
                requiredEquipment: [],
                requiredLeadership: nil
            ),
            TimeTrackingActivity(
                name: "Quality Control",
                category: .coreWork,
                billable: true,
                requiresLocation: true,
                requiresEquipment: false,
                safetyLevel: .low,
                icon: "checkmark.seal",
                color: "blue",
                allowedRoles: [.MUL],
                minimumTier: 3,
                requiredCertifications: [],
                requiredEquipment: [],
                requiredLeadership: nil
            )
        ]
    }
    
    // MARK: - STG Activities (Stump Grinding & Site Restoration)
    
    private func getSTGActivities(tier: Int) -> [TimeTrackingActivity] {
        return [
            TimeTrackingActivity(
                name: "Stump Grinding",
                category: .coreWork,
                billable: true,
                requiresLocation: true,
                requiresEquipment: true,
                safetyLevel: .high,
                icon: "circle.grid.hex",
                color: "orange",
                allowedRoles: [.STG],
                minimumTier: 1,
                requiredCertifications: [],
                requiredEquipment: [],
                requiredLeadership: nil
            ),
            TimeTrackingActivity(
                name: "Site Restoration",
                category: .coreWork,
                billable: true,
                requiresLocation: true,
                requiresEquipment: true,
                safetyLevel: .medium,
                icon: "leaf.circle",
                color: "green",
                allowedRoles: [.STG],
                minimumTier: 2,
                requiredCertifications: [],
                requiredEquipment: [],
                requiredLeadership: nil
            ),
            TimeTrackingActivity(
                name: "Clean-up Operations",
                category: .coreWork,
                billable: true,
                requiresLocation: true,
                requiresEquipment: true,
                safetyLevel: .medium,
                icon: "trash.fill",
                color: "gray",
                allowedRoles: [.STG],
                minimumTier: 1,
                requiredCertifications: [],
                requiredEquipment: [],
                requiredLeadership: nil
            )
        ]
    }
    
    // MARK: - ESR Activities (Emergency & Storm Response)
    
    private func getESRActivities(tier: Int) -> [TimeTrackingActivity] {
        return [
            TimeTrackingActivity(
                name: "Emergency Assessment",
                category: .emergency,
                billable: true,
                requiresLocation: true,
                requiresEquipment: false,
                safetyLevel: .high,
                icon: "exclamationmark.triangle.fill",
                color: "red",
                allowedRoles: [.ESR],
                minimumTier: 1,
                requiredCertifications: [],
                requiredEquipment: [],
                requiredLeadership: nil
            ),
            TimeTrackingActivity(
                name: "Hazard Mitigation",
                category: .emergency,
                billable: true,
                requiresLocation: true,
                requiresEquipment: true,
                safetyLevel: .extreme,
                icon: "shield.fill",
                color: "red",
                allowedRoles: [.ESR],
                minimumTier: 2,
                requiredCertifications: [],
                requiredEquipment: [],
                requiredLeadership: nil
            ),
            TimeTrackingActivity(
                name: "Storm Cleanup",
                category: .emergency,
                billable: true,
                requiresLocation: true,
                requiresEquipment: true,
                safetyLevel: .high,
                icon: "cloud.bolt.rain.fill",
                color: "purple",
                allowedRoles: [.ESR],
                minimumTier: 1,
                requiredCertifications: [],
                requiredEquipment: [],
                requiredLeadership: nil
            )
        ]
    }
    
    // MARK: - Leadership Activities
    
    private func getLeadershipActivities(level: LeadershipLevel) -> [TimeTrackingActivity] {
        var activities: [TimeTrackingActivity] = []
        
        // Team Leader activities
        if level != .none {
            activities.append(contentsOf: [
                TimeTrackingActivity(
                    name: "Crew Coordination",
                    category: .leadership,
                    billable: true,
                    requiresLocation: true,
                    requiresEquipment: false,
                    safetyLevel: .low,
                    icon: "person.3.sequence",
                    color: "gold",
                    allowedRoles: PrimaryRole.allCases,
                    minimumTier: 2,
                    requiredCertifications: [],
                    requiredEquipment: [],
                    requiredLeadership: .teamLeader
                ),
                TimeTrackingActivity(
                    name: "Task Assignment",
                    category: .leadership,
                    billable: false,
                    requiresLocation: false,
                    requiresEquipment: false,
                    safetyLevel: .low,
                    icon: "list.clipboard",
                    color: "blue",
                    allowedRoles: PrimaryRole.allCases,
                    minimumTier: 2,
                    requiredCertifications: [],
                    requiredEquipment: [],
                    requiredLeadership: .teamLeader
                )
            ])
        }
        
        // Supervisor activities
        if level == .supervisor || level == .manager || level == .director {
            activities.append(contentsOf: [
                TimeTrackingActivity(
                    name: "Project Planning",
                    category: .leadership,
                    billable: true,
                    requiresLocation: false,
                    requiresEquipment: false,
                    safetyLevel: .low,
                    icon: "calendar.badge.plus",
                    color: "blue",
                    allowedRoles: PrimaryRole.allCases,
                    minimumTier: 3,
                    requiredCertifications: [],
                    requiredEquipment: [],
                    requiredLeadership: .supervisor
                ),
                TimeTrackingActivity(
                    name: "Performance Review",
                    category: .administrative,
                    billable: false,
                    requiresLocation: false,
                    requiresEquipment: false,
                    safetyLevel: .low,
                    icon: "star.circle",
                    color: "gold",
                    allowedRoles: PrimaryRole.allCases,
                    minimumTier: 3,
                    requiredCertifications: [],
                    requiredEquipment: [],
                    requiredLeadership: .supervisor
                ),
                TimeTrackingActivity(
                    name: "Safety Oversight",
                    category: .safety,
                    billable: false,
                    requiresLocation: true,
                    requiresEquipment: false,
                    safetyLevel: .low,
                    icon: "eye.circle",
                    color: "red",
                    allowedRoles: PrimaryRole.allCases,
                    minimumTier: 3,
                    requiredCertifications: [],
                    requiredEquipment: [],
                    requiredLeadership: .supervisor
                )
            ])
        }
        
        // Manager activities
        if level == .manager || level == .director {
            activities.append(contentsOf: [
                TimeTrackingActivity(
                    name: "Strategic Planning",
                    category: .administrative,
                    billable: false,
                    requiresLocation: false,
                    requiresEquipment: false,
                    safetyLevel: .low,
                    icon: "chart.line.uptrend.xyaxis",
                    color: "purple",
                    allowedRoles: PrimaryRole.allCases,
                    minimumTier: 4,
                    requiredCertifications: [],
                    requiredEquipment: [],
                    requiredLeadership: .manager
                ),
                TimeTrackingActivity(
                    name: "Business Development",
                    category: .client,
                    billable: false,
                    requiresLocation: false,
                    requiresEquipment: false,
                    safetyLevel: .low,
                    icon: "briefcase.fill",
                    color: "blue",
                    allowedRoles: PrimaryRole.allCases,
                    minimumTier: 4,
                    requiredCertifications: [],
                    requiredEquipment: [],
                    requiredLeadership: .manager
                )
            ])
        }
        
        return activities
    }
    
    // MARK: - Equipment Level Activities
    
    private func getEquipmentActivities(level: EquipmentLevel) -> [TimeTrackingActivity] {
        switch level {
        case .E1:
            return [
                TimeTrackingActivity(
                    name: "Hand Tool Operations",
                    category: .coreWork,
                    billable: true,
                    requiresLocation: true,
                    requiresEquipment: true,
                    safetyLevel: .medium,
                    icon: "hammer",
                    color: "brown",
                    allowedRoles: PrimaryRole.allCases,
                    minimumTier: 1,
                    requiredCertifications: [],
                    requiredEquipment: [.E1],
                    requiredLeadership: nil
                )
            ]
        case .E2:
            return [
                TimeTrackingActivity(
                    name: "Chipper Operations",
                    category: .coreWork,
                    billable: true,
                    requiresLocation: true,
                    requiresEquipment: true,
                    safetyLevel: .high,
                    icon: "tornado",
                    color: "orange",
                    allowedRoles: [.MUL, .TRS, .LCL],
                    minimumTier: 2,
                    requiredCertifications: [],
                    requiredEquipment: [.E2],
                    requiredLeadership: nil
                )
            ]
        case .E3:
            return [
                TimeTrackingActivity(
                    name: "Bucket Truck Operations",
                    category: .coreWork,
                    billable: true,
                    requiresLocation: true,
                    requiresEquipment: true,
                    safetyLevel: .extreme,
                    icon: "car.rear.fill",
                    color: "red",
                    allowedRoles: [.TRS, .ATC],
                    minimumTier: 3,
                    requiredCertifications: [],
                    requiredEquipment: [.E3],
                    requiredLeadership: nil
                )
            ]
        case .E4:
            return [
                TimeTrackingActivity(
                    name: "Complex Machinery Operation",
                    category: .coreWork,
                    billable: true,
                    requiresLocation: true,
                    requiresEquipment: true,
                    safetyLevel: .extreme,
                    icon: "gear.circle.fill",
                    color: "purple",
                    allowedRoles: [.EQO, .LCL],
                    minimumTier: 4,
                    requiredCertifications: [],
                    requiredEquipment: [.E4],
                    requiredLeadership: nil
                )
            ]
        }
    }
    
    // MARK: - Driver Activities
    
    private func getDriverActivities(class driverClass: DriverClass) -> [TimeTrackingActivity] {
        switch driverClass {
        case .D1:
            return [
                TimeTrackingActivity(
                    name: "Vehicle Operation",
                    category: .transport,
                    billable: true,
                    requiresLocation: true,
                    requiresEquipment: false,
                    safetyLevel: .medium,
                    icon: "car.circle",
                    color: "TreeShopBlue",
                    allowedRoles: PrimaryRole.allCases,
                    minimumTier: 1,
                    requiredCertifications: [],
                    requiredEquipment: [],
                    requiredLeadership: nil
                )
            ]
        case .D2:
            return [
                TimeTrackingActivity(
                    name: "CDL Vehicle Operation",
                    category: .transport,
                    billable: true,
                    requiresLocation: true,
                    requiresEquipment: false,
                    safetyLevel: .medium,
                    icon: "truck.box",
                    color: "blue",
                    allowedRoles: PrimaryRole.allCases,
                    minimumTier: 2,
                    requiredCertifications: [],
                    requiredEquipment: [],
                    requiredLeadership: nil
                )
            ]
        case .D3:
            return [
                TimeTrackingActivity(
                    name: "Heavy Equipment Transport",
                    category: .transport,
                    billable: true,
                    requiresLocation: true,
                    requiresEquipment: true,
                    safetyLevel: .high,
                    icon: "truck.pickup",
                    color: "orange",
                    allowedRoles: PrimaryRole.allCases,
                    minimumTier: 3,
                    requiredCertifications: [],
                    requiredEquipment: [],
                    requiredLeadership: nil
                )
            ]
        case .DH:
            return [
                TimeTrackingActivity(
                    name: "Hazmat Transport",
                    category: .transport,
                    billable: true,
                    requiresLocation: true,
                    requiresEquipment: true,
                    safetyLevel: .extreme,
                    icon: "exclamationmark.triangle.fill",
                    color: "red",
                    allowedRoles: PrimaryRole.allCases,
                    minimumTier: 4,
                    requiredCertifications: [],
                    requiredEquipment: [],
                    requiredLeadership: nil
                )
            ]
        }
    }
    
    // MARK: - Professional Certification Activities
    
    private func getCertificationActivities(cert: ProfessionalCertification) -> [TimeTrackingActivity] {
        switch cert {
        case .CRA:
            return [
                TimeTrackingActivity(
                    name: "Crane Operations",
                    category: .coreWork,
                    billable: true,
                    requiresLocation: true,
                    requiresEquipment: true,
                    safetyLevel: .extreme,
                    icon: "arrow.up.and.down.and.arrow.left.and.right",
                    color: "red",
                    allowedRoles: [.TRS, .LCL],
                    minimumTier: 4,
                    requiredCertifications: [.CRA],
                    requiredEquipment: [],
                    requiredLeadership: nil
                )
            ]
        case .ISA:
            return [
                TimeTrackingActivity(
                    name: "Professional Consultation",
                    category: .client,
                    billable: true,
                    requiresLocation: false,
                    requiresEquipment: false,
                    safetyLevel: .low,
                    icon: "graduationcap.fill",
                    color: "blue",
                    allowedRoles: [.ATC, .FOR],
                    minimumTier: 3,
                    requiredCertifications: [.ISA],
                    requiredEquipment: [],
                    requiredLeadership: nil
                )
            ]
        case .OSH:
            return [
                TimeTrackingActivity(
                    name: "Safety Training Delivery",
                    category: .training,
                    billable: false,
                    requiresLocation: false,
                    requiresEquipment: false,
                    safetyLevel: .low,
                    icon: "person.wave.2.fill",
                    color: "red",
                    allowedRoles: PrimaryRole.allCases,
                    minimumTier: 3,
                    requiredCertifications: [.OSH],
                    requiredEquipment: [],
                    requiredLeadership: nil
                )
            ]
        default:
            return []
        }
    }
    
    // MARK: - Cross-Training Activities
    
    private func getCrossTrainingActivities(crossTrain: CrossTraining) -> [TimeTrackingActivity] {
        // Get base activities for the cross-trained role at specified tier
        let baseActivities = getRoleSpecificActivities(role: crossTrain.role, tier: crossTrain.tier)
        
        // Mark as cross-training variants
        return baseActivities.map { activity in
            TimeTrackingActivity(
                name: "Cross-Train: \(activity.name)",
                category: .training,
                billable: activity.billable,
                requiresLocation: activity.requiresLocation,
                requiresEquipment: activity.requiresEquipment,
                safetyLevel: activity.safetyLevel,
                icon: "arrow.triangle.2.circlepath",
                color: "purple",
                allowedRoles: [crossTrain.role],
                minimumTier: crossTrain.tier,
                requiredCertifications: [],
                requiredEquipment: [],
                requiredLeadership: nil
            )
        }
    }
}