import Foundation
import SwiftUI

// MARK: - Customer Data Model
struct Customer: Identifiable, Codable {
    var id = UUID()
    var firstName: String = ""
    var lastName: String = ""
    var email: String = ""
    var phone: String = ""
    var address: String = ""
    var city: String = ""
    var state: String = ""
    var zipCode: String = ""
    var notes: String = ""
    var dateCreated: Date = Date()
    var lastUpdated: Date = Date()
    var projects: [CustomerProject] = []
    var tags: [String] = []
    var preferredContactMethod: ContactMethod = .phone
    
    var fullName: String {
        "\(firstName) \(lastName)".trimmingCharacters(in: .whitespacesAndNewlines)
    }
    var customerType: CustomerType = .residential
    var referralSource: String = ""
    
    var fullAddress: String {
        let components = [address, city, state, zipCode].filter { !$0.isEmpty }
        return components.joined(separator: ", ")
    }
    
    var totalProjects: Int {
        projects.count
    }
    
    var totalRevenue: Double {
        projects.reduce(0) { $0 + $1.finalPrice }
    }
    
    var lastProjectDate: Date? {
        projects.map { $0.dateCreated }.max()
    }
}

// MARK: - Customer Project
struct CustomerProject: Identifiable, Codable {
    var id = UUID()
    var projectName: String = ""
    var landSize: Double = 0.0
    var packageType: PackageType = .medium
    var projectZipCode: String = ""
    var transportHours: Double = 0.0
    var debrisYards: Double = 0.0
    var baseCost: Double = 0.0
    var transportCost: Double = 0.0
    var debrisCost: Double = 0.0
    var finalPrice: Double = 0.0
    var depositAmount: Double = 0.0
    var projectStatus: ProjectStatus = .quoted
    var dateCreated: Date = Date()
    var scheduledDate: Date?
    var completedDate: Date?
    var notes: String = ""
    
    var statusColor: Color {
        switch projectStatus {
        case .quoted: return Color(red: 1.0, green: 0.76, blue: 0.03)
        case .accepted: return Color(red: 0.2, green: 0.7, blue: 0.3)
        case .scheduled: return Color(red: 0.0, green: 0.5, blue: 1.0)
        case .inProgress: return Color(red: 1.0, green: 0.3, blue: 0.0)
        case .completed: return Color(red: 0.2, green: 0.7, blue: 0.3)
        case .cancelled: return Color(red: 0.7, green: 0.3, blue: 0.3)
        }
    }
}

// MARK: - Enums
enum ContactMethod: String, CaseIterable, Codable {
    case phone = "phone"
    case email = "email"
    case text = "text"
    
    var displayName: String {
        switch self {
        case .phone: return "Phone Call"
        case .email: return "Email"
        case .text: return "Text Message"
        }
    }
    
    var iconName: String {
        switch self {
        case .phone: return "phone.fill"
        case .email: return "envelope.fill"
        case .text: return "message.fill"
        }
    }
}

enum CustomerType: String, CaseIterable, Codable {
    case residential = "residential"
    case commercial = "commercial"
    case municipal = "municipal"
    
    var displayName: String {
        switch self {
        case .residential: return "Residential"
        case .commercial: return "Commercial"
        case .municipal: return "Municipal"
        }
    }
    
    var iconName: String {
        switch self {
        case .residential: return "house.fill"
        case .commercial: return "building.2.fill"
        case .municipal: return "building.columns.fill"
        }
    }
}

enum ProjectStatus: String, CaseIterable, Codable {
    case quoted = "quoted"
    case accepted = "accepted"
    case scheduled = "scheduled"
    case inProgress = "inProgress"
    case completed = "completed"
    case cancelled = "cancelled"
    
    var displayName: String {
        switch self {
        case .quoted: return "Quoted"
        case .accepted: return "Accepted"
        case .scheduled: return "Scheduled"
        case .inProgress: return "In Progress"
        case .completed: return "Completed"
        case .cancelled: return "Cancelled"
        }
    }
}

// MARK: - Customer Manager
class CustomerManager: ObservableObject {
    @Published var customers: [Customer] = []
    @Published var searchText: String = ""
    @Published var selectedCustomerType: CustomerType? = nil
    
    private let userDefaults = UserDefaults.standard
    private let customersKey = "savedCustomers"
    
