import Foundation
import Combine

// MARK: - Environment Configuration

enum TreeShopEnvironment {
    case development
    case production
    
    var convexURL: String {
        switch self {
        case .development:
            return "https://content-lynx-725.convex.cloud"
        case .production:
            return "https://earnest-lemming-634.convex.cloud"
        }
    }
}

// MARK: - API Service

class TreeShopAPIService: ObservableObject {
    private var convexURL: String
    private let session = URLSession.shared
    private var cancellables = Set<AnyCancellable>()
    
    @Published var isConnected = false
    @Published var lastSyncTime: Date?
    
    init(environment: TreeShopEnvironment = .development) {
        self.convexURL = environment.convexURL
    }
    
    init(customURL: String) {
        self.convexURL = customURL
    }
    
    func updateConvexURL(_ url: String) {
        self.convexURL = url
        self.isConnected = false
        self.lastSyncTime = nil
    }
    
    // MARK: - Lead API Methods
    
    func fetchLeads() async throws -> [WebsiteLead] {
        let url = URL(string: "\(convexURL)/api/query")!
        var request = URLRequest(url: url)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let queryBody: [String: Any] = [
            "query": "leads.list",
            "args": [:]
        ]
        
        print("🌐 Fetching from: \(url.absoluteString)")
        print("📤 Request body: \(queryBody)")
        
        request.httpMethod = "POST"
        request.httpBody = try JSONSerialization.data(withJSONObject: queryBody)
        
        let (data, response) = try await session.data(for: request)
        
        print("📥 Response status: \((response as? HTTPURLResponse)?.statusCode ?? -1)")
        print("📥 Response data: \(String(data: data, encoding: .utf8) ?? "nil")")
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            print("❌ Invalid response: \(response)")
            throw APIError.invalidResponse
        }
        
        let apiResponse = try JSONDecoder().decode(ConvexResponse<[WebsiteLead]>.self, from: data)
        lastSyncTime = Date()
        isConnected = true
        
        print("✅ Decoded \(apiResponse.result.count) leads successfully")
        return apiResponse.result
    }
    
    func updateLeadStatus(leadId: String, status: WebsiteLeadStatus, notes: String? = nil) async throws {
        let url = URL(string: "\(convexURL)/api/mutation")!
        var request = URLRequest(url: url)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let mutationBody: [String: Any] = [
            "mutation": "leads.updateStatus",
            "args": [
                "id": leadId,
                "status": status.rawValue,
                "notes": notes ?? ""
            ]
        ]
        
        request.httpMethod = "POST"
        request.httpBody = try JSONSerialization.data(withJSONObject: mutationBody)
        
        let (_, response) = try await session.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw APIError.updateFailed
        }
    }
    
    func validateLead(leadId: String, wetlandsChecked: Bool, siteMapUrl: String? = nil, parcelId: String? = nil) async throws {
        let url = URL(string: "\(convexURL)/api/mutation")!
        var request = URLRequest(url: url)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let mutationBody: [String: Any] = [
            "mutation": "leads.validate",
            "args": [
                "id": leadId,
                "wetlandsChecked": wetlandsChecked,
                "siteMapUrl": siteMapUrl ?? "",
                "parcelId": parcelId ?? ""
            ]
        ]
        
        request.httpMethod = "POST"
        request.httpBody = try JSONSerialization.data(withJSONObject: mutationBody)
        
        let (_, response) = try await session.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw APIError.validationFailed
        }
    }
    
    // MARK: - Real-time Sync
    
    func startLeadSync() -> AnyPublisher<[WebsiteLead], Never> {
        Timer.publish(every: 30, on: .main, in: .common)
            .autoconnect()
            .flatMap { _ in
                Future<[WebsiteLead], Never> { promise in
                    Task {
                        do {
                            let leads = try await self.fetchLeads()
                            promise(.success(leads))
                        } catch {
                            print("Lead sync error: \(error)")
                            promise(.success([]))
                        }
                    }
                }
            }
            .eraseToAnyPublisher()
    }
}

// MARK: - Data Models

