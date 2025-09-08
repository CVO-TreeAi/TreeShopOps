import Foundation
import SwiftUI

// MARK: - Time Tracking Entry

struct TimeEntry: Identifiable, Codable {
    var id = UUID()
    var employeeId: UUID
    var employeeCode: String
    var employeeName: String
    var workOrderId: UUID?
    var proposalId: UUID?
    var customerId: UUID?
    
    var activity: TimeTrackingActivity
    var startTime: Date
    var endTime: Date?
    var notes: String
    var location: String?
    var gpsCoordinate: GPSCoordinate?
    
    var isActive: Bool {
        return endTime == nil
    }
    
    var duration: TimeInterval {
        let end = endTime ?? Date()
        return end.timeIntervalSince(startTime)
    }
    
    var durationHours: Double {
        return duration / 3600
    }
    
    var durationFormatted: String {
        let hours = Int(duration) / 3600
        let minutes = Int(duration.truncatingRemainder(dividingBy: 3600)) / 60
        return String(format: "%02d:%02d", hours, minutes)
    }
}

// MARK: - Time Tracking Activity

struct TimeTrackingActivity: Identifiable, Codable, Hashable {
    var id = UUID()
    let name: String
    let category: ActivityCategory
    let billable: Bool
    let requiresLocation: Bool
    let requiresEquipment: Bool
    let safetyLevel: SafetyLevel
    let icon: String
    let color: String
    
    // Role restrictions - who can perform this activity
    let allowedRoles: [PrimaryRole]
    let minimumTier: Int
    let requiredCertifications: [ProfessionalCertification]
    let requiredEquipment: [EquipmentLevel]
    let requiredLeadership: LeadershipLevel?
    
