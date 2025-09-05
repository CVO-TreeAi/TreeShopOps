import SwiftUI

struct AddEditWorkOrderView: View {
    @EnvironmentObject var workOrderManager: WorkOrderManager
    @Environment(\.presentationMode) var presentationMode
    
    @State private var workOrder: WorkOrder
    @State private var isEditing: Bool
    
    // Form sections
    @State private var selectedSection = 0
    private let sections = ["Project", "Schedule", "Crew", "Progress"]
    
    init(workOrder: WorkOrder? = nil) {
        if let existingWorkOrder = workOrder {
            _workOrder = State(initialValue: existingWorkOrder)
            _isEditing = State(initialValue: true)
        } else {
            _workOrder = State(initialValue: WorkOrder())
            _isEditing = State(initialValue: false)
        }
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                Color("TreeShopBlack").ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Section picker
                    sectionPicker
                    
                    // Form content
                    ScrollView {
                        VStack(spacing: 20) {
                            switch selectedSection {
                            case 0:
                                projectSection
                            case 1:
                                scheduleSection
                            case 2:
                                crewSection
                            case 3:
                                progressSection
                            default:
                                EmptyView()
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.bottom, 100)
                    }
                    .onTapGesture {
                        hideKeyboard()
                    }
                }
            }
            .navigationTitle(isEditing ? "Edit Work Order" : "New Work Order")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(
                leading: Button("Cancel") {
                    presentationMode.wrappedValue.dismiss()
                }
                .foregroundColor(.white),
                
                trailing: Button("Save") {
                    saveWorkOrder()
                }
                .foregroundColor(Color("TreeShopGreen"))
                .fontWeight(.semibold)
            )
        }
    }
    
    private var sectionPicker: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 16) {
                ForEach(0..<sections.count, id: \.self) { index in
                    Button(action: {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            selectedSection = index
                        }
                    }) {
                        VStack(spacing: 4) {
                            Text(sections[index])
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundColor(selectedSection == index ? Color("TreeShopGreen") : .gray)
                            
                            Rectangle()
                                .fill(selectedSection == index ? Color("TreeShopGreen") : Color.clear)
                                .frame(height: 2)
                        }
                    }
                }
            }
            .padding(.horizontal, 20)
        }
        .padding(.vertical, 16)
        .background(Color.white.opacity(0.05))
    }
    
    private var projectSection: some View {
        VStack(spacing: 20) {
            WorkOrderFormSection(title: "Project Information") {
                VStack(spacing: 16) {
                    WorkOrderFormField(title: "Work Order #", text: $workOrder.workOrderNumber, placeholder: "WO-12345")
                    WorkOrderFormField(title: "Customer Name", text: $workOrder.customerName, placeholder: "Customer name")
                    WorkOrderFormField(title: "Project Title", text: $workOrder.projectTitle, placeholder: "Land clearing project")
                    WorkOrderFormField(title: "Project Location", text: $workOrder.projectLocation, placeholder: "Project address")
                    WorkOrderFormField(title: "Description", text: $workOrder.projectDescription, placeholder: "Project details...", axis: .vertical)
                    
                    HStack(spacing: 12) {
                        WorkOrderDoubleField(title: "Land Size (Acres)", value: $workOrder.landSize)
                        WorkOrderFormField(title: "Package Type", text: $workOrder.packageType, placeholder: "medium")
                    }
                }
            }
        }
    }
    
    private var scheduleSection: some View {
        VStack(spacing: 20) {
            WorkOrderFormSection(title: "Scheduling") {
                VStack(spacing: 16) {
                    DatePicker("Start Date", 
                              selection: Binding(
                                get: { workOrder.scheduledStartDate ?? Date() },
                                set: { workOrder.scheduledStartDate = $0 }
                              ), 
                              displayedComponents: .date)
                        .foregroundColor(.white)
                        .padding(12)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color.white.opacity(0.1))
                                .stroke(Color.white.opacity(0.2), lineWidth: 1)
                        )
                    
                    DatePicker("End Date", 
                              selection: Binding(
                                get: { workOrder.scheduledEndDate ?? Date() },
                                set: { workOrder.scheduledEndDate = $0 }
                              ), 
                              displayedComponents: .date)
                        .foregroundColor(.white)
                        .padding(12)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color.white.opacity(0.1))
                                .stroke(Color.white.opacity(0.2), lineWidth: 1)
                        )
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Status")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(.white)
                        
                        Picker("Status", selection: $workOrder.status) {
                            ForEach(WorkOrderStatus.allCases, id: \.self) { status in
                                HStack {
                                    Image(systemName: status.systemImage)
                                    Text(status.rawValue)
                                }
                                .tag(status)
                            }
                        }
                        .pickerStyle(MenuPickerStyle())
                        .padding(.horizontal, 12)
                        .padding(.vertical, 10)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color.white.opacity(0.1))
                                .stroke(Color.white.opacity(0.2), lineWidth: 1)
                        )
                    }
                }
            }
        }
    }
    
    private var crewSection: some View {
        VStack(spacing: 20) {
            WorkOrderFormSection(title: "Crew & Equipment") {
                VStack(spacing: 16) {
                    WorkOrderFormField(title: "Crew Members", text: Binding(
                        get: { workOrder.crewAssigned.joined(separator: ", ") },
                        set: { workOrder.crewAssigned = $0.split(separator: ",").map { $0.trimmingCharacters(in: .whitespacesAndNewlines) } }
                    ), placeholder: "John Doe, Jane Smith", axis: .vertical)
                    
                    WorkOrderFormField(title: "Equipment", text: Binding(
                        get: { workOrder.equipmentUsed.joined(separator: ", ") },
                        set: { workOrder.equipmentUsed = $0.split(separator: ",").map { $0.trimmingCharacters(in: .whitespacesAndNewlines) } }
                    ), placeholder: "Forestry mulcher, excavator", axis: .vertical)
                    
                    WorkOrderDoubleField(title: "Hours Worked", value: $workOrder.hoursWorked)
                }
            }
        }
    }
    
    private var progressSection: some View {
        VStack(spacing: 20) {
            WorkOrderFormSection(title: "Progress & Notes") {
                VStack(spacing: 16) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Completion %")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(.white)
                        
                        Slider(value: $workOrder.completionPercentage, in: 0...1)
                            .accentColor(Color("TreeShopGreen"))
                        
                        Text("\(String(format: "%.0f", workOrder.completionPercentage * 100))% Complete")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    .padding(12)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.white.opacity(0.1))
                            .stroke(Color.white.opacity(0.2), lineWidth: 1)
                    )
                    
                    WorkOrderFormField(title: "Work Notes", text: $workOrder.workNotes, placeholder: "Progress updates, challenges, etc...", axis: .vertical)
                    WorkOrderFormField(title: "Safety Notes", text: $workOrder.safetyNotes, placeholder: "Safety incidents or concerns...", axis: .vertical)
                    
                    WorkOrderDoubleField(title: "Additional Costs", value: $workOrder.additionalCosts)
                }
            }
        }
    }
    
    private func saveWorkOrder() {
        // Calculate final amount
        workOrder.finalAmount = workOrder.originalAmount + workOrder.additionalCosts
        workOrder.dateUpdated = Date()
        
        if isEditing {
            workOrderManager.updateWorkOrder(workOrder)
        } else {
            workOrderManager.addWorkOrder(workOrder)
        }
        
        presentationMode.wrappedValue.dismiss()
    }
}

