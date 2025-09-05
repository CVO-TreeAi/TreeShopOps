import Foundation
import SwiftUI

struct Proposal: Identifiable, Codable {
    var id = UUID()
    var customerName: String
    var customerEmail: String
    var customerPhone: String
    var customerAddress: String
    var projectZipCode: String
    
    // Project Details
    var projectTitle: String
    var projectDescription: String
    var dateCreated: Date
    var dateUpdated: Date
    var status: ProposalStatus
    
    // Forestry Mulching & Land Clearing Details
    var landSize: Double
    var packageType: String
    var transportHours: Double
    var debrisYards: Double
    
    // Pricing Details
    var subtotal: Double
    var taxAmount: Double
    var totalAmount: Double
    var discount: Double
    
    // Additional Details
    var notes: String
    var termsAccepted: Bool
    var validUntil: Date
    
    init(
        customerName: String = "",
        customerEmail: String = "",
        customerPhone: String = "",
        customerAddress: String = "",
        projectZipCode: String = "",
        projectTitle: String = "",
        projectDescription: String = "",
        landSize: Double = 0.0,
        packageType: String = "medium",
        transportHours: Double = 2.0,
        debrisYards: Double = 0.0,
        subtotal: Double = 0.0,
        taxAmount: Double = 0.0,
        totalAmount: Double = 0.0,
        discount: Double = 0.0,
        notes: String = "",
        termsAccepted: Bool = false
    ) {
        self.customerName = customerName
        self.customerEmail = customerEmail
        self.customerPhone = customerPhone
        self.customerAddress = customerAddress
        self.projectZipCode = projectZipCode
        self.projectTitle = projectTitle
        self.projectDescription = projectDescription
        self.dateCreated = Date()
        self.dateUpdated = Date()
        self.status = .draft
        self.landSize = landSize
        self.packageType = packageType
        self.transportHours = transportHours
        self.debrisYards = debrisYards
        self.subtotal = subtotal
        self.taxAmount = taxAmount
        self.totalAmount = totalAmount
        self.discount = discount
        self.notes = notes
        self.termsAccepted = termsAccepted
        self.validUntil = Calendar.current.date(byAdding: .day, value: 30, to: Date()) ?? Date()
    }
}

enum ProposalStatus: String, CaseIterable, Codable {
    case draft = "Draft"
    case sent = "Sent"
    case accepted = "Accepted"
    case rejected = "Rejected"
    case expired = "Expired"
    
    var color: Color {
        switch self {
        case .draft:
            return .gray
        case .sent:
            return Color("TreeShopBlue")
        case .accepted:
            return Color("TreeShopGreen")
        case .rejected:
            return .red
        case .expired:
            return .orange
        }
    }
    
    var systemImage: String {
        switch self {
        case .draft:
            return "doc.text"
        case .sent:
            return "paperplane"
        case .accepted:
            return "checkmark.circle"
        case .rejected:
            return "xmark.circle"
        case .expired:
            return "clock.badge.exclamationmark"
        }
    }
}

class ProposalManager: ObservableObject {
    @Published var proposals: [Proposal] = []
    
    private let proposalsKey = "SavedProposals"
    
    init() {
        loadProposals()
    }
    
    func addProposal(_ proposal: Proposal) {
        proposals.append(proposal)
        saveProposals()
    }
    
    func updateProposal(_ proposal: Proposal) {
        if let index = proposals.firstIndex(where: { $0.id == proposal.id }) {
            var updatedProposal = proposal
            updatedProposal.dateUpdated = Date()
            proposals[index] = updatedProposal
            saveProposals()
        }
    }
    
    func deleteProposal(_ proposal: Proposal) {
        proposals.removeAll { $0.id == proposal.id }
        saveProposals()
    }
    
    func deleteProposals(at offsets: IndexSet) {
        proposals.remove(atOffsets: offsets)
        saveProposals()
    }
    
    func getProposal(by id: UUID) -> Proposal? {
        return proposals.first { $0.id == id }
    }
    
    func getProposalsByStatus(_ status: ProposalStatus) -> [Proposal] {
        return proposals.filter { $0.status == status }
    }
    
    func searchProposals(_ searchText: String) -> [Proposal] {
        if searchText.isEmpty {
            return proposals
        }
        return proposals.filter { proposal in
            proposal.customerName.localizedCaseInsensitiveContains(searchText) ||
            proposal.projectTitle.localizedCaseInsensitiveContains(searchText) ||
            proposal.customerEmail.localizedCaseInsensitiveContains(searchText)
        }
    }
    
    private func saveProposals() {
        if let encoded = try? JSONEncoder().encode(proposals) {
            UserDefaults.standard.set(encoded, forKey: proposalsKey)
        }
    }
    
    private func loadProposals() {
        if let data = UserDefaults.standard.data(forKey: proposalsKey),
           let decoded = try? JSONDecoder().decode([Proposal].self, from: data) {
            proposals = decoded
        }
    }
    
    // Helper method to create proposal from pricing model
    func createProposalFromPricing(pricingModel: PricingModel, customer: Customer?, projectTitle: String, projectDescription: String) -> Proposal {
        return Proposal(
            customerName: customer?.fullName ?? "",
            customerEmail: customer?.email ?? "",
            customerPhone: customer?.phone ?? "",
            customerAddress: customer?.fullAddress ?? "",
            projectZipCode: pricingModel.projectZipCode,
            projectTitle: projectTitle,
            projectDescription: projectDescription,
            landSize: 0.0,
            packageType: "medium",
            transportHours: 2.0,
            debrisYards: 0.0,
            subtotal: pricingModel.subtotal,
            taxAmount: 0.0,
            totalAmount: pricingModel.finalPrice,
            discount: 0.0
        )
    }
}