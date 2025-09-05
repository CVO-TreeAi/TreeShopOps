import SwiftUI

struct AddEditServiceItemView: View {
    @EnvironmentObject var serviceItemManager: ServiceItemManager
    @Environment(\.presentationMode) var presentationMode
    
    @State private var serviceItem: ServiceItem
    @State private var isEditing: Bool
    
    // Form sections
    @State private var selectedSection = 0
    private let sections = ["Basic Info", "Pricing", "Requirements"]
    
    init(serviceItem: ServiceItem? = nil) {
        if let existingService = serviceItem {
            _serviceItem = State(initialValue: existingService)
            _isEditing = State(initialValue: true)
        } else {
            _serviceItem = State(initialValue: ServiceItem())
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
                                basicInfoSection
                            case 1:
                                pricingSection
                            case 2:
                                requirementsSection
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
            .navigationTitle(isEditing ? "Edit Service" : "New Service")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(
                leading: Button("Cancel") {
                    presentationMode.wrappedValue.dismiss()
                }
                .foregroundColor(.white),
                
                trailing: Button("Save") {
                    saveServiceItem()
                }
                .foregroundColor(Color("TreeShopGreen"))
                .fontWeight(.semibold)
                .disabled(serviceItem.name.isEmpty)
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
    
    private var basicInfoSection: some View {
        VStack(spacing: 20) {
            ServiceFormSection(title: "Service Information") {
                VStack(spacing: 16) {
                    ServiceFormField(title: "Service Name", text: $serviceItem.name, placeholder: "Forestry Mulching")
                    ServiceFormField(title: "Description", text: $serviceItem.description, placeholder: "Professional forestry mulching service...", axis: .vertical)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Category")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(.white)
                        
                        Picker("Category", selection: $serviceItem.category) {
                            ForEach(ServiceCategory.allCases, id: \.self) { category in
                                HStack {
                                    Image(systemName: category.systemImage)
                                    Text(category.rawValue)
                                }
                                .tag(category)
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
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Unit Type")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(.white)
                        
                        Picker("Unit Type", selection: $serviceItem.unitType) {
                            ForEach(UnitType.allCases, id: \.self) { unit in
                                Text(unit.rawValue).tag(unit)
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
                    
                    Toggle("Active Service", isOn: $serviceItem.isActive)
                        .foregroundColor(.white)
                        .padding(12)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color.white.opacity(0.1))
                                .stroke(Color.white.opacity(0.2), lineWidth: 1)
                        )
                }
            }
        }
    }
    
    private var pricingSection: some View {
        VStack(spacing: 20) {
            ServiceFormSection(title: "Pricing Configuration") {
                VStack(spacing: 16) {
                    ServiceDoubleField(title: "Base Price", value: $serviceItem.basePrice)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Pricing Model")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(.white)
                        
                        Picker("Pricing Model", selection: $serviceItem.pricingModel) {
                            ForEach(ServicePricingModel.allCases, id: \.self) { model in
                                VStack(alignment: .leading) {
                                    Text(model.rawValue)
                                    Text(model.description)
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                }
                                .tag(model)
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
                    
                    HStack(spacing: 12) {
                        ServiceDoubleField(title: "Min Quantity", value: $serviceItem.minimumQuantity)
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Max Quantity")
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundColor(.white)
                            
                            TextField("Unlimited", value: Binding(
                                get: { serviceItem.maximumQuantity ?? 0 },
                                set: { serviceItem.maximumQuantity = $0 > 0 ? $0 : nil }
                            ), format: .number)
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
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Tax Category")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(.white)
                        
                        Picker("Tax Category", selection: $serviceItem.taxCategory) {
                            ForEach(TaxCategory.allCases, id: \.self) { category in
                                Text(category.rawValue).tag(category)
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
                    
                    Toggle("Discount Eligible", isOn: $serviceItem.discountEligible)
                        .foregroundColor(.white)
                        .padding(12)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color.white.opacity(0.1))
                                .stroke(Color.white.opacity(0.2), lineWidth: 1)
                        )
                    
                    Toggle("Taxable", isOn: $serviceItem.taxable)
                        .foregroundColor(.white)
                        .padding(12)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color.white.opacity(0.1))
                                .stroke(Color.white.opacity(0.2), lineWidth: 1)
                        )
                }
            }
        }
    }
    
    private var requirementsSection: some View {
        VStack(spacing: 20) {
            ServiceFormSection(title: "Service Requirements") {
                VStack(spacing: 16) {
                    ServiceDoubleField(title: "Estimated Duration (Hours)", value: $serviceItem.estimatedDuration)
                    
                    ServiceFormField(
                        title: "Equipment Required", 
                        text: Binding(
                            get: { serviceItem.equipmentRequired.joined(separator: ", ") },
                            set: { serviceItem.equipmentRequired = $0.split(separator: ",").map { $0.trimmingCharacters(in: .whitespacesAndNewlines) } }
                        ), 
                        placeholder: "Forestry mulcher, excavator, dump truck", 
                        axis: .vertical
                    )
                    
                    ServiceFormField(
                        title: "Skill Requirements", 
                        text: Binding(
                            get: { serviceItem.skillRequirements.joined(separator: ", ") },
                            set: { serviceItem.skillRequirements = $0.split(separator: ",").map { $0.trimmingCharacters(in: .whitespacesAndNewlines) } }
                        ), 
                        placeholder: "Heavy equipment operation, safety certification", 
                        axis: .vertical
                    )
                    
                    Toggle("Seasonal Available", isOn: $serviceItem.seasonalAvailable)
                        .foregroundColor(.white)
                        .padding(12)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color.white.opacity(0.1))
                                .stroke(Color.white.opacity(0.2), lineWidth: 1)
                        )
                    
                    ServiceFormField(title: "Notes", text: $serviceItem.notes, placeholder: "Additional service information...", axis: .vertical)
                }
            }
        }
    }
    
    private func saveServiceItem() {
        serviceItem.dateUpdated = Date()
        
        if isEditing {
            serviceItemManager.updateServiceItem(serviceItem)
        } else {
            serviceItemManager.addServiceItem(serviceItem)
        }
        
        presentationMode.wrappedValue.dismiss()
    }
}

struct ServiceFormSection<Content: View>: View {
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

struct ServiceFormField: View {
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

struct ServiceDoubleField: View {
    let title: String
    @Binding var value: Double
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(.white)
            
            TextField("0.00", value: $value, format: .number)
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
    AddEditServiceItemView()
        .environmentObject(ServiceItemManager())
}