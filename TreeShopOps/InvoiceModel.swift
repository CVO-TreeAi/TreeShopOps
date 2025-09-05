import Foundation
import SwiftUI

struct Invoice: Identifiable, Codable {
    var id = UUID()
    var workOrderId: UUID?
    var invoiceNumber: String
    
    // Customer Information
    var customerName: String
    var customerEmail: String
    var customerPhone: String
    var customerAddress: String
    var billingAddress: String
    
    // Project Details
    var projectTitle: String
    var projectDescription: String
    var workCompletedDate: Date?
    var landSize: Double
    var packageType: String
    
    // Financial Details
    var originalAmount: Double
    var additionalCosts: Double
    var discountAmount: Double
    var subtotal: Double
    var taxRate: Double
    var taxAmount: Double
    var totalAmount: Double
    
    // Payment Information
    var depositAmount: Double
    var depositPaid: Bool
    var depositPaidDate: Date?
    var balanceAmount: Double
    var balancePaid: Bool
    var balancePaidDate: Date?
    var paymentMethod: PaymentMethod
    var paymentTerms: PaymentTerms
    
    // Invoice Details
    var status: InvoiceStatus
    var dateCreated: Date
    var dateUpdated: Date
    var dueDate: Date
    var notes: String
    
    init(
        workOrderId: UUID? = nil,
        invoiceNumber: String = "",
        customerName: String = "",
        customerEmail: String = "",
        customerPhone: String = "",
        customerAddress: String = "",
        billingAddress: String = "",
        projectTitle: String = "",
        projectDescription: String = "",
        landSize: Double = 0.0,
        packageType: String = "medium",
        originalAmount: Double = 0.0,
        additionalCosts: Double = 0.0,
        discountAmount: Double = 0.0,
        taxRate: Double = 0.0875
    ) {
        self.workOrderId = workOrderId
        self.invoiceNumber = invoiceNumber.isEmpty ? "INV-\(UUID().uuidString.prefix(8).uppercased())" : invoiceNumber
        self.customerName = customerName
        self.customerEmail = customerEmail
        self.customerPhone = customerPhone
        self.customerAddress = customerAddress
        self.billingAddress = billingAddress.isEmpty ? customerAddress : billingAddress
        self.projectTitle = projectTitle
        self.projectDescription = projectDescription
        self.landSize = landSize
        self.packageType = packageType
        self.originalAmount = originalAmount
        self.additionalCosts = additionalCosts
        self.discountAmount = discountAmount
        
        // Calculate financial details
        let baseAmount = originalAmount + additionalCosts - discountAmount
        self.subtotal = baseAmount
        self.taxRate = taxRate
        self.taxAmount = baseAmount * taxRate
        self.totalAmount = baseAmount + self.taxAmount
        
        // Payment calculations (25% deposit default)
        self.depositAmount = self.totalAmount * 0.25
        self.balanceAmount = self.totalAmount - self.depositAmount
        self.depositPaid = false
        self.balancePaid = false
        self.paymentMethod = .check
        self.paymentTerms = .net30
        
        self.status = .draft
        self.dateCreated = Date()
        self.dateUpdated = Date()
        self.dueDate = Calendar.current.date(byAdding: .day, value: 30, to: Date()) ?? Date()
        self.notes = ""
    }
    
    var totalPaid: Double {
        var paid = 0.0
        if depositPaid { paid += depositAmount }
        if balancePaid { paid += balanceAmount }
        return paid
    }
    
    var amountDue: Double {
        return totalAmount - totalPaid
    }
    
    var isFullyPaid: Bool {
        return amountDue <= 0.01 // Account for rounding
    }
    
    var isOverdue: Bool {
        return Date() > dueDate && !isFullyPaid
    }
}

enum InvoiceStatus: String, CaseIterable, Codable {
    case draft = "Draft"
    case sent = "Sent"
    case partiallyPaid = "Partially Paid"
    case paid = "Paid"
    case overdue = "Overdue"
    case cancelled = "Cancelled"
    
    var color: Color {
        switch self {
        case .draft:
            return .gray
        case .sent:
            return Color("TreeShopBlue")
        case .partiallyPaid:
            return .orange
        case .paid:
            return Color("TreeShopGreen")
        case .overdue:
            return .red
        case .cancelled:
            return .gray
        }
    }
    
