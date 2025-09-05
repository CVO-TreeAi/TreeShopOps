import SwiftUI

struct WorkOrderDetailView: View {
    @EnvironmentObject var workOrderManager: WorkOrderManager
    @Environment(\.presentationMode) var presentationMode
    
    @State var workOrder: WorkOrder
    @State private var showingEditWorkOrder = false
    @State private var showingDeleteAlert = false
    @State private var showingStatusUpdate = false
    @State private var showingConvertToInvoice = false
    
    var body: some View {
        NavigationView {
            ZStack {
                Color("TreeShopBlack").ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 20) {
                        // Header card
                        headerCard
                        
                        // Project information
                        projectCard
                        
                        // Schedule and crew
                        scheduleCard
                        
                        // Progress tracking
                        if workOrder.status == .inProgress || workOrder.status == .completed {
                            progressCard
                        }
                        
                        // Financial details
                        financialCard
                        
                        // Action buttons
                        actionButtons
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 100)
                }
            }
            .navigationTitle("Work Order Details")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(
                leading: Button("Close") {
                    presentationMode.wrappedValue.dismiss()
                }
                .foregroundColor(.white),
                
                trailing: Menu {
                    Button(action: {
                        showingEditWorkOrder = true
                    }) {
                        Label("Edit", systemImage: "pencil")
                    }
                    
                    Button(action: {
                        showingStatusUpdate = true
                    }) {
                        Label("Update Status", systemImage: "arrow.clockwise")
                    }
                    
                    if workOrder.status == .completed {
                        Button(action: {
                            showingConvertToInvoice = true
                        }) {
                            Label("Convert to Invoice", systemImage: "dollarsign.square")
                        }
                    }
                    
                    Button(role: .destructive, action: {
                        showingDeleteAlert = true
                    }) {
                        Label("Delete", systemImage: "trash")
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                        .foregroundColor(Color("TreeShopGreen"))
                }
            )
        }
        .sheet(isPresented: $showingEditWorkOrder) {
            AddEditWorkOrderView(workOrder: workOrder)
                .environmentObject(workOrderManager)
                .onDisappear {
                    if let updated = workOrderManager.getWorkOrder(by: workOrder.id) {
                        workOrder = updated
                    }
                }
        }
        .confirmationDialog("Update Status", isPresented: $showingStatusUpdate) {
            ForEach(WorkOrderStatus.allCases, id: \.self) { status in
                Button(status.rawValue) {
                    updateWorkOrderStatus(status)
                }
            }
            Button("Cancel", role: .cancel) { }
        }
        .alert("Convert to Invoice", isPresented: $showingConvertToInvoice) {
            Button("Cancel", role: .cancel) { }
            Button("Convert") {
                convertToInvoice()
            }
        } message: {
            Text("This will create a new invoice from this completed work order.")
        }
        .alert("Delete Work Order", isPresented: $showingDeleteAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                workOrderManager.deleteWorkOrder(workOrder)
                presentationMode.wrappedValue.dismiss()
            }
        } message: {
            Text("Are you sure you want to delete this work order? This action cannot be undone.")
        }
    }
    
    private var headerCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 8) {
                    Text(workOrder.workOrderNumber)
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    Text(workOrder.customerName)
                        .font(.headline)
                        .foregroundColor(.gray)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 8) {
                    // Status badge
                    HStack(spacing: 6) {
                        Image(systemName: workOrder.status.systemImage)
                            .font(.caption)
                        Text(workOrder.status.rawValue)
                            .font(.caption)
                            .fontWeight(.semibold)
                    }
                    .foregroundColor(workOrder.status.color)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(workOrder.status.color.opacity(0.2))
                    )
                    
                    // Amount
                    Text("$\(String(format: "%.2f", workOrder.finalAmount))")
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(Color("TreeShopGreen"))
                }
            }
            
            if workOrder.isOverdue {
                HStack {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundColor(.red)
                    Text("Project Overdue")
                        .font(.subheadline)
                        .foregroundColor(.red)
                }
                .padding(12)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.red.opacity(0.1))
                        .stroke(Color.red.opacity(0.3), lineWidth: 1)
                )
            }
        }
        .cardStyle()
    }
    
    private var projectCard: some View {
        DetailCard(title: "Project Details", icon: "leaf.fill") {
            VStack(alignment: .leading, spacing: 12) {
                if !workOrder.projectTitle.isEmpty {
                    WorkOrderDetailRow(title: "Title", value: workOrder.projectTitle)
                }
                if !workOrder.projectLocation.isEmpty {
                    WorkOrderDetailRow(title: "Location", value: workOrder.projectLocation)
                }
                if !workOrder.projectDescription.isEmpty {
                    WorkOrderDetailRow(title: "Description", value: workOrder.projectDescription)
                }
                if workOrder.landSize > 0 {
                    WorkOrderDetailRow(title: "Land Size", value: String(format: "%.1f acres", workOrder.landSize))
                }
                WorkOrderDetailRow(title: "Package Type", value: workOrder.packageType.capitalized)
            }
        }
    }
    
    private var scheduleCard: some View {
        DetailCard(title: "Schedule & Crew", icon: "calendar.badge.clock") {
            VStack(alignment: .leading, spacing: 12) {
                if let startDate = workOrder.scheduledStartDate {
                    WorkOrderDetailRow(title: "Scheduled Start", value: startDate.formatted(date: .long, time: .omitted))
                }
                if let endDate = workOrder.scheduledEndDate {
                    WorkOrderDetailRow(title: "Scheduled End", value: endDate.formatted(date: .long, time: .omitted))
                }
                
                if !workOrder.crewAssigned.isEmpty {
                    WorkOrderDetailRow(title: "Crew", value: workOrder.crewAssigned.joined(separator: ", "))
                }
                
                if !workOrder.equipmentUsed.isEmpty {
                    WorkOrderDetailRow(title: "Equipment", value: workOrder.equipmentUsed.joined(separator: ", "))
                }
            }
        }
    }
    
    private var progressCard: some View {
        DetailCard(title: "Progress", icon: "chart.pie.fill") {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text("Completion")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.gray)
                    
                    Spacer()
                    
                    Text(String(format: "%.0f%%", workOrder.completionPercentage * 100))
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(Color("TreeShopGreen"))
                }
                
                ProgressView(value: workOrder.completionPercentage)
                    .progressViewStyle(LinearProgressViewStyle(tint: Color("TreeShopGreen")))
                
                if workOrder.hoursWorked > 0 {
                    WorkOrderDetailRow(title: "Hours Worked", value: String(format: "%.1f hours", workOrder.hoursWorked))
                }
                
                if !workOrder.workNotes.isEmpty {
                    WorkOrderDetailRow(title: "Work Notes", value: workOrder.workNotes)
                }
                
                if !workOrder.safetyNotes.isEmpty {
                    WorkOrderDetailRow(title: "Safety Notes", value: workOrder.safetyNotes)
                }
            }
        }
    }
    
    private var financialCard: some View {
        DetailCard(title: "Financial", icon: "dollarsign.circle.fill") {
            VStack(spacing: 12) {
                WorkOrderPricingRow(title: "Original Amount", amount: workOrder.originalAmount)
                
                if workOrder.additionalCosts > 0 {
                    WorkOrderPricingRow(title: "Additional Costs", amount: workOrder.additionalCosts)
                    
                    Divider()
                        .background(Color.white.opacity(0.3))
                }
                
                WorkOrderPricingRow(title: "Total", amount: workOrder.finalAmount, isTotal: true)
            }
        }
    }
    
    private var actionButtons: some View {
        VStack(spacing: 12) {
            if workOrder.status == .scheduled {
                Button(action: {
                    updateWorkOrderStatus(.inProgress)
                }) {
                    HStack {
                        Image(systemName: "play.circle.fill")
                        Text("Start Work")
                    }
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(Color("TreeShopGreen"))
                    .cornerRadius(12)
                }
            } else if workOrder.status == .inProgress {
                Button(action: {
                    updateWorkOrderStatus(.completed)
                }) {
                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                        Text("Mark Complete")
                    }
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(Color("TreeShopGreen"))
                    .cornerRadius(12)
                }
            } else if workOrder.status == .completed {
                Button(action: {
                    showingConvertToInvoice = true
                }) {
                    HStack {
                        Image(systemName: "dollarsign.square.fill")
                        Text("Create Invoice")
                    }
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(Color("TreeShopGreen"))
                    .cornerRadius(12)
                }
            }
            
            Button(action: {
                showingEditWorkOrder = true
            }) {
                HStack {
                    Image(systemName: "pencil")
                    Text("Edit Work Order")
                }
                .font(.headline)
                .foregroundColor(Color("TreeShopGreen"))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color("TreeShopGreen"), lineWidth: 2)
                )
            }
        }
        .padding(.top, 10)
    }
    
    private func updateWorkOrderStatus(_ status: WorkOrderStatus) {
        workOrder.status = status
        workOrder.dateUpdated = Date()
        
        if status == .inProgress && workOrder.actualStartDate == nil {
            workOrder.actualStartDate = Date()
        } else if status == .completed {
            workOrder.actualEndDate = Date()
            workOrder.completionPercentage = 1.0
        }
        
        workOrderManager.updateWorkOrder(workOrder)
    }
    
    private func convertToInvoice() {
        // This will be implemented when we integrate with InvoiceManager
        presentationMode.wrappedValue.dismiss()
    }
}