struct WebsiteLead: Identifiable, Codable {
    let id: String
    let name: String
    let email: String
    let phone: String
    let propertyAddress: String
    let source: WebsiteLeadSource
    let status: WebsiteLeadStatus
    let createdAt: Double
    let updatedAt: Double
    
    // Business Fields
    let packageType: WebsitePackageType
    let instantQuote: Double
    let estimatedAcreage: Double?
    
    // Optional Fields
    let additionalDetails: String?
    let assignedTo: String?
    
    // Follow-up & Validation
    let followedUpAt: Double?
    let validatedAt: Double?
    let wetlandsChecked: Bool?
    let siteMapUrl: String?
    let parcelId: String?
    
    var createdDate: Date {
        Date(timeIntervalSince1970: createdAt / 1000)
    }
    
    var updatedDate: Date {
        Date(timeIntervalSince1970: updatedAt / 1000)
    }
    
    var followUpDate: Date? {
        guard let timestamp = followedUpAt else { return nil }
        return Date(timeIntervalSince1970: timestamp / 1000)
    }
    
    var validationDate: Date? {
        guard let timestamp = validatedAt else { return nil }
        return Date(timeIntervalSince1970: timestamp / 1000)
    }
}

enum WebsiteLeadSource: String, Codable, CaseIterable {
    case treeshopApp = "treeshop.app"
    case fltreeshopCom = "fltreeshop.com"
    case social = "social"
    case youtube = "youtube"
    case referral = "referral"
    case phone = "phone"
    case walkIn = "walk-in"
    
    var displayName: String {
        switch self {
        case .treeshopApp: return "TreeShop App"
        case .fltreeshopCom: return "FL TreeShop Website"
        case .social: return "Social Media"
        case .youtube: return "YouTube"
        case .referral: return "Referral"
        case .phone: return "Phone Call"
        case .walkIn: return "Walk-in"
        }
    }
    
    var systemImage: String {
        switch self {
        case .treeshopApp: return "iphone"
        case .fltreeshopCom: return "globe"
        case .social: return "person.2.fill"
        case .youtube: return "play.rectangle.fill"
        case .referral: return "person.badge.plus"
        case .phone: return "phone.fill"
        case .walkIn: return "building.2.fill"
        }
    }
}

enum WebsiteLeadStatus: String, Codable, CaseIterable {
    case new = "new"
    case contacted = "contacted"
    case validated = "validated"
    case quoted = "quoted"
    case accepted = "accepted"
    case rejected = "rejected"
    case lost = "lost"
    
    var color: Color {
        switch self {
        case .new: return Color("TreeShopBlue")
        case .contacted: return .orange
        case .validated: return .purple
        case .quoted: return .yellow
        case .accepted: return Color("TreeShopGreen")
        case .rejected: return .red
        case .lost: return .gray
        }
    }
    
    var systemImage: String {
        switch self {
        case .new: return "star.fill"
        case .contacted: return "phone.fill"
        case .validated: return "checkmark.shield.fill"
        case .quoted: return "doc.text.fill"
        case .accepted: return "checkmark.circle.fill"
        case .rejected: return "xmark.circle.fill"
        case .lost: return "exclamationmark.triangle.fill"
        }
    }
}

enum WebsitePackageType: String, Codable, CaseIterable {
    case small = "Small"
    case medium = "Medium"
    case large = "Large"
    case xLarge = "X-Large"
    case max = "Max"
    
    var description: String {
        switch self {
        case .small: return "Small (4\" DBH)"
        case .medium: return "Medium (6\" DBH)"
        case .large: return "Large (8\" DBH)"
        case .xLarge: return "X-Large (10\" DBH)"
        case .max: return "Max Density"
        }
    }
}

// MARK: - API Response Models

struct ConvexResponse<T: Codable>: Codable {
    let result: T
}

enum APIError: Error, LocalizedError {
    case invalidResponse
    case updateFailed
    case validationFailed
    case networkError
    
    var errorDescription: String? {
        switch self {
        case .invalidResponse: return "Invalid response from server"
        case .updateFailed: return "Failed to update lead"
        case .validationFailed: return "Failed to validate lead"
        case .networkError: return "Network connection error"
        }
    }
}

// MARK: - Lead Sync Manager