    var systemImage: String {
        switch self {
        case .draft:
            return "doc.text"
        case .sent:
            return "paperplane.fill"
        case .partiallyPaid:
            return "dollarsign.circle.fill"
        case .paid:
            return "checkmark.circle.fill"
        case .overdue:
            return "exclamationmark.triangle.fill"
        case .cancelled:
            return "xmark.circle.fill"
        }
    }
}

enum PaymentMethod: String, CaseIterable, Codable {
    case cash = "Cash"
    case check = "Check"
    case creditCard = "Credit Card"
    case bankTransfer = "Bank Transfer"
    case financing = "Financing"
    
    var systemImage: String {
        switch self {
        case .cash:
            return "dollarsign.circle"
        case .check:
            return "doc.text"
        case .creditCard:
            return "creditcard"
        case .bankTransfer:
            return "building.columns"
        case .financing:
            return "chart.line.uptrend.xyaxis"
        }
    }
}

enum PaymentTerms: String, CaseIterable, Codable {
    case dueOnCompletion = "Due on Completion"
    case net15 = "Net 15"
    case net30 = "Net 30"
    case net60 = "Net 60"
    case custom = "Custom Terms"
    
    var systemImage: String {
        switch self {
        case .dueOnCompletion:
            return "clock.badge.checkmark"
        case .net15, .net30, .net60:
            return "calendar.badge.clock"
        case .custom:
            return "gearshape"
        }
    }
}

class InvoiceManager: ObservableObject {
    @Published var invoices: [Invoice] = []
    
    private let invoicesKey = "SavedInvoices"
    
    init() {
        loadInvoices()
    }
    
    func addInvoice(_ invoice: Invoice) {
        invoices.append(invoice)
        saveInvoices()
    }
    
    func updateInvoice(_ invoice: Invoice) {
        if let index = invoices.firstIndex(where: { $0.id == invoice.id }) {
            var updatedInvoice = invoice
            updatedInvoice.dateUpdated = Date()
            
            // Auto-update status based on payment
            if updatedInvoice.isFullyPaid {
                updatedInvoice.status = .paid
            } else if updatedInvoice.totalPaid > 0 {
                updatedInvoice.status = .partiallyPaid
            } else if updatedInvoice.isOverdue {
                updatedInvoice.status = .overdue
            }
            
            invoices[index] = updatedInvoice
            saveInvoices()
        }
    }
    
    func deleteInvoice(_ invoice: Invoice) {
        invoices.removeAll { $0.id == invoice.id }
        saveInvoices()
    }
    
    func deleteInvoices(at offsets: IndexSet) {
        invoices.remove(atOffsets: offsets)
        saveInvoices()
    }
    
    func getInvoice(by id: UUID) -> Invoice? {
        return invoices.first { $0.id == id }
    }
    
    func getInvoicesByStatus(_ status: InvoiceStatus) -> [Invoice] {
        return invoices.filter { $0.status == status }
    }
    
    func searchInvoices(_ searchText: String) -> [Invoice] {
        if searchText.isEmpty {
            return invoices
        }
        return invoices.filter { invoice in
            invoice.customerName.localizedCaseInsensitiveContains(searchText) ||
            invoice.invoiceNumber.localizedCaseInsensitiveContains(searchText) ||
            invoice.projectTitle.localizedCaseInsensitiveContains(searchText)
        }
    }
    
    func createInvoiceFromWorkOrder(_ workOrder: WorkOrder) -> Invoice {
        return Invoice(
            workOrderId: workOrder.id,
            customerName: workOrder.customerName,
            customerEmail: workOrder.customerEmail,
            customerPhone: workOrder.customerPhone,
            customerAddress: workOrder.customerAddress,
            projectTitle: workOrder.projectTitle,
            projectDescription: workOrder.projectDescription,
            landSize: workOrder.landSize,
            packageType: workOrder.packageType,
            originalAmount: workOrder.finalAmount
        )
    }
    
    func getTotalRevenue() -> Double {
        return invoices.filter { $0.status == .paid }.reduce(0) { $0 + $1.totalAmount }
    }
    
    func getOutstandingAmount() -> Double {
        return invoices.filter { $0.status != .paid && $0.status != .cancelled }.reduce(0) { $0 + $1.amountDue }
    }
    
    private func saveInvoices() {
        if let encoded = try? JSONEncoder().encode(invoices) {
            UserDefaults.standard.set(encoded, forKey: invoicesKey)
        }
    }
    
    private func loadInvoices() {
        if let data = UserDefaults.standard.data(forKey: invoicesKey),
           let decoded = try? JSONDecoder().decode([Invoice].self, from: data) {
            invoices = decoded
        }
    }
}