    init() {
        loadCustomers()
    }
    
    var filteredCustomers: [Customer] {
        var filtered = customers
        
        // Filter by search text
        if !searchText.isEmpty {
            filtered = filtered.filter { customer in
                customer.fullName.lowercased().contains(searchText.lowercased()) ||
                customer.email.lowercased().contains(searchText.lowercased()) ||
                customer.phone.contains(searchText) ||
                customer.city.lowercased().contains(searchText.lowercased())
            }
        }
        
        // Filter by customer type
        if let selectedType = selectedCustomerType {
            filtered = filtered.filter { $0.customerType == selectedType }
        }
        
        return filtered.sorted { $0.lastUpdated > $1.lastUpdated }
    }
    
    func addCustomer(_ customer: Customer) {
        var newCustomer = customer
        newCustomer.lastUpdated = Date()
        customers.append(newCustomer)
        saveCustomers()
    }
    
    func updateCustomer(_ customer: Customer) {
        if let index = customers.firstIndex(where: { $0.id == customer.id }) {
            var updatedCustomer = customer
            updatedCustomer.lastUpdated = Date()
            customers[index] = updatedCustomer
            saveCustomers()
        }
    }
    
    func deleteCustomer(_ customer: Customer) {
        customers.removeAll { $0.id == customer.id }
        saveCustomers()
    }
    
    func addProjectToCustomer(_ customerId: UUID, project: CustomerProject) {
        if let index = customers.firstIndex(where: { $0.id == customerId }) {
            customers[index].projects.append(project)
            customers[index].lastUpdated = Date()
            saveCustomers()
        }
    }
    
    func createProjectFromQuote(_ customerId: UUID, pricingModel: PricingModel, projectName: String = "Tree Service Project") {
        let project = CustomerProject(
            projectName: projectName,
            landSize: pricingModel.landSize,
            packageType: pricingModel.selectedPackage,
            projectZipCode: pricingModel.projectZipCode,
            transportHours: pricingModel.transportHours,
            debrisYards: pricingModel.debrisYards,
            baseCost: pricingModel.baseCost,
            transportCost: pricingModel.transportCost,
            debrisCost: pricingModel.debrisCost,
            finalPrice: pricingModel.finalPrice,
            depositAmount: pricingModel.depositAmount,
            projectStatus: .quoted,
            dateCreated: Date()
        )
        
        addProjectToCustomer(customerId, project: project)
    }
    
    func saveCustomers() {
        DispatchQueue.global(qos: .background).async {
            if let encoded = try? JSONEncoder().encode(self.customers) {
                DispatchQueue.main.async {
                    self.userDefaults.set(encoded, forKey: self.customersKey)
                }
            }
        }
    }
    
    private func loadCustomers() {
        if let data = userDefaults.data(forKey: customersKey),
           let decoded = try? JSONDecoder().decode([Customer].self, from: data) {
            customers = decoded
        } else {
            // Start with empty customer list
            customers = []
        }
    }
    
    private func loadSampleData() {
        let sampleCustomers = [
            Customer(
                firstName: "John",
                lastName: "Smith",
                email: "john.smith@email.com",
                phone: "(555) 123-4567",
                address: "123 Oak Street",
                city: "Portland",
                state: "OR",
                zipCode: "97205",
                notes: "Has large property with many mature trees",
                projects: [
                    CustomerProject(
                        projectName: "Backyard Tree Removal",
                        landSize: 2.5,
                        packageType: .medium,
                        projectZipCode: "97205",
                        finalPrice: 8750,
                        depositAmount: 2187.50,
                        projectStatus: .completed,
                        dateCreated: Calendar.current.date(byAdding: .day, value: -30, to: Date()) ?? Date(),
                        completedDate: Calendar.current.date(byAdding: .day, value: -5, to: Date()) ?? Date()
                    )
                ],
                customerType: .residential,
                referralSource: "Google Search"
            ),
            Customer(
                firstName: "Sarah",
                lastName: "Johnson",
                email: "sarah@company.com",
                phone: "(555) 987-6543",
                address: "456 Pine Avenue",
                city: "Lake Oswego",
                state: "OR",
                zipCode: "97034",
                customerType: .commercial,
                referralSource: "Referral from John Smith"
            )
        ]
        
        customers = sampleCustomers
        saveCustomers()
    }
}