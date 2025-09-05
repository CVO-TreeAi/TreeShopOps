import SwiftUI
import MapKit

struct AddEditCustomerView: View {
    @ObservedObject var customerManager: CustomerManager
    @Environment(\.presentationMode) var presentationMode
    
    let existingCustomer: Customer?
    let pricingModel: PricingModel?
    
    @State private var firstName: String = ""
    @State private var lastName: String = ""
    @State private var email: String = ""
    @State private var phone: String = ""
    @State private var address: String = ""
    @State private var city: String = ""
    @State private var state: String = ""
    @State private var zipCode: String = ""
    @State private var notes: String = ""
    @State private var selectedCustomerType: CustomerType = .residential
    @State private var selectedContactMethod: ContactMethod = .phone
    @State private var referralSource: String = ""
    
    @State private var addressSearchResults: [MKMapItem] = []
    @State private var showingValidationAlert = false
    @State private var validationMessage = ""
    
    var isEditing: Bool {
        existingCustomer != nil
    }
    
    init(customerManager: CustomerManager, existingCustomer: Customer? = nil, pricingModel: PricingModel? = nil) {
        self.customerManager = customerManager
        self.existingCustomer = existingCustomer
        self.pricingModel = pricingModel
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.black.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 20) {
                        // Personal Information Section
                        personalInfoSection
                        
                        // Contact Information Section
                        contactInfoSection
                        
                        // Address Information Section
                        addressInfoSection
                        
                        // Additional Information Section
                        additionalInfoSection
                        
                        // Quote Information Section (if available)
                        if pricingModel != nil {
                            quoteInfoSection
                        }
                        
                        // Save Button
                        saveButton
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 20)
                    .padding(.bottom, 30)
                }
                .onTapGesture {
                    hideKeyboard()
                }
            }
            .navigationTitle(isEditing ? "Edit Customer" : "Add Customer")
            .navigationBarTitleDisplayMode(.large)
            .navigationBarItems(
                leading: Button("Cancel") {
                    presentationMode.wrappedValue.dismiss()
                },
                trailing: Button("Save") {
                    saveCustomer()
                }
                .foregroundColor(Color("TreeShopGreen"))
            )
        }
        .preferredColorScheme(.dark)
        .onAppear {
            loadExistingCustomerData()
        }
        .alert(isPresented: $showingValidationAlert) {
            Alert(
                title: Text("Validation Error"),
                message: Text(validationMessage),
                dismissButton: .default(Text("OK"))
            )
        }
    }
    
    // MARK: - Personal Information Section
    private var personalInfoSection: some View {
        VStack(alignment: .leading, spacing: 15) {
            sectionHeader(title: "Personal Information", icon: "person.fill")
            
            VStack(spacing: 12) {
                HStack(spacing: 12) {
                    modernInputField(
                        title: "First Name",
                        text: $firstName,
                        placeholder: "First name",
                        icon: "person.fill"
                    )
                    
                    modernInputField(
                        title: "Last Name", 
                        text: $lastName,
                        placeholder: "Last name",
                        icon: "person.fill"
                    )
                }
                
                // Customer type picker
                customerTypePicker
            }
        }
        .padding(24)
        .background(glassMorphismBackground)
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }
    
    // MARK: - Contact Information Section
    private var contactInfoSection: some View {
        VStack(alignment: .leading, spacing: 15) {
            sectionHeader(title: "Contact Information", icon: "phone.fill")
            
            VStack(spacing: 12) {
                modernInputField(
                    title: "Email Address",
                    text: $email,
                    placeholder: "email@example.com",
                    icon: "envelope.fill",
                    keyboardType: .emailAddress
                )
                
                modernInputField(
                    title: "Phone Number",
                    text: $phone,
                    placeholder: "(555) 123-4567",
                    icon: "phone.fill",
                    keyboardType: .phonePad
                )
                
                // Preferred contact method picker
                contactMethodPicker
            }
        }
        .padding(24)
        .background(glassMorphismBackground)
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }
    
    // MARK: - Address Information Section
    private var addressInfoSection: some View {
        VStack(alignment: .leading, spacing: 15) {
            sectionHeader(title: "Address Information", icon: "location.fill")
            
            VStack(spacing: 12) {
                modernAddressField(
                    title: "Street Address",
                    text: $address,
                    placeholder: "123 Main Street",
                    icon: "house.fill"
                )
                
                HStack(spacing: 12) {
                    modernInputField(
                        title: "City",
                        text: $city,
                        placeholder: "City",
                        icon: "building.2.fill"
                    )
                    
                    modernInputField(
                        title: "State",
                        text: $state,
                        placeholder: "State",
                        icon: "map.fill"
                    )
                }
                
                modernInputField(
                    title: "Zip Code",
                    text: $zipCode,
                    placeholder: "12345",
                    icon: "location.circle.fill",
                    keyboardType: .numberPad
                )
            }
        }
        .padding(24)
        .background(glassMorphismBackground)
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }
    
    // MARK: - Quote Information Section
    private var quoteInfoSection: some View {
        VStack(alignment: .leading, spacing: 15) {
            sectionHeader(title: "Quote Information", icon: "dollarsign.circle.fill")
            
            if let pricing = pricingModel {
                VStack(spacing: 12) {
                    // Quote summary card
                    VStack(spacing: 10) {
                        HStack {
                            Text("Project Total")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.white)
                            
                            Spacer()
                            
                            Text(pricing.formatCurrency(pricing.finalPrice))
                                .font(.system(size: 18, weight: .bold, design: .rounded))
                                .foregroundColor(Color("TreeShopGreen"))
                        }
                        
                        HStack {
                            Text("Deposit Required (25%)")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(Color.white.opacity(0.8))
                            
                            Spacer()
                            
                            Text(pricing.formatCurrency(pricing.depositAmount))
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(Color(red: 1.0, green: 0.76, blue: 0.03))
                        }
                        
                        Divider()
                            .background(Color.white.opacity(0.2))
                        
                        // Project details
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("\(pricing.landSize, specifier: "%.1f") acres")
                                    .font(.system(size: 12, weight: .medium))
                                    .foregroundColor(Color.white.opacity(0.7))
                                
                                Text(pricing.selectedPackage.displayName)
                                    .font(.system(size: 12, weight: .medium))
                                    .foregroundColor(Color.white.opacity(0.7))
                            }
                            
                            Spacer()
                            
                            if !pricing.projectZipCode.isEmpty {
                                Text("Zip: \(pricing.projectZipCode)")
                                    .font(.system(size: 12, weight: .medium))
                                    .foregroundColor(Color.white.opacity(0.7))
                            }
                        }
                    }
                    .padding(16)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.white.opacity(0.03))
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color("TreeShopGreen").opacity(0.3), lineWidth: 1)
                            )
                    )
                    
                    HStack(spacing: 8) {
                        Image(systemName: "info.circle.fill")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(Color(red: 1.0, green: 0.76, blue: 0.03))
                        
                        Text("This quote will be automatically saved as a project for this customer")
                            .font(.system(size: 11, weight: .medium))
                            .foregroundColor(Color.white.opacity(0.6))
                        
                        Spacer()
                    }
                }
            }
        }
        .padding(24)
        .background(glassMorphismBackground)
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }
    
    // MARK: - Additional Information Section
    private var additionalInfoSection: some View {
        VStack(alignment: .leading, spacing: 15) {
            sectionHeader(title: "Additional Information", icon: "note.text")
            
            VStack(spacing: 12) {
                modernInputField(
                    title: "Referral Source",
                    text: $referralSource,
                    placeholder: "How did they find us?",
                    icon: "person.2.fill"
                )
                
                modernTextEditor(
                    title: "Notes",
                    text: $notes,
                    placeholder: "Additional notes about this customer...",
                    icon: "note.text"
                )
            }
        }
        .padding(24)
        .background(glassMorphismBackground)
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }
    
    // MARK: - Save Button
    private var saveButton: some View {
        Button(action: {
            saveCustomer()
        }) {
            HStack {
                Image(systemName: isEditing ? "checkmark.circle.fill" : "plus.circle.fill")
                    .font(.title2)
                Text(isEditing ? "Update Customer" : "Add Customer")
                    .font(.headline)
                    .fontWeight(.semibold)
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(
                LinearGradient(
                    colors: [Color(red: 0.18, green: 0.49, blue: 0.20), Color("TreeShopGreen")],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .clipShape(RoundedRectangle(cornerRadius: 12))
            )
            .shadow(color: .black.opacity(0.3), radius: 5, x: 0, y: 2)
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    // MARK: - Customer Type Picker
    private var customerTypePicker: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 6) {
                Image(systemName: "building.2.fill")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(Color("TreeShopGreen"))
                    .frame(width: 16)
                
                Text("Customer Type")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(Color.white.opacity(0.7))
                
                Spacer()
            }
            
            HStack(spacing: 8) {
                ForEach(CustomerType.allCases, id: \.self) { type in
                    Button(action: {
                        selectedCustomerType = type
                        let impactFeedback = UIImpactFeedbackGenerator(style: .light)
                        impactFeedback.impactOccurred()
                    }) {
                        HStack(spacing: 6) {
                            Image(systemName: type.iconName)
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(selectedCustomerType == type ? .white : Color.white.opacity(0.6))
                            
                            Text(type.displayName)
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(selectedCustomerType == type ? .white : Color.white.opacity(0.6))
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(selectedCustomerType == type ? 
                                      Color("TreeShopGreen") : 
                                      Color.white.opacity(0.05))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(selectedCustomerType == type ? 
                                                Color("TreeShopGreen") : 
                                                Color.white.opacity(0.1), lineWidth: 1)
                                )
                        )
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
        }
    }
    
    // MARK: - Contact Method Picker  
    private var contactMethodPicker: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 6) {
                Image(systemName: "phone.circle.fill")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(Color("TreeShopGreen"))
                    .frame(width: 16)
                
                Text("Preferred Contact Method")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(Color.white.opacity(0.7))
                
                Spacer()
            }
            
            HStack(spacing: 8) {
                ForEach(ContactMethod.allCases, id: \.self) { method in
                    Button(action: {
                        selectedContactMethod = method
                        let impactFeedback = UIImpactFeedbackGenerator(style: .light)
                        impactFeedback.impactOccurred()
                    }) {
                        HStack(spacing: 6) {
                            Image(systemName: method.iconName)
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(selectedContactMethod == method ? .white : Color.white.opacity(0.6))
                            
                            Text(method.displayName)
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(selectedContactMethod == method ? .white : Color.white.opacity(0.6))
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(selectedContactMethod == method ? 
                                      Color(red: 1.0, green: 0.76, blue: 0.03) : 
                                      Color.white.opacity(0.05))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(selectedContactMethod == method ? 
                                                Color(red: 1.0, green: 0.76, blue: 0.03) : 
                                                Color.white.opacity(0.1), lineWidth: 1)
                                )
                        )
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
        }
    }
    
    // MARK: - Section Header
    private func sectionHeader(title: String, icon: String) -> some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(Color("TreeShopGreen"))
                .font(.title2)
            
            Text(title)
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(.white)
        }
    }
    
    // MARK: - Modern Input Field (reusing existing pattern)
    private func modernInputField(title: String, text: Binding<String>, placeholder: String, icon: String, keyboardType: UIKeyboardType = .default) -> some View {
        VStack(spacing: 8) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(Color("TreeShopGreen"))
                    .frame(width: 16)
                
                Text(title)
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(Color.white.opacity(0.7))
                
                Spacer()
            }
            
            TextField(placeholder, text: text)
                .font(.system(size: 15, weight: .medium))
                .foregroundColor(.white)
                .keyboardType(keyboardType)
                .textContentType(getTextContentType(for: title))
                .autocapitalization(getAutoCapitalization(for: title))
                .disableAutocorrection(shouldDisableAutoCorrect(for: title))
                .padding(.horizontal, 12)
                .padding(.vertical, 10)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.white.opacity(0.05))
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.white.opacity(0.1), lineWidth: 1)
                        )
                )
        }
        .frame(maxWidth: .infinity)
    }
    
    // MARK: - Modern Address Field with Maps Integration
    private func modernAddressField(title: String, text: Binding<String>, placeholder: String, icon: String) -> some View {
        VStack(spacing: 8) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(Color("TreeShopGreen"))
                    .frame(width: 16)
                
                Text(title)
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(Color.white.opacity(0.7))
                
                Spacer()
            }
            
            HStack {
                TextField(placeholder, text: text)
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(.white)
                    .textContentType(.fullStreetAddress)
                    .onSubmit {
                        searchForAddress(text.wrappedValue)
                    }
                    .onChange(of: text.wrappedValue) { oldValue, newValue in
                        if newValue.count > 5 {
                            searchForAddress(newValue)
                        }
                    }
                
                Button(action: {
                    searchForAddress(text.wrappedValue)
                }) {
                    Image(systemName: "magnifyingglass")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(Color("TreeShopGreen"))
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.white.opacity(0.05))
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.white.opacity(0.1), lineWidth: 1)
                    )
            )
            
            // Show search results
            if !addressSearchResults.isEmpty {
                VStack(spacing: 4) {
                    ForEach(addressSearchResults.prefix(3), id: \.self) { mapItem in
                        Button(action: {
                            selectAddress(mapItem)
                            addressSearchResults = []
                        }) {
                            HStack {
                                Image(systemName: "mappin.circle.fill")
                                    .foregroundColor(Color(red: 1.0, green: 0.76, blue: 0.03))
                                Text(formatAddress(mapItem))
                                    .font(.caption)
                                    .foregroundColor(.white)
                                Spacer()
                            }
                            .padding(.vertical, 6)
                            .padding(.horizontal, 8)
                            .background(Color(red: 0.2, green: 0.2, blue: 0.2))
                            .cornerRadius(6)
                        }
                    }
                }
                .padding(.top, 4)
            }
        }
    }
    
    // MARK: - Modern Text Editor
    private func modernTextEditor(title: String, text: Binding<String>, placeholder: String, icon: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(Color("TreeShopGreen"))
                    .frame(width: 16)
                
                Text(title)
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(Color.white.opacity(0.7))
                
                Spacer()
            }
            
            ZStack(alignment: .topLeading) {
                if text.wrappedValue.isEmpty {
                    Text(placeholder)
                        .font(.system(size: 15, weight: .medium))
                        .foregroundColor(Color.white.opacity(0.5))
                        .padding(.horizontal, 12)
                        .padding(.vertical, 10)
                        .allowsHitTesting(false)
                }
                
                TextEditor(text: text)
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(.white)
                    .scrollContentBackground(.hidden)
                    .background(Color.clear)
                    .frame(minHeight: 80)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 6)
            }
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.white.opacity(0.05))
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.white.opacity(0.1), lineWidth: 1)
                    )
            )
        }
    }
    
    // MARK: - Glassmorphism Background (reusing existing pattern)
    private var glassMorphismBackground: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20)
                .fill(.ultraThinMaterial)
            
            RoundedRectangle(cornerRadius: 20)
                .fill(
                    LinearGradient(
                        colors: [
                            Color.white.opacity(0.05),
                            Color.white.opacity(0.02),
                            Color.black.opacity(0.05)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
            
            RoundedRectangle(cornerRadius: 20)
                .stroke(
                    LinearGradient(
                        colors: [Color.white.opacity(0.2), Color.white.opacity(0.05)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1
                )
        }
    }
    
    // MARK: - Helper Functions
    private func loadExistingCustomerData() {
        if let customer = existingCustomer {
            firstName = customer.firstName
            lastName = customer.lastName
            email = customer.email
            phone = customer.phone
            address = customer.address
            city = customer.city
            state = customer.state
            zipCode = customer.zipCode
            notes = customer.notes
            selectedCustomerType = customer.customerType
            selectedContactMethod = customer.preferredContactMethod
            referralSource = customer.referralSource
        }
    }
    
    private func validateInput() -> Bool {
        if firstName.isEmpty && lastName.isEmpty {
            validationMessage = "Please enter at least a first name or last name."
            return false
        }
        
        if !email.isEmpty && !isValidEmail(email) {
            validationMessage = "Please enter a valid email address."
            return false
        }
        
        return true
    }
    
    private func isValidEmail(_ email: String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format:"SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: email)
    }
    
    private func saveCustomer() {
        guard validateInput() else {
            showingValidationAlert = true
            return
        }
        
        let customer = Customer(
            id: existingCustomer?.id ?? UUID(),
            firstName: firstName.trimmingCharacters(in: .whitespaces),
            lastName: lastName.trimmingCharacters(in: .whitespaces),
            email: email.trimmingCharacters(in: .whitespaces),
            phone: phone.trimmingCharacters(in: .whitespaces),
            address: address.trimmingCharacters(in: .whitespaces),
            city: city.trimmingCharacters(in: .whitespaces),
            state: state.trimmingCharacters(in: .whitespaces),
            zipCode: zipCode.trimmingCharacters(in: .whitespaces),
            notes: notes.trimmingCharacters(in: .whitespaces),
            dateCreated: existingCustomer?.dateCreated ?? Date(),
            lastUpdated: Date(),
            projects: existingCustomer?.projects ?? [],
            tags: existingCustomer?.tags ?? [],
            preferredContactMethod: selectedContactMethod,
            customerType: selectedCustomerType,
            referralSource: referralSource.trimmingCharacters(in: .whitespaces)
        )
        
        if isEditing {
            customerManager.updateCustomer(customer)
        } else {
            customerManager.addCustomer(customer)
        }
        
        // If we have a pricing model, create a project from it
        if let pricing = pricingModel, !isEditing {
            customerManager.createProjectFromQuote(customer.id, pricingModel: pricing, projectName: "Tree Service Quote")
        }
        
        // Haptic feedback
        let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
        impactFeedback.impactOccurred()
        
        presentationMode.wrappedValue.dismiss()
    }
    
    // MARK: - Address Search Functions
    private func searchForAddress(_ query: String) {
        guard !query.isEmpty else { return }
        
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = query
        
        let search = MKLocalSearch(request: request)
        search.start { response, error in
            if let response = response {
                DispatchQueue.main.async {
                    self.addressSearchResults = Array(response.mapItems.prefix(5))
                }
            }
        }
    }
    
    private func selectAddress(_ mapItem: MKMapItem) {
        let placemark = mapItem.placemark
        
        if let streetNumber = placemark.subThoroughfare,
           let street = placemark.thoroughfare {
            address = "\(streetNumber) \(street)"
        } else if let street = placemark.thoroughfare {
            address = street
        }
        
        if let selectedCity = placemark.locality {
            city = selectedCity
        }
        
        if let selectedState = placemark.administrativeArea {
            state = selectedState
        }
        
        if let selectedZip = placemark.postalCode {
            zipCode = selectedZip
        }
    }
    
    private func formatAddress(_ mapItem: MKMapItem) -> String {
        let placemark = mapItem.placemark
        var components: [String] = []
        
        if let streetNumber = placemark.subThoroughfare {
            components.append(streetNumber)
        }
        if let street = placemark.thoroughfare {
            components.append(street)
        }
        if let city = placemark.locality {
            components.append(city)
        }
        if let state = placemark.administrativeArea {
            components.append(state)
        }
        if let zipCode = placemark.postalCode {
            components.append(zipCode)
        }
        
        return components.joined(separator: " ")
    }
    
    private func getTextContentType(for title: String) -> UITextContentType? {
        switch title.lowercased() {
        case "first name":
            return .givenName
        case "last name":
            return .familyName
        case "email", "email address":
            return .emailAddress
        case "phone", "phone number":
            return .telephoneNumber
        case "street address":
            return .fullStreetAddress
        case "city":
            return .addressCity
        case "state":
            return .addressState
        case "zip code":
            return .postalCode
        default:
            return nil
        }
    }
    
    private func getAutoCapitalization(for title: String) -> UITextAutocapitalizationType {
        switch title.lowercased() {
        case "email", "email address":
            return .none
        default:
            return .words
        }
    }
    
    private func shouldDisableAutoCorrect(for title: String) -> Bool {
        switch title.lowercased() {
        case "email", "email address", "phone", "phone number", "zip code":
            return true
        default:
            return false
        }
    }
    
    private func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

#Preview {
    AddEditCustomerView(customerManager: CustomerManager())
}