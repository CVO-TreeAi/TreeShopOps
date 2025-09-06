import Foundation

// MARK: - Employee Model

struct Employee: Codable, Identifiable, Hashable {
    let id: UUID
    var personalInfo: EmployeePersonalInfo
    var qualifications: EmployeeQualifications
    var compensation: EmployeeCompensation
    var calculated: EmployeeCalculation?
    var metadata: EmployeeMetadata
    
    init(
        personalInfo: EmployeePersonalInfo,
        qualifications: EmployeeQualifications,
        compensation: EmployeeCompensation
    ) {
        self.id = UUID()
        self.personalInfo = personalInfo
        self.qualifications = qualifications
        self.compensation = compensation
        self.calculated = EmployeeCalculationEngine.calculateTrueHourlyCost(
            qualifications: qualifications,
            compensation: compensation
        )
        self.metadata = EmployeeMetadata(
            dateHired: Date(),
            status: .active,
            availability: .available,
            performanceRating: 0,
            hoursThisMonth: 0,
            totalHoursWorked: 0
        )
    }
    
    var fullName: String {
        return "\(personalInfo.firstName) \(personalInfo.lastName)"
    }
    
    var qualificationCode: String {
        return EmployeeQualificationCodeBuilder.buildCode(from: qualifications)
    }
}

// MARK: - Employee Personal Info

struct EmployeePersonalInfo: Codable, Hashable {
    var firstName: String
    var lastName: String
    var employeeNumber: String
    var email: String?
    var phone: String?
    var emergencyContact: String?
    var address: String?
}

// MARK: - Employee Qualifications

struct EmployeeQualifications: Codable, Hashable {
    var primaryRole: PrimaryRole
    var tier: Int // 1-5
    var leadershipLevel: LeadershipLevel
    var equipmentCertifications: [EquipmentLevel]
    var driverClassification: DriverClass?
    var professionalCertifications: [ProfessionalCertification]
    var crossTraining: [CrossTraining]
    var specializations: [String]
    
    var hasLeadership: Bool {
        return leadershipLevel != .none
    }
    
    var hasEquipmentCerts: Bool {
        return !equipmentCertifications.isEmpty
    }
    
    var hasDriverLicense: Bool {
        return driverClassification != nil
    }
    
    var totalCertifications: Int {
        return equipmentCertifications.count + professionalCertifications.count + crossTraining.count
    }
}

// MARK: - Employee Compensation

struct EmployeeCompensation: Codable, Hashable {
    var baseHourlyRate: Double
    var overtime: Double // Multiplier for overtime (usually 1.5)
    var benefits: Double // Annual benefits cost
    var workersComp: Double // Workers compensation rate
    var payrollTaxes: Double // Payroll tax rate
    var bonusStructure: String?
    var lastRaise: Date?
    var nextReviewDate: Date?
}

// MARK: - Employee Calculation

struct EmployeeCalculation: Codable, Hashable {
    let baseMultiplier: Double
    let leadershipPremium: Double
    let equipmentPremium: Double
    let driverPremium: Double
    let certificationPremium: Double
    let crossTrainingPremium: Double
    let trueHourlyCost: Double
    let billingRate: Double // Recommended billing rate
    let profitMargin: Double
    
    // Additional metrics
    var annualCost: Double {
        return trueHourlyCost * 2080 // 40 hours/week * 52 weeks
    }
    
    var monthlyBenefitsCost: Double {
        return annualCost * 0.3 / 12 // Estimated 30% benefits
    }
    
    var overtimeCost: Double {
        return trueHourlyCost * 1.5 // Time and a half
    }
}

// MARK: - Employee Metadata

struct EmployeeMetadata: Codable, Hashable {
    var dateHired: Date
    var status: EmployeeStatus
    var availability: EmployeeAvailability
    var performanceRating: Double // 0-5 scale
    var hoursThisMonth: Double
    var totalHoursWorked: Double
    var lastPromotion: Date?
    var nextReviewDate: Date?
    var disciplinaryActions: Int
    var safetyRecord: Double // Days without incident
    var customerRating: Double? // Customer feedback rating
    
    var yearsOfService: Int {
        let calendar = Calendar.current
        return calendar.dateComponents([.year], from: dateHired, to: Date()).year ?? 0
    }
    