    static func == (lhs: TimeTrackingActivity, rhs: TimeTrackingActivity) -> Bool {
        return lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

// MARK: - Activity Categories

enum ActivityCategory: String, CaseIterable, Codable {
    case coreWork = "Core Work"
    case transport = "Transport"
    case setup = "Setup"
    case safety = "Safety"
    case equipment = "Equipment"
    case documentation = "Documentation"
    case leadership = "Leadership"
    case maintenance = "Maintenance"
    case emergency = "Emergency"
    case training = "Training"
    case client = "Client"
    case administrative = "Administrative"
    
    var systemImage: String {
        switch self {
        case .coreWork: return "hammer.fill"
        case .transport: return "car.fill"
        case .setup: return "wrench.and.screwdriver"
        case .safety: return "shield.checkered"
        case .equipment: return "gear"
        case .documentation: return "doc.text"
        case .leadership: return "person.3.sequence"
        case .maintenance: return "wrench.fill"
        case .emergency: return "exclamationmark.triangle.fill"
        case .training: return "book.fill"
        case .client: return "person.2.wave.2"
        case .administrative: return "building.columns"
        }
    }
    
    var color: String {
        switch self {
        case .coreWork: return "TreeShopGreen"
        case .transport: return "TreeShopBlue"
        case .setup: return "orange"
        case .safety: return "red"
        case .equipment: return "purple"
        case .documentation: return "gray"
        case .leadership: return "gold"
        case .maintenance: return "brown"
        case .emergency: return "red"
        case .training: return "blue"
        case .client: return "green"
        case .administrative: return "gray"
        }
    }
}

enum SafetyLevel: String, CaseIterable, Codable {
    case low = "Low Risk"
    case medium = "Medium Risk"
    case high = "High Risk"
    case extreme = "Extreme Risk"
    
    var color: String {
        switch self {
        case .low: return "green"
        case .medium: return "yellow"
        case .high: return "orange"
        case .extreme: return "red"
        }
    }
    
    var systemImage: String {
        switch self {
        case .low: return "checkmark.shield"
        case .medium: return "exclamationmark.shield"
        case .high: return "exclamationmark.triangle"
        case .extreme: return "exclamationmark.octagon"
        }
    }
}

// MARK: - GPS Coordinate

struct GPSCoordinate: Codable {
    let latitude: Double
    let longitude: Double
    let accuracy: Double
    let timestamp: Date
}

// MARK: - Time Tracking Manager

class TimeTrackingManager: ObservableObject {
    @Published var timeEntries: [TimeEntry] = []
    @Published var activeEntries: [TimeEntry] = []
    
    private let timeEntriesKey = "SavedTimeEntries"
    private let activityEngine = TimeTrackingActivityEngine()
    
    init() {
        loadTimeEntries()
        updateActiveEntries()
    }
    
    // MARK: - Time Entry Operations
    
    func startTimeEntry(
        employee: Employee,
        activity: TimeTrackingActivity,
        workOrderId: UUID? = nil,
        proposalId: UUID? = nil,
        customerId: UUID? = nil,
        location: String? = nil
    ) {
        let entry = TimeEntry(
            employeeId: employee.id,
            employeeCode: employee.qualificationCode,
            employeeName: employee.fullName,
            workOrderId: workOrderId,
            proposalId: proposalId,
            customerId: customerId,
            activity: activity,
            startTime: Date(),
            endTime: nil,
            notes: "",
            location: location,
            gpsCoordinate: nil
        )
        
        timeEntries.append(entry)
        saveTimeEntries()
        updateActiveEntries()
    }
    
    func stopTimeEntry(_ entryId: UUID, notes: String = "") {
        if let index = timeEntries.firstIndex(where: { $0.id == entryId }) {
            timeEntries[index].endTime = Date()
            timeEntries[index].notes = notes
            saveTimeEntries()
            updateActiveEntries()
        }
    }
    
    func updateTimeEntry(_ entry: TimeEntry) {
        if let index = timeEntries.firstIndex(where: { $0.id == entry.id }) {
            timeEntries[index] = entry
            saveTimeEntries()
            updateActiveEntries()
        }
    }
    
    func deleteTimeEntry(_ entryId: UUID) {
        timeEntries.removeAll { $0.id == entryId }
        saveTimeEntries()
        updateActiveEntries()
    }
    
    // MARK: - Activity Assignment
    
    func getAvailableActivities(for employee: Employee) -> [TimeTrackingActivity] {
        return activityEngine.generateActivities(for: employee.qualifications)
    }
    
    // MARK: - Reporting and Analytics
    
    func getTimeEntriesForEmployee(_ employeeId: UUID, date: Date = Date()) -> [TimeEntry] {
        let calendar = Calendar.current
        return timeEntries.filter { entry in
            entry.employeeId == employeeId &&
            calendar.isDate(entry.startTime, inSameDayAs: date)
        }
    }
    
    func getTimeEntriesForWorkOrder(_ workOrderId: UUID) -> [TimeEntry] {
        return timeEntries.filter { $0.workOrderId == workOrderId }
    }
    
    func getTotalHours(employeeId: UUID, startDate: Date, endDate: Date) -> Double {
        return timeEntries
            .filter { 
                $0.employeeId == employeeId &&
                $0.startTime >= startDate &&
                $0.startTime <= endDate &&
                $0.endTime != nil
            }
            .reduce(0) { $0 + $1.durationHours }
    }
    
    func getDailyProductivityReport(date: Date = Date()) -> DailyProductivityReport {
        let calendar = Calendar.current
        let dayEntries = timeEntries.filter { entry in
            calendar.isDate(entry.startTime, inSameDayAs: date) && entry.endTime != nil
        }
        
        let totalHours = dayEntries.reduce(0) { $0 + $1.durationHours }
        let billableHours = dayEntries.filter { $0.activity.billable }.reduce(0) { $0 + $1.durationHours }
        let activeEmployees = Set(dayEntries.map { $0.employeeId }).count
        let topActivities = getTopActivities(from: dayEntries)
        
        return DailyProductivityReport(
            date: date,
            totalHours: totalHours,
            billableHours: billableHours,
            nonBillableHours: totalHours - billableHours,
            activeEmployeeCount: activeEmployees,
            productivityRate: billableHours / totalHours * 100,
            topActivities: topActivities,
            totalEntries: dayEntries.count
        )
    }
    
    private func getTopActivities(from entries: [TimeEntry]) -> [(activity: String, hours: Double)] {
        let activityTotals = Dictionary(grouping: entries, by: { $0.activity.name })
            .mapValues { entries in entries.reduce(0) { $0 + $1.durationHours } }
        
        return activityTotals
            .sorted { $0.value > $1.value }
            .prefix(5)
            .map { (activity: $0.key, hours: $0.value) }
    }
    
    // MARK: - Data Persistence
    
    private func updateActiveEntries() {
        activeEntries = timeEntries.filter { $0.isActive }
    }
    
    private func saveTimeEntries() {
        if let encoded = try? JSONEncoder().encode(timeEntries) {
            UserDefaults.standard.set(encoded, forKey: timeEntriesKey)
        }
    }
    
    private func loadTimeEntries() {
        if let data = UserDefaults.standard.data(forKey: timeEntriesKey),
           let decoded = try? JSONDecoder().decode([TimeEntry].self, from: data) {
            timeEntries = decoded
        }
    }
}

// MARK: - Daily Productivity Report

struct DailyProductivityReport {
    let date: Date
    let totalHours: Double
    let billableHours: Double
    let nonBillableHours: Double
    let activeEmployeeCount: Int
    let productivityRate: Double
    let topActivities: [(activity: String, hours: Double)]
    let totalEntries: Int
    
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
    
    var productivityGrade: String {
        switch productivityRate {
        case 90...100: return "Excellent"
        case 80..<90: return "Good"
        case 70..<80: return "Fair"
        case 60..<70: return "Poor"
        default: return "Critical"
        }
    }
    
    var productivityColor: String {
        switch productivityRate {
        case 90...100: return "TreeShopGreen"
        case 80..<90: return "blue"
        case 70..<80: return "orange"
        case 60..<70: return "red"
        default: return "red"
        }
    }
}