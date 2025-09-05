import SwiftUI

struct WorkOrderListView: View {
    @EnvironmentObject var workOrderManager: WorkOrderManager
    @State private var searchText = ""
    @State private var selectedStatus: WorkOrderStatus? = nil
    @State private var showingAddWorkOrder = false
    @State private var selectedWorkOrder: WorkOrder? = nil
    @State private var showingWorkOrderDetail = false
    
    var filteredWorkOrders: [WorkOrder] {
        var workOrders = workOrderManager.searchWorkOrders(searchText)
        
        if let status = selectedStatus {
            workOrders = workOrders.filter { $0.status == status }
        }
        
        return workOrders.sorted { $0.dateUpdated > $1.dateUpdated }
    }
    
    var body: some View {
        ZStack {
            Color("TreeShopBlack").ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header with stats
                headerSection
                
                // Status filter chips
                statusFilterSection
                
                // Work orders list
                workOrdersList
            }
        }
        .navigationTitle("Work Orders")
        .navigationBarTitleDisplayMode(.large)
        .navigationBarItems(
            trailing: Button(action: {
                showingAddWorkOrder = true
            }) {
                Image(systemName: "plus.circle.fill")
                    .font(.title2)
                    .foregroundColor(Color("TreeShopGreen"))
            }
        )
        .sheet(isPresented: $showingAddWorkOrder) {
            AddEditWorkOrderView()
                .environmentObject(workOrderManager)
        }
        .sheet(isPresented: $showingWorkOrderDetail) {
            if let workOrder = selectedWorkOrder {
                WorkOrderDetailView(workOrder: workOrder)
                    .environmentObject(workOrderManager)
            }
        }
        .searchable(text: $searchText, prompt: "Search work orders...")
    }
    
    private var headerSection: some View {
        VStack(spacing: 16) {
            // Stats cards
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: 3), spacing: 12) {
                StandardStatCard(
                    title: "Scheduled",
                    value: "\(workOrderManager.getWorkOrdersByStatus(.scheduled).count)",
                    icon: "calendar",
                    color: Color("TreeShopBlue")
                )
                
                StandardStatCard(
                    title: "In Progress",
                    value: "\(workOrderManager.getWorkOrdersByStatus(.inProgress).count)",
                    icon: "gearshape.2",
                    color: .orange
                )
                
                StandardStatCard(
                    title: "Completed",
                    value: "\(workOrderManager.getWorkOrdersByStatus(.completed).count)",
                    icon: "checkmark.circle",
                    color: Color("TreeShopGreen")
                )
            }
            .padding(.horizontal, 20)
        }
        .padding(.top, 20)
    }
    
    private var statusFilterSection: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                WorkOrderFilterChip(
                    title: "All",
                    isSelected: selectedStatus == nil
                ) {
                    selectedStatus = nil
                }
                
                ForEach(WorkOrderStatus.allCases, id: \.self) { status in
                    WorkOrderFilterChip(
                        title: status.rawValue,
                        isSelected: selectedStatus == status,
                        color: status.color
                    ) {
                        selectedStatus = selectedStatus == status ? nil : status
                    }
                }
            }
            .padding(.horizontal, 20)
        }
        .padding(.vertical, 16)
    }
    
    private var workOrdersList: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                if filteredWorkOrders.isEmpty {
                    emptyStateView
                } else {
                    ForEach(filteredWorkOrders) { workOrder in
                        WorkOrderRowView(workOrder: workOrder) {
                            selectedWorkOrder = workOrder
                            showingWorkOrderDetail = true
                        }
                        .contextMenu {
                            Button(action: {
                                selectedWorkOrder = workOrder
                                showingAddWorkOrder = true
                            }) {
                                Label("Edit", systemImage: "pencil")
                            }
                            
                            if workOrder.status == .completed {
                                Button(action: {
                                    // Convert to invoice
                                }) {
                                    Label("Convert to Invoice", systemImage: "dollarsign.square")
                                }
                            }
                            
                            Button(role: .destructive, action: {
                                withAnimation(.spring()) {
                                    workOrderManager.deleteWorkOrder(workOrder)
                                }
                            }) {
                                Label("Delete", systemImage: "trash")
                            }
                        }
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 100)
        }
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: "hammer.fill")
                .font(.system(size: 60))
                .foregroundColor(.gray)
            
            VStack(spacing: 8) {
                Text("No Work Orders Found")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                
                Text(searchText.isEmpty ? "Create your first work order to start tracking projects" : "No work orders match your search")
                    .font(.body)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
            }
            
            if searchText.isEmpty {
                Button(action: {
                    showingAddWorkOrder = true
                }) {
                    HStack {
                        Image(systemName: "plus.circle.fill")
                        Text("Create Work Order")
                    }
                    .font(.headline)
                    .foregroundColor(.black)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                    .background(Color("TreeShopGreen"))
                    .cornerRadius(12)
                }
            }
        }
        .padding(.vertical, 60)
    }
}