struct WorkOrderDetailRow: View {
    let title: String
    let value: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(.gray)
            Text(value.isEmpty ? "Not specified" : value)
                .font(.body)
                .foregroundColor(value.isEmpty ? .gray : .white)
        }
    }
}

struct WorkOrderPricingRow: View {
    let title: String
    let amount: Double
    let isTotal: Bool
    
    init(title: String, amount: Double, isTotal: Bool = false) {
        self.title = title
        self.amount = amount
        self.isTotal = isTotal
    }
    
    var body: some View {
        HStack {
            Text(title)
                .font(isTotal ? .headline : .body)
                .fontWeight(isTotal ? .bold : .regular)
                .foregroundColor(.white)
            
            Spacer()
            
            Text("$\(String(format: "%.2f", amount))")
                .font(isTotal ? .headline : .body)
                .fontWeight(isTotal ? .bold : .semibold)
                .foregroundColor(isTotal ? Color("TreeShopGreen") : .white)
        }
        .padding(isTotal ? 12 : 0)
        .background(
            isTotal ? 
            RoundedRectangle(cornerRadius: 8)
                .fill(Color("TreeShopGreen").opacity(0.1))
                .stroke(Color("TreeShopGreen").opacity(0.3), lineWidth: 1)
            : nil
        )
    }
}

#Preview {
    WorkOrderDetailView(workOrder: WorkOrder(
        workOrderNumber: "WO-12345",
        customerName: "John Doe",
        projectTitle: "5 Acre Land Clearing",
        landSize: 5.0,
        originalAmount: 12500.0
    ))
    .environmentObject(WorkOrderManager())
}