    var isEligibleForPromotion: Bool {
        return yearsOfService >= 1 && performanceRating >= 4.0 && disciplinaryActions == 0
    }
    
    var utilizationRate: Double {
        // Calculate utilization based on hours worked vs available hours
        let workingDaysThisMonth = 22 // Approximate
        let availableHours = Double(workingDaysThisMonth) * 8
        return (hoursThisMonth / availableHours) * 100
    }
}

// MARK: - Enums

enum PrimaryRole: String, CaseIterable, Codable {
    // Primary Roles from TreeShop system
    case ATC = "ATC" // Arborist Tree Care
    case TRS = "TRS" // Tree Removal Specialist  
    case FOR = "FOR" // Forestry Specialist
    case LCL = "LCL" // Land Clearing
    case MUL = "MUL" // Mulching Specialist
    case STG = "STG" // Stump Grinding
    case ESR = "ESR" // Emergency Response
    case LSC = "LSC" // Landscape
    case EQO = "EQO" // Equipment Operator
    case MNT = "MNT" // Maintenance
    case SAL = "SAL" // Sales
    case PMC = "PMC" // Project Management Coordination
    case ADM = "ADM" // Administration
    case FIN = "FIN" // Finance
    case SAF = "SAF" // Safety
    case TEC = "TEC" // Technical
    
    var fullName: String {
        switch self {
        case .ATC: return "Arborist Tree Care"
        case .TRS: return "Tree Removal Specialist"
        case .FOR: return "Forestry Specialist"
        case .LCL: return "Land Clearing"
        case .MUL: return "Mulching Specialist"
        case .STG: return "Stump Grinding"
        case .ESR: return "Emergency Response"
        case .LSC: return "Landscape"
        case .EQO: return "Equipment Operator"
        case .MNT: return "Maintenance"
        case .SAL: return "Sales"
        case .PMC: return "Project Management"
        case .ADM: return "Administration"
        case .FIN: return "Finance"
        case .SAF: return "Safety"
        case .TEC: return "Technical"
        }
    }
    
    var systemImage: String {
        switch self {
        case .ATC: return "tree.circle"
        case .TRS: return "tree.fill"
        case .FOR: return "leaf.fill"
        case .LCL: return "hammer.fill"
        case .MUL: return "scissors.circle"
        case .STG: return "circle.grid.hex"
        case .ESR: return "exclamationmark.triangle.fill"
        case .LSC: return "leaf.circle"
        case .EQO: return "gear.circle"
        case .MNT: return "wrench.and.screwdriver"
        case .SAL: return "person.wave.2"
        case .PMC: return "person.3.sequence"
        case .ADM: return "building.columns"
        case .FIN: return "dollarsign.circle"
        case .SAF: return "shield.checkered"
        case .TEC: return "laptopcomputer"
        }
    }
    
    var baseMultiplier: Double {
        // Base tier multipliers for different roles
        switch self {
        case .ATC, .TRS: return 1.8  // Skilled tree work
        case .FOR, .MUL: return 1.7  // Forestry operations
        case .LCL, .STG: return 1.6  // Ground operations
        case .ESR: return 2.0        // Emergency premium
        case .LSC: return 1.5        // Landscape work
        case .EQO: return 1.7        // Equipment operation
        case .MNT: return 1.9        // Maintenance skills
        case .SAL, .PMC: return 1.4  // Administrative
        case .ADM, .FIN: return 1.3  // Office roles
        case .SAF, .TEC: return 1.6  // Specialized
        }
    }
}

enum LeadershipLevel: String, CaseIterable, Codable {
    case none = "None"
    case teamLeader = "+L"     // Team Leader
    case supervisor = "+S"     // Supervisor
    case manager = "+M"        // Manager
    case director = "+D"       // Director
    
    var fullName: String {
        switch self {
        case .none: return "No Leadership Role"
        case .teamLeader: return "Team Leader"
        case .supervisor: return "Supervisor"
        case .manager: return "Manager"
        case .director: return "Director"
        }
    }
    
    var premium: Double {
        switch self {
        case .none: return 0
        case .teamLeader: return 2.0   // $2/hr premium
        case .supervisor: return 5.0   // $5/hr premium
        case .manager: return 10.0     // $10/hr premium
        case .director: return 15.0    // $15/hr premium
        }
    }
}