struct WorkOrderStatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title)
                .foregroundColor(color)
            
            VStack(spacing: 4) {
                Text(value)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                Text(title)
                    .font(.caption)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
            }
        }
        .frame(maxWidth: .infinity)
        .frame(height: 100)
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white.opacity(0.05))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(color.opacity(0.2), lineWidth: 1)
                )
        )
    }
}

struct WorkOrderFilterChip: View {
    let title: String
    let isSelected: Bool
    let color: Color
    let action: () -> Void
    
    init(title: String, isSelected: Bool, color: Color = Color("TreeShopGreen"), action: @escaping () -> Void) {
        self.title = title
        self.isSelected = isSelected
        self.color = color
        self.action = action
    }
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(isSelected ? .white : .gray)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(isSelected ? color : Color.white.opacity(0.1))
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(isSelected ? color : Color.white.opacity(0.2), lineWidth: 1)
                        )
                )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct WorkOrderRowView: View {
    let workOrder: WorkOrder
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 12) {
                // Header row
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(workOrder.workOrderNumber)
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                        
                        Text(workOrder.customerName)
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing, spacing: 4) {
                        // Status badge
                        HStack(spacing: 4) {
                            Image(systemName: workOrder.status.systemImage)
                                .font(.caption)
                            Text(workOrder.status.rawValue)
                                .font(.caption)
                                .fontWeight(.medium)
                        }
                        .foregroundColor(workOrder.status.color)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(
                            RoundedRectangle(cornerRadius: 6)
                                .fill(workOrder.status.color.opacity(0.2))
                        )
                        
                        // Amount
                        Text("$\(String(format: "%.2f", workOrder.finalAmount))")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(Color("TreeShopGreen"))
                    }
                }
                
                // Details row
                HStack {
                    if let startDate = workOrder.scheduledStartDate {
                        Label(startDate.formatted(date: .abbreviated, time: .omitted), 
                              systemImage: "calendar")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    
                    if workOrder.landSize > 0 {
                        Label(String(format: "%.1f acres", workOrder.landSize), 
                              systemImage: "leaf.fill")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    
                    Spacer()
                    
                    if workOrder.isOverdue {
                        Label("Overdue", systemImage: "exclamationmark.triangle.fill")
                            .font(.caption)
                            .foregroundColor(.red)
                    } else if workOrder.completionPercentage > 0 {
                        Label(String(format: "%.0f%% complete", workOrder.completionPercentage * 100), 
                              systemImage: "chart.pie.fill")
                            .font(.caption)
                            .foregroundColor(.orange)
                    }
                }
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.white.opacity(0.05))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(workOrder.isOverdue ? Color.red.opacity(0.5) : Color.white.opacity(0.1), lineWidth: workOrder.isOverdue ? 2 : 1)
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    NavigationView {
        WorkOrderListView()
            .environmentObject(WorkOrderManager())
    }
}