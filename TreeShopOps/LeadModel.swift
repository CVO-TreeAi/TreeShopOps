import Foundation
import SwiftUI

struct Lead: Identifiable, Codable {
    var id = UUID()
    var customerFirstName: String
    var customerLastName: String
    var customerEmail: String
    var customerPhone: String
    var customerAddress: String
    var customerCity: String
    var customerState: String
    var customerZipCode: String
    
    // Project Details
    var projectDescription: String
    var landSize: Double
    var projectLocation: String
    var urgency: LeadUrgency
    var dateCreated: Date
    var dateUpdated: Date
    var status: LeadStatus
    
    // Lead Source & Tracking
    var leadSource: LeadSource
    var estimatedValue: Double
    var notes: String
    var followUpDate: Date?
    var lastContactDate: Date?
    
    init(
        customerFirstName: String = "",
        customerLastName: String = "",
        customerEmail: String = "",
        customerPhone: String = "",
        customerAddress: String = "",
        customerCity: String = "",
        customerState: String = "",
        customerZipCode: String = "",
        projectDescription: String = "",
        landSize: Double = 0.0,
        projectLocation: String = "",
        urgency: LeadUrgency = .normal,
        leadSource: LeadSource = .website,
        estimatedValue: Double = 0.0,
        notes: String = ""
    ) {
        self.customerFirstName = customerFirstName
        self.customerLastName = customerLastName
        self.customerEmail = customerEmail
        self.customerPhone = customerPhone
        self.customerAddress = customerAddress
        self.customerCity = customerCity
        self.customerState = customerState
        self.customerZipCode = customerZipCode
        self.projectDescription = projectDescription
        self.landSize = landSize
        self.projectLocation = projectLocation
        self.urgency = urgency
        self.dateCreated = Date()
        self.dateUpdated = Date()
        self.status = .new
        self.leadSource = leadSource
        self.estimatedValue = estimatedValue
        self.notes = notes
    }
    
    var fullName: String {
        "\(customerFirstName) \(customerLastName)".trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    var fullAddress: String {
        let components = [customerAddress, customerCity, customerState, customerZipCode].filter { !$0.isEmpty }
        return components.joined(separator: ", ")
    }
}

enum LeadStatus: String, CaseIterable, Codable {
    case new = "New"
    case contacted = "Contacted"
    case quoted = "Quoted"
    case qualified = "Qualified"
    case lost = "Lost"
    case converted = "Converted"
    
    var color: Color {
        switch self {
        case .new:
            return Color("TreeShopBlue")
        case .contacted:
            return .orange
        case .quoted:
            return .purple
        case .qualified:
            return Color("TreeShopGreen")
        case .lost:
            return .red
        case .converted:
            return .green
        }
    }
    
    var systemImage: String {
        switch self {
        case .new:
            return "star.fill"
        case .contacted:
            return "phone.fill"
        case .quoted:
            return "doc.text.fill"
        case .qualified:
            return "checkmark.circle.fill"
        case .lost:
            return "xmark.circle.fill"
        case .converted:
            return "arrow.right.circle.fill"
        }
    }
}

enum LeadUrgency: String, CaseIterable, Codable {
    case low = "Low"
    case normal = "Normal"
    case high = "High"
    case urgent = "Urgent"
    
    var color: Color {
        switch self {
        case .low:
            return .gray
        case .normal:
            return Color("TreeShopBlue")
        case .high:
            return .orange
        case .urgent:
            return .red
        }
    }
    
    var systemImage: String {
        switch self {
        case .low:
            return "tortoise.fill"
        case .normal:
            return "clock.fill"
        case .high:
            return "exclamationmark.triangle.fill"
        case .urgent:
            return "flame.fill"
        }
    }
}

enum LeadSource: String, CaseIterable, Codable {
    case website = "Website"
    case phone = "Phone Call"
    case referral = "Referral"
    case google = "Google Ads"
    case facebook = "Facebook"
    case walkIn = "Walk-in"
    case other = "Other"
    
    var systemImage: String {
        switch self {
        case .website:
            return "globe"
        case .phone:
            return "phone"
        case .referral:
            return "person.2.fill"
        case .google:
            return "magnifyingglass"
        case .facebook:
            return "f.circle.fill"
        case .walkIn:
            return "building.2.fill"
        case .other:
            return "questionmark.circle"
        }
    }
}

class LeadManager: ObservableObject {
    @Published var leads: [Lead] = []
    
    private let leadsKey = "SavedLeads"
    
    init() {
        loadLeads()
    }
    
    func addLead(_ lead: Lead) {
        leads.append(lead)
        saveLeads()
    }
    
    func updateLead(_ lead: Lead) {
        if let index = leads.firstIndex(where: { $0.id == lead.id }) {
            var updatedLead = lead
            updatedLead.dateUpdated = Date()
            leads[index] = updatedLead
            saveLeads()
        }
    }
    
    func deleteLead(_ lead: Lead) {
        leads.removeAll { $0.id == lead.id }
        saveLeads()
    }
    
    func deleteLeads(at offsets: IndexSet) {
        leads.remove(atOffsets: offsets)
        saveLeads()
    }
    
    func getLead(by id: UUID) -> Lead? {
        return leads.first { $0.id == id }
    }
    
    func getLeadsByStatus(_ status: LeadStatus) -> [Lead] {
        return leads.filter { $0.status == status }
    }
    
    func searchLeads(_ searchText: String) -> [Lead] {
        if searchText.isEmpty {
            return leads
        }
        return leads.filter { lead in
            lead.fullName.localizedCaseInsensitiveContains(searchText) ||
            lead.customerEmail.localizedCaseInsensitiveContains(searchText) ||
            lead.projectDescription.localizedCaseInsensitiveContains(searchText) ||
            lead.customerPhone.localizedCaseInsensitiveContains(searchText)
        }
    }
    
    func convertLeadToProposal(_ lead: Lead) -> Proposal {
        return Proposal(
            customerName: lead.fullName,
            customerEmail: lead.customerEmail,
            customerPhone: lead.customerPhone,
            customerAddress: lead.fullAddress,
            projectZipCode: lead.customerZipCode,
            projectTitle: "Forestry Mulching - \(lead.projectLocation)",
            projectDescription: lead.projectDescription,
            landSize: lead.landSize,
            packageType: "medium",
            transportHours: 2.0,
            debrisYards: 0.0,
            subtotal: lead.estimatedValue,
            taxAmount: 0.0,
            totalAmount: lead.estimatedValue,
            discount: 0.0,
            notes: lead.notes
        )
    }
    
    private func saveLeads() {
        if let encoded = try? JSONEncoder().encode(leads) {
            UserDefaults.standard.set(encoded, forKey: leadsKey)
        }
    }
    
    private func loadLeads() {
        if let data = UserDefaults.standard.data(forKey: leadsKey),
           let decoded = try? JSONDecoder().decode([Lead].self, from: data) {
            leads = decoded
        }
    }
}