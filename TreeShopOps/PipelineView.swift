import SwiftUI

struct PipelineView: View {
    @EnvironmentObject var appState: AppStateManager
    
    // Computed properties for better performance  
    private var leadManager: LeadManager { appState.leadManager }
    private var proposalManager: ProposalManager { appState.proposalManager }
    private var workOrderManager: WorkOrderManager { appState.workOrderManager }
    private var customerManager: CustomerManager { appState.customerManager }
    
    @State private var selectedPipelineTab = 0
    private let pipelineTabs = ["Website", "Leads", "Proposals", "Work Orders"]
    
    var body: some View {
        VStack(spacing: 0) {
            // Pipeline tab picker
            pipelineTabPicker
            
            // Content based on selected tab
            Group {
                switch selectedPipelineTab {
                case 0:
                    WebsiteLeadListView()
                        .environmentObject(appState)
                case 1:
                    LeadListView()
                        .environmentObject(appState)
                case 2:
                    ProposalListView()
                        .environmentObject(appState)
                case 3:
                    WorkOrderListView()
                        .environmentObject(appState)
                default:
                    EmptyView()
                }
            }
            .navigationBarHidden(true)
        }
        .navigationTitle("Pipeline")
        .navigationBarTitleDisplayMode(.large)
    }
    
    private var pipelineTabPicker: some View {
        VStack(spacing: 0) {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 0) {
                    ForEach(0..<pipelineTabs.count, id: \.self) { index in
                        Button(action: {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                selectedPipelineTab = index
                            }
                        }) {
                            VStack(spacing: 8) {
                                Text(pipelineTabs[index])
                                    .font(.headline)
                                    .fontWeight(.semibold)
                                    .foregroundColor(selectedPipelineTab == index ? Color("TreeShopGreen") : .gray)
                                
                                Rectangle()
                                    .fill(selectedPipelineTab == index ? Color("TreeShopGreen") : Color.clear)
                                    .frame(height: 3)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                    }
                }
            }
            .background(Color("TreeShopBlack"))
            
            Divider()
                .background(Color.white.opacity(0.1))
        }
    }
}

#Preview {
    NavigationView {
        PipelineView()
            .environmentObject(LeadManager())
            .environmentObject(ProposalManager())
            .environmentObject(WorkOrderManager())
            .environmentObject(CustomerManager())
    }
}