enum EquipmentLevel: String, CaseIterable, Codable {
    case E1 = "+E1" // Basic Equipment
    case E2 = "+E2" // Intermediate Equipment
    case E3 = "+E3" // Advanced Equipment
    case E4 = "+E4" // Specialized Equipment
    
    var description: String {
        switch self {
        case .E1: return "Basic Equipment Operation"
        case .E2: return "Intermediate Equipment"
        case .E3: return "Advanced Equipment"
        case .E4: return "Specialized Equipment"
        }
    }
    
    var premium: Double {
        switch self {
        case .E1: return 1.0
        case .E2: return 2.0
        case .E3: return 3.5
        case .E4: return 5.0
        }
    }
}

enum DriverClass: String, CaseIterable, Codable {
    case D1 = "+D1" // Standard License
    case D2 = "+D2" // CDL Class B
    case D3 = "+D3" // CDL Class A
    case DH = "+DH" // Hazmat Endorsement
    
    var description: String {
        switch self {
        case .D1: return "Standard Driver's License"
        case .D2: return "Commercial Class B License"
        case .D3: return "Commercial Class A License"  
        case .DH: return "Hazmat Endorsement"
        }
    }
    
    var premium: Double {
        switch self {
        case .D1: return 1.0
        case .D2: return 2.5
        case .D3: return 4.0
        case .DH: return 6.0
        }
    }
}

enum ProfessionalCertification: String, CaseIterable, Codable {
    case ISA = "+ISA"   // International Society of Arboriculture
    case TRA = "+TRA"   // Tree Risk Assessment
    case MUN = "+MUN"   // Municipal Specialist
    case UTL = "+UTL"   // Utility Specialist
    case CRA = "+CRA"   // Climbing Risk Assessment
    case OSH = "+OSH"   // OSHA Safety
    case CPR = "+CPR"   // CPR/First Aid
    case PPE = "+PPE"   // Personal Protective Equipment
    case RFW = "+RFW"   // Right of Way
    case EMR = "+EMR"   // Emergency Medical Response
    
    var fullName: String {
        switch self {
        case .ISA: return "ISA Certified Arborist"
        case .TRA: return "Tree Risk Assessment Qualified"
        case .MUN: return "Municipal Specialist"
        case .UTL: return "Utility Specialist"
        case .CRA: return "Climbing Risk Assessment"
        case .OSH: return "OSHA Safety Certified"
        case .CPR: return "CPR/First Aid Certified"
        case .PPE: return "PPE Specialist"
        case .RFW: return "Right of Way Certified"
        case .EMR: return "Emergency Medical Response"
        }
    }
    
    var premium: Double {
        switch self {
        case .ISA: return 3.0
        case .TRA: return 2.5
        case .MUN, .UTL: return 2.0
        case .CRA: return 1.5
        case .OSH: return 1.0
        case .CPR, .PPE: return 0.5
        case .RFW: return 1.5
        case .EMR: return 2.0
        }
    }
}

struct CrossTraining: Codable, Hashable {
    let role: PrimaryRole
    let tier: Int
    
    var code: String {
        return "X-\(role.rawValue)\(tier)"
    }
    
    var description: String {
        return "Cross-trained: \(role.fullName) Level \(tier)"
    }
    
    var premium: Double {
        return Double(tier) * 0.5 // $0.50 per tier level
    }
}

enum EmployeeStatus: String, CaseIterable, Codable {
    case active = "Active"
    case onProject = "On Project"
    case onLeave = "On Leave"
    case unavailable = "Unavailable"
    case training = "In Training"
    case terminated = "Terminated"
    
    var color: String {
        switch self {
        case .active: return "TreeShopGreen"
        case .onProject: return "TreeShopBlue"
        case .onLeave: return "orange"
        case .unavailable: return "red"
        case .training: return "purple"
        case .terminated: return "gray"
        }
    }
    
    var systemImage: String {
        switch self {
        case .active: return "checkmark.circle.fill"
        case .onProject: return "hammer.circle.fill"
        case .onLeave: return "pause.circle.fill"
        case .unavailable: return "xmark.circle.fill"
        case .training: return "book.circle.fill"
        case .terminated: return "minus.circle.fill"
        }
    }
}

enum EmployeeAvailability: String, CaseIterable, Codable {
    case available = "Available"
    case busy = "Busy"
    case onLeave = "On Leave"
    case partTime = "Part Time"
    case seasonal = "Seasonal"
    
