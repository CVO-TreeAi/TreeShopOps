import SwiftUI

// MARK: - Shared State Container
class AppStateManager: ObservableObject {
    @Published var leadManager = LeadManager()
    @Published var proposalManager = ProposalManager()
    @Published var workOrderManager = WorkOrderManager()
    @Published var invoiceManager = InvoiceManager()
    @Published var customerManager = CustomerManager()
    @Published var pricingModel = PricingModel()
    @Published var equipmentManager = EquipmentManager()
    @Published var employeeManager = EmployeeManager()
    @Published var loadoutManager = LoadoutManager()
    
    
}

struct MainTabView: View {
    @StateObject private var appState = AppStateManager()
    
    var body: some View {
        TabView {
            // Dashboard Tab (Home)
            NavigationView {
                DashboardView()
                    .environmentObject(appState.leadManager)
                    .environmentObject(appState.proposalManager)
                    .environmentObject(appState.workOrderManager)
                    .environmentObject(appState.invoiceManager)
                    .environmentObject(appState.customerManager)
            }
            .tabItem {
                Label("Dashboard", systemImage: "house")
            }
            
            // Pipeline Tab
            NavigationView {
                PipelineView()
                    .environmentObject(appState.leadManager)
                    .environmentObject(appState.proposalManager)
                    .environmentObject(appState.workOrderManager)
                    .environmentObject(appState.invoiceManager)
                    .environmentObject(appState.customerManager)
            }
            .tabItem {
                Label("Pipeline", systemImage: "arrow.right.circle")
            }
            
            // Pricing Tab
            NavigationView {
                ContentView()
                    .environmentObject(appState.pricingModel)
                    .environmentObject(appState.proposalManager)
                    .environmentObject(appState.customerManager)
            }
            .tabItem {
                Label("Pricing", systemImage: "calculator")
            }
            
            // Customers Tab
            NavigationView {
                CustomerListView()
                    .environmentObject(appState.customerManager)
            }
            .tabItem {
                Label("Customers", systemImage: "person.2.fill")
            }
            
            // Menu Tab
            NavigationView {
                MenuView(pricingModel: appState.pricingModel)
                    .environmentObject(appState.equipmentManager)
                    .environmentObject(appState.employeeManager)
                    .environmentObject(appState.loadoutManager)
            }
            .tabItem {
                Label("Menu", systemImage: "ellipsis")
            }
        }
        .environmentObject(appState)
        .accentColor(Color("TreeShopGreen"))
        .preferredColorScheme(.dark)
    }
}

#Preview {
    MainTabView()
}