@MainActor
class WebsiteLeadSyncManager: ObservableObject {
    @Published var websiteLeads: [WebsiteLead] = []
    @Published var isSyncing = false
    @Published var syncError: String?
    
    let apiService: TreeShopAPIService
    private var syncCancellable: AnyCancellable?
    private let businessConfig: BusinessConfigManager
    
    init(businessConfig: BusinessConfigManager = BusinessConfigManager()) {
        self.businessConfig = businessConfig
        
        if businessConfig.config.convexEnabled && !businessConfig.config.convexURL.isEmpty {
            self.apiService = TreeShopAPIService(customURL: businessConfig.config.convexURL)
        } else {
            self.apiService = TreeShopAPIService()
        }
    }
    
    func startSync() {
        // Immediate sync on startup
        Task {
            await manualSync()
        }
        
        // Only start periodic sync if Convex is enabled
        guard businessConfig.config.convexEnabled else {
            syncError = "Website integration disabled. Enable in Business Configuration."
            return
        }
        
        syncCancellable = apiService.startLeadSync()
            .sink(receiveValue: { [weak self] leads in
                self?.websiteLeads = leads
                self?.isSyncing = false
                self?.syncError = nil
            })
    }
    
    func stopSync() {
        syncCancellable?.cancel()
        syncCancellable = nil
    }
    
    func manualSync() async {
        // Only sync if Convex is enabled
        guard businessConfig.config.convexEnabled else {
            syncError = "Website integration disabled. Enable in Business Configuration."
            return
        }
        
        isSyncing = true
        syncError = nil
        
        print("🔄 Starting manual sync from: \(businessConfig.config.convexURL)")
        
        do {
            let leads = try await apiService.fetchLeads()
            print("✅ Fetched \(leads.count) website leads")
            self.websiteLeads = leads
            self.isSyncing = false
        } catch {
            print("❌ Sync error: \(error)")
            self.syncError = error.localizedDescription
            self.isSyncing = false
        }
    }
    
    func updateLeadStatus(_ leadId: String, status: WebsiteLeadStatus, notes: String = "") async {
        do {
            try await apiService.updateLeadStatus(leadId: leadId, status: status, notes: notes)
            await manualSync() // Refresh after update
        } catch {
            self.syncError = "Failed to update lead: \(error.localizedDescription)"
        }
    }
    
    func validateLead(_ leadId: String, wetlandsChecked: Bool, siteMapUrl: String = "", parcelId: String = "") async {
        do {
            try await apiService.validateLead(leadId: leadId, wetlandsChecked: wetlandsChecked, siteMapUrl: siteMapUrl, parcelId: parcelId)
            await manualSync() // Refresh after validation
        } catch {
            self.syncError = "Failed to validate lead: \(error.localizedDescription)"
        }
    }
    
    func convertToLocalLead(_ websiteLead: WebsiteLead) -> Lead {
        return Lead(
            customerFirstName: extractFirstName(from: websiteLead.name),
            customerLastName: extractLastName(from: websiteLead.name),
            customerEmail: websiteLead.email,
            customerPhone: websiteLead.phone,
            customerAddress: websiteLead.propertyAddress,
            customerCity: "",
            customerState: "",
            customerZipCode: "",
            projectDescription: websiteLead.additionalDetails ?? "",
            landSize: websiteLead.estimatedAcreage ?? 0.0,
            projectLocation: websiteLead.propertyAddress,
            urgency: .normal,
            leadSource: convertSource(websiteLead.source),
            estimatedValue: websiteLead.instantQuote,
            notes: websiteLead.additionalDetails ?? ""
        )
    }
    
    private func extractFirstName(from fullName: String) -> String {
        let components = fullName.split(separator: " ")
        return String(components.first ?? "")
    }
    
    private func extractLastName(from fullName: String) -> String {
        let components = fullName.split(separator: " ")
        return components.dropFirst().joined(separator: " ")
    }
    
    private func convertSource(_ source: WebsiteLeadSource) -> LeadSource {
        switch source {
        case .treeshopApp, .fltreeshopCom: return .website
        case .social: return .referral
        case .youtube: return .other
        case .referral: return .referral
        case .phone: return .phone
        case .walkIn: return .walkIn
        }
    }
}

import SwiftUI