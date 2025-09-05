import Foundation
import SwiftUI

struct WorkOrder: Identifiable, Codable {
    var id = UUID()
    var proposalId: UUID?
    var workOrderNumber: String
    
    // Customer Information
    var customerName: String
    var customerEmail: String
    var customerPhone: String
    var customerAddress: String
    var projectLocation: String
    
    // Project Details
    var projectTitle: String
    var projectDescription: String
    var landSize: Double
    var packageType: String
    
    // Scheduling
    var scheduledStartDate: Date?
    var scheduledEndDate: Date?
    var actualStartDate: Date?
    var actualEndDate: Date?
    
    // Work Details
    var crewAssigned: [String]
    var equipmentUsed: [String]
    var hoursWorked: Double
    var materialsUsed: String
    
    // Progress Tracking
    var status: WorkOrderStatus
    var completionPercentage: Double
    var workNotes: String
    var safetyNotes: String
    
    // Financial
    var originalAmount: Double
    var additionalCosts: Double
    var finalAmount: Double
    
    // Dates
    var dateCreated: Date
    var dateUpdated: Date
    
    init(
        proposalId: UUID? = nil,
        workOrderNumber: String = "",
        customerName: String = "",
        customerEmail: String = "",
        customerPhone: String = "",
        customerAddress: String = "",
        projectLocation: String = "",
        projectTitle: String = "",
        projectDescription: String = "",
        landSize: Double = 0.0,
        packageType: String = "medium",
        originalAmount: Double = 0.0
    ) {
        self.proposalId = proposalId
        self.workOrderNumber = workOrderNumber.isEmpty ? "WO-\(UUID().uuidString.prefix(8).uppercased())" : workOrderNumber
        self.customerName = customerName
        self.customerEmail = customerEmail
        self.customerPhone = customerPhone
        self.customerAddress = customerAddress
        self.projectLocation = projectLocation
        self.projectTitle = projectTitle
        self.projectDescription = projectDescription
        self.landSize = landSize
        self.packageType = packageType
        self.crewAssigned = []
        self.equipmentUsed = []
        self.hoursWorked = 0.0
        self.materialsUsed = ""
        self.status = .scheduled
        self.completionPercentage = 0.0
        self.workNotes = ""
        self.safetyNotes = ""
        self.originalAmount = originalAmount
        self.additionalCosts = 0.0
        self.finalAmount = originalAmount
        self.dateCreated = Date()
        self.dateUpdated = Date()
    }
    
    var estimatedDuration: Int {
        if let start = scheduledStartDate, let end = scheduledEndDate {
            return Calendar.current.dateComponents([.day], from: start, to: end).day ?? 1
        }
        return 1
    }
    
    var isOverdue: Bool {
        if let scheduledEnd = scheduledEndDate {
            return Date() > scheduledEnd && status != .completed
        }
        return false
    }
}

enum WorkOrderStatus: String, CaseIterable, Codable {
    case scheduled = "Scheduled"
    case inProgress = "In Progress"
    case onHold = "On Hold"
    case completed = "Completed"
    case cancelled = "Cancelled"
    
    var color: Color {
        switch self {
        case .scheduled:
            return Color("TreeShopBlue")
        case .inProgress:
            return .orange
        case .onHold:
            return .yellow
        case .completed:
            return Color("TreeShopGreen")
        case .cancelled:
            return .red
        }
    }
    
    var systemImage: String {
        switch self {
        case .scheduled:
            return "calendar.badge.clock"
        case .inProgress:
            return "gearshape.2.fill"
        case .onHold:
            return "pause.circle.fill"
        case .completed:
            return "checkmark.circle.fill"
        case .cancelled:
            return "xmark.circle.fill"
        }
    }
}

class WorkOrderManager: ObservableObject {
    @Published var workOrders: [WorkOrder] = []
    
    private let workOrdersKey = "SavedWorkOrders"
    
    init() {
        loadWorkOrders()
    }
    
    func addWorkOrder(_ workOrder: WorkOrder) {
        workOrders.append(workOrder)
        saveWorkOrders()
    }
    
    func updateWorkOrder(_ workOrder: WorkOrder) {
        if let index = workOrders.firstIndex(where: { $0.id == workOrder.id }) {
            var updatedWorkOrder = workOrder
            updatedWorkOrder.dateUpdated = Date()
            workOrders[index] = updatedWorkOrder
            saveWorkOrders()
        }
    }
    
    func deleteWorkOrder(_ workOrder: WorkOrder) {
        workOrders.removeAll { $0.id == workOrder.id }
        saveWorkOrders()
    }
    
    func deleteWorkOrders(at offsets: IndexSet) {
        workOrders.remove(atOffsets: offsets)
        saveWorkOrders()
    }
    
    func getWorkOrder(by id: UUID) -> WorkOrder? {
        return workOrders.first { $0.id == id }
    }
    
    func getWorkOrdersByStatus(_ status: WorkOrderStatus) -> [WorkOrder] {
        return workOrders.filter { $0.status == status }
    }
    
    func searchWorkOrders(_ searchText: String) -> [WorkOrder] {
        if searchText.isEmpty {
            return workOrders
        }
        return workOrders.filter { workOrder in
            workOrder.customerName.localizedCaseInsensitiveContains(searchText) ||
            workOrder.workOrderNumber.localizedCaseInsensitiveContains(searchText) ||
            workOrder.projectTitle.localizedCaseInsensitiveContains(searchText)
        }
    }
    
    func createWorkOrderFromProposal(_ proposal: Proposal) -> WorkOrder {
        return WorkOrder(
            proposalId: proposal.id,
            customerName: proposal.customerName,
            customerEmail: proposal.customerEmail,
            customerPhone: proposal.customerPhone,
            customerAddress: proposal.customerAddress,
            projectLocation: proposal.customerAddress,
            projectTitle: proposal.projectTitle,
            projectDescription: proposal.projectDescription,
            landSize: proposal.landSize,
            packageType: proposal.packageType,
            originalAmount: proposal.totalAmount
        )
    }
    
    private func saveWorkOrders() {
        if let encoded = try? JSONEncoder().encode(workOrders) {
            UserDefaults.standard.set(encoded, forKey: workOrdersKey)
        }
    }
    
    private func loadWorkOrders() {
        if let data = UserDefaults.standard.data(forKey: workOrdersKey),
           let decoded = try? JSONDecoder().decode([WorkOrder].self, from: data) {
            workOrders = decoded
        }
    }
}