    var color: String {
        switch self {
        case .available: return "TreeShopGreen"
        case .busy: return "orange"
        case .onLeave: return "red"
        case .partTime: return "TreeShopBlue"
        case .seasonal: return "purple"
        }
    }
}

// MARK: - Employee Manager

class EmployeeManager: ObservableObject {
    @Published var employees: [Employee] = []
    
    private let employeesKey = "SavedEmployees"
    
    init() {
        loadEmployees()
    }
    
    // MARK: - CRUD Operations
    
    func addEmployee(_ employee: Employee) {
        self.employees.append(employee)
        saveEmployees()
    }
    
    func updateEmployee(_ employee: Employee) {
        if let index = self.employees.firstIndex(where: { $0.id == employee.id }) {
            var updatedEmployee = employee
            updatedEmployee.metadata.lastModified = Date()
            updatedEmployee.calculated = EmployeeCalculationEngine.calculateTrueHourlyCost(
                qualifications: employee.qualifications,
                compensation: employee.compensation
            )
            self.employees[index] = updatedEmployee
            saveEmployees()
        }
    }
    
    func deleteEmployee(_ employee: Employee) {
        self.employees.removeAll { $0.id == employee.id }
        saveEmployees()
    }
    
    func getEmployee(by id: UUID) -> Employee? {
        return employees.first { $0.id == id }
    }
    
    // MARK: - Filtering and Search
    
    func getEmployeesByRole(_ role: PrimaryRole) -> [Employee] {
        return employees.filter { $0.qualifications.primaryRole == role }
    }
    
    func getEmployeesByStatus(_ status: EmployeeStatus) -> [Employee] {
        return employees.filter { $0.metadata.status == status }
    }
    
    func getAvailableEmployees() -> [Employee] {
        return employees.filter { 
            $0.metadata.status == .active && 
            $0.metadata.availability == .available 
        }
    }
    
    func searchEmployees(_ searchTerm: String) -> [Employee] {
        guard !searchTerm.isEmpty else { return employees }
        
        let lowercasedTerm = searchTerm.lowercased()
        return employees.filter {
            $0.personalInfo.firstName.lowercased().contains(lowercasedTerm) ||
            $0.personalInfo.lastName.lowercased().contains(lowercasedTerm) ||
            $0.personalInfo.employeeNumber.lowercased().contains(lowercasedTerm) ||
            $0.qualifications.primaryRole.fullName.lowercased().contains(lowercasedTerm) ||
            $0.qualificationCode.lowercased().contains(lowercasedTerm)
        }
    }
    
    // MARK: - Statistics
    
    func getWorkforceStats() -> EmployeeWorkforceStats {
        let totalCount = employees.count
        let availableCount = getAvailableEmployees().count
        let onProjectCount = getEmployeesByStatus(.onProject).count
        let averageRate = employees.isEmpty ? 0 : 
            employees.reduce(0) { $0 + ($1.calculated?.trueHourlyCost ?? 0) } / Double(totalCount)
        let averagePerformance = employees.isEmpty ? 0 :
            employees.reduce(0) { $0 + $1.metadata.performanceRating } / Double(totalCount)
        
        return EmployeeWorkforceStats(
            totalCount: totalCount,
            availableCount: availableCount,
            onProjectCount: onProjectCount,
            averageHourlyRate: averageRate,
            averagePerformance: averagePerformance,
            highPerformersCount: employees.filter { $0.metadata.performanceRating >= 4.5 }.count,
            needsTrainingCount: employees.filter { needsTraining($0) }.count
        )
    }
    
    private func needsTraining(_ employee: Employee) -> Bool {
        return employee.metadata.performanceRating < 3.0 ||
               employee.qualifications.totalCertifications < 2 ||
               employee.metadata.yearsOfService > 2 && employee.qualifications.tier < 3
    }
    
    // MARK: - Data Persistence
    
    private func saveEmployees() {
        if let encoded = try? JSONEncoder().encode(employees) {
            UserDefaults.standard.set(encoded, forKey: employeesKey)
        }
    }
    
    private func loadEmployees() {
        if let data = UserDefaults.standard.data(forKey: employeesKey),
           let decoded = try? JSONDecoder().decode([Employee].self, from: data) {
            self.employees = decoded
        }
    }
}

// MARK: - Employee Workforce Statistics