struct WorkOrderFormSection<Content: View>: View {
    let title: String
    let content: Content
    
    init(title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(title)
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(.white)
            
            content
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white.opacity(0.05))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.white.opacity(0.1), lineWidth: 1)
                )
        )
    }
}

struct WorkOrderFormField: View {
    let title: String
    @Binding var text: String
    let placeholder: String
    let axis: Axis
    
    init(title: String, text: Binding<String>, placeholder: String, axis: Axis = .horizontal) {
        self.title = title
        self._text = text
        self.placeholder = placeholder
        self.axis = axis
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(.white)
            
            TextField(placeholder, text: $text, axis: axis)
                .textFieldStyle(PlainTextFieldStyle())
                .foregroundColor(.white)
                .padding(12)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.white.opacity(0.1))
                        .stroke(Color.white.opacity(0.2), lineWidth: 1)
                )
                .lineLimit(axis == .vertical ? 4 : 1)
        }
    }
}

struct WorkOrderDoubleField: View {
    let title: String
    @Binding var value: Double
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(.white)
            
            TextField("0.0", value: $value, format: .number)
                .textFieldStyle(PlainTextFieldStyle())
                .foregroundColor(.white)
                .keyboardType(.decimalPad)
                .padding(12)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.white.opacity(0.1))
                        .stroke(Color.white.opacity(0.2), lineWidth: 1)
                )
        }
    }
}

#Preview {
    AddEditWorkOrderView()
        .environmentObject(WorkOrderManager())
}