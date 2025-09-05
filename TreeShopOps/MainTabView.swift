import SwiftUI

struct MainTabView: View {
    @StateObject private var leadManager = LeadManager()
    @StateObject private var proposalManager = ProposalManager()
    @StateObject private var workOrderManager = WorkOrderManager()
    @StateObject private var invoiceManager = InvoiceManager()
    @StateObject private var customerManager = CustomerManager()
    @StateObject private var pricingModel = PricingModel()
    
    var body: some View {
        TabView {
            // Leads Tab
            NavigationView {
                LeadListView()
                    .environmentObject(leadManager)
                    .environmentObject(proposalManager)
                    .environmentObject(customerManager)
            }
            .tabItem {
                Label("Leads", systemImage: "person.crop.circle.badge.plus")
            }
            
            // Proposals Tab
            NavigationView {
                ProposalListView()
                    .environmentObject(proposalManager)
                    .environmentObject(leadManager)
                    .environmentObject(workOrderManager)
                    .environmentObject(customerManager)
            }
            .tabItem {
                Label("Proposals", systemImage: "doc.text.fill")
            }
            
            // Work Orders Tab
            NavigationView {
                WorkOrderListView()
                    .environmentObject(workOrderManager)
                    .environmentObject(proposalManager)
                    .environmentObject(invoiceManager)
                    .environmentObject(customerManager)
            }
            .tabItem {
                Label("Work Orders", systemImage: "hammer.fill")
            }
            
            // Invoices Tab
            NavigationView {
                InvoiceListView()
                    .environmentObject(invoiceManager)
                    .environmentObject(workOrderManager)
                    .environmentObject(customerManager)
            }
            .tabItem {
                Label("Invoices", systemImage: "dollarsign.square.fill")
            }
            
            // Customers Tab
            NavigationView {
                CustomerListView()
                    .environmentObject(customerManager)
                    .environmentObject(leadManager)
                    .environmentObject(proposalManager)
                    .environmentObject(workOrderManager)
                    .environmentObject(invoiceManager)
            }
            .tabItem {
                Label("Customers", systemImage: "person.2.fill")
            }
            
            // Menu Tab
            NavigationView {
                MenuView(pricingModel: pricingModel)
                    .environmentObject(leadManager)
                    .environmentObject(proposalManager)
                    .environmentObject(workOrderManager)
                    .environmentObject(invoiceManager)
            }
            .tabItem {
                Label("Menu", systemImage: "line.3.horizontal.circle.fill")
            }
        }
        .accentColor(Color("TreeShopGreen"))
        .preferredColorScheme(.dark)
    }
}

#Preview {
    MainTabView()
}