struct EmployeeWorkforceStats {
    let totalCount: Int
    let availableCount: Int
    let onProjectCount: Int
    let averageHourlyRate: Double
    let averagePerformance: Double
    let highPerformersCount: Int
    let needsTrainingCount: Int
    
    var utilizationRate: Double {
        guard totalCount > 0 else { return 0 }
        return Double(onProjectCount) / Double(totalCount) * 100
    }
    
    var totalMonthlyCost: Double {
        return averageHourlyRate * 160 * Double(totalCount) // Assuming 160 hours/month
    }
    
    var availabilityRate: Double {
        guard totalCount > 0 else { return 0 }
        return Double(availableCount) / Double(totalCount) * 100
    }
}

// MARK: - Employee Calculation Engine

struct EmployeeCalculationEngine {
    
    static func calculateTrueHourlyCost(
        qualifications: EmployeeQualifications,
        compensation: EmployeeCompensation
    ) -> EmployeeCalculation {
        
        // Base multiplier from role and tier
        let roleMultiplier = qualifications.primaryRole.baseMultiplier
        let tierMultiplier = getTierMultiplier(tier: qualifications.tier)
        let baseMultiplier = roleMultiplier + tierMultiplier
        
        // Leadership premium
        let leadershipPremium = qualifications.leadershipLevel.premium
        
        // Equipment certifications premium
        let equipmentPremium = qualifications.equipmentCertifications.reduce(0) { $0 + $1.premium }
        
        // Driver classification premium
        let driverPremium = qualifications.driverClassification?.premium ?? 0
        
        // Professional certifications premium
        let certificationPremium = qualifications.professionalCertifications.reduce(0) { $0 + $1.premium }
        
        // Cross training premium
        let crossTrainingPremium = qualifications.crossTraining.reduce(0) { $0 + $1.premium }
        
        // Calculate true hourly cost
        let baseCost = compensation.baseHourlyRate * baseMultiplier
        let totalPremiums = leadershipPremium + equipmentPremium + driverPremium + 
                           certificationPremium + crossTrainingPremium
        let trueHourlyCost = baseCost + totalPremiums
        
        // Calculate recommended billing rate (2.5x markup typical for labor)
        let billingRate = trueHourlyCost * 2.5
        let profitMargin = ((billingRate - trueHourlyCost) / billingRate) * 100
        
        return EmployeeCalculation(
            baseMultiplier: baseMultiplier,
            leadershipPremium: leadershipPremium,
            equipmentPremium: equipmentPremium,
            driverPremium: driverPremium,
            certificationPremium: certificationPremium,
            crossTrainingPremium: crossTrainingPremium,
            trueHourlyCost: trueHourlyCost,
            billingRate: billingRate,
            profitMargin: profitMargin
        )
    }
    
    private static func getTierMultiplier(tier: Int) -> Double {
        switch tier {
        case 1: return 0.0  // Entry level
        case 2: return 0.1  // Basic
        case 3: return 0.2  // Intermediate
        case 4: return 0.4  // Advanced
        case 5: return 0.6  // Expert
        default: return 0.1
        }
    }
}

// MARK: - Qualification Code Builder

struct EmployeeQualificationCodeBuilder {
    
    static func buildCode(from qualifications: EmployeeQualifications) -> String {
        var codeComponents: [String] = []
        
        // Primary role and tier
        codeComponents.append("\(qualifications.primaryRole.rawValue)\(qualifications.tier)")
        
        // Leadership
        if qualifications.leadershipLevel != .none {
            codeComponents.append(qualifications.leadershipLevel.rawValue)
        }
        
        // Equipment certifications
        for equipment in qualifications.equipmentCertifications.sorted(by: { $0.rawValue < $1.rawValue }) {
            codeComponents.append(equipment.rawValue)
        }
        
        // Driver classification
        if let driver = qualifications.driverClassification {
            codeComponents.append(driver.rawValue)
        }
        
        // Professional certifications
        for cert in qualifications.professionalCertifications.sorted(by: { $0.rawValue < $1.rawValue }) {
            codeComponents.append(cert.rawValue)
        }
        
        // Cross training
        for training in qualifications.crossTraining {
            codeComponents.append(training.code)
        }
        
        return codeComponents.joined(separator: "")
    }
    
    static func parseCode(_ code: String) -> EmployeeQualifications? {
        // TODO: Implement code parsing if needed
        return nil
    }
}