import SwiftUI

// MARK: - Employee Picker View

struct EmployeePickerView: View {
    let employees: [Employee]
    @Binding var selectedEmployee: Employee?
    @Environment(\.presentationMode) var presentationMode
    
    @State private var searchText = ""
    
    var filteredEmployees: [Employee] {
        if searchText.isEmpty {
            return employees
        }
        return employees.filter { employee in
            employee.fullName.localizedCaseInsensitiveContains(searchText) ||
            employee.qualificationCode.localizedCaseInsensitiveContains(searchText) ||
            employee.qualifications.primaryRole.fullName.localizedCaseInsensitiveContains(searchText)
        }
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                Color("TreeShopBlack").ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Search bar
                    searchBar
                    
                    // Employee list
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            ForEach(filteredEmployees) { employee in
                                EmployeePickerRow(employee: employee) {
                                    selectedEmployee = employee
                                    presentationMode.wrappedValue.dismiss()
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.bottom, 100)
                    }
                }
            }
            .navigationTitle("Select Employee")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(
                trailing: Button("Cancel") {
                    presentationMode.wrappedValue.dismiss()
                }
                .foregroundColor(.white)
            )
        }
        .searchable(text: $searchText, prompt: "Search employees...")
    }
    
    private var searchBar: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.gray)
            
            TextField("Search employees...", text: $searchText)
                .foregroundColor(.white)
                .textFieldStyle(PlainTextFieldStyle())
            
            if !searchText.isEmpty {
                Button(action: { searchText = "" }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.gray)
                }
            }
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.white.opacity(0.05))
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.white.opacity(0.1), lineWidth: 1)
                )
        )
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
    }
}

struct EmployeePickerRow: View {
    let employee: Employee
    let onSelect: () -> Void
    
    var body: some View {
        Button(action: onSelect) {
            HStack(spacing: 16) {
                // Employee avatar
                Circle()
                    .fill(Color("TreeShopGreen"))
                    .frame(width: 50, height: 50)
                    .overlay(
                        Text(employee.personalInfo.firstName.prefix(1))
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.black)
                    )
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(employee.fullName)
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                    
                    Text(employee.qualificationCode)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(Color("TreeShopGreen"))
                    
                    Text(employee.qualifications.primaryRole.fullName)
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Image(systemName: employee.metadata.status.systemImage)
                        .foregroundColor(Color(employee.metadata.status.color))
                    
                    Text(employee.metadata.status.rawValue)
                        .font(.caption2)
                        .foregroundColor(.gray)
                }
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.white.opacity(0.05))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.white.opacity(0.1), lineWidth: 1)
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Activity Picker View

struct ActivityPickerView: View {
    let employee: Employee
    let timeTrackingManager: TimeTrackingManager
    @Environment(\.presentationMode) var presentationMode
    
    @State private var selectedCategory: ActivityCategory? = nil
    @State private var searchText = ""
    
    private var availableActivities: [TimeTrackingActivity] {
        timeTrackingManager.getAvailableActivities(for: employee)
    }
    
    private var filteredActivities: [TimeTrackingActivity] {
        var activities = availableActivities
        
        if let category = selectedCategory {
            activities = activities.filter { $0.category == category }
        }
        
        if !searchText.isEmpty {
            activities = activities.filter { activity in
                activity.name.localizedCaseInsensitiveContains(searchText) ||
                activity.category.rawValue.localizedCaseInsensitiveContains(searchText)
            }
        }
        
        return activities
    }
    
    private var categorizedActivities: [(category: ActivityCategory, activities: [TimeTrackingActivity])] {
        let grouped = Dictionary(grouping: filteredActivities) { $0.category }
        return grouped.map { (category: $0.key, activities: $0.value) }
            .sorted { $0.category.rawValue < $1.category.rawValue }
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                Color("TreeShopBlack").ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Employee info header
                    employeeInfoHeader
                    
                    // Category filter
                    categoryFilterSection
                    
                    // Activities list
                    ScrollView {
                        LazyVStack(spacing: 16) {
                            ForEach(categorizedActivities, id: \.category) { categoryData in
                                ActivityCategorySection(
                                    category: categoryData.category,
                                    activities: categoryData.activities,
                                    employee: employee,
                                    timeTrackingManager: timeTrackingManager,
                                    onActivitySelected: {
                                        presentationMode.wrappedValue.dismiss()
                                    }
                                )
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.bottom, 100)
                    }
                }
            }
            .navigationTitle("Select Activity")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(
                trailing: Button("Cancel") {
                    presentationMode.wrappedValue.dismiss()
                }
                .foregroundColor(.white)
            )
        }
        .searchable(text: $searchText, prompt: "Search activities...")
    }
    
    private var employeeInfoHeader: some View {
        HStack {
            Circle()
                .fill(Color("TreeShopGreen"))
                .frame(width: 40, height: 40)
                .overlay(
                    Text(employee.personalInfo.firstName.prefix(1))
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(.black)
                )
            
            VStack(alignment: .leading, spacing: 2) {
                Text(employee.fullName)
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                
                Text(employee.qualificationCode)
                    .font(.caption)
                    .foregroundColor(Color("TreeShopGreen"))
            }
            
            Spacer()
            
            Text("\(availableActivities.count) activities")
                .font(.caption)
                .foregroundColor(.gray)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .background(Color.white.opacity(0.05))
    }
    
    private var categoryFilterSection: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                CategoryFilterChip(
                    title: "All",
                    isSelected: selectedCategory == nil
                ) {
                    selectedCategory = nil
                }
                
                ForEach(ActivityCategory.allCases, id: \.self) { category in
                    if availableActivities.contains(where: { $0.category == category }) {
                        CategoryFilterChip(
                            title: category.rawValue,
                            isSelected: selectedCategory == category,
                            icon: category.systemImage,
                            color: Color(category.color)
                        ) {
                            selectedCategory = selectedCategory == category ? nil : category
                        }
                    }
                }
            }
            .padding(.horizontal, 20)
        }
        .padding(.vertical, 12)
    }
}

struct ActivityCategorySection: View {
    let category: ActivityCategory
    let activities: [TimeTrackingActivity]
    let employee: Employee
    let timeTrackingManager: TimeTrackingManager
    let onActivitySelected: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: category.systemImage)
                    .foregroundColor(Color(category.color))
                
                Text(category.rawValue)
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                
                Spacer()
                
                Text("\(activities.count)")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            
            VStack(spacing: 8) {
                ForEach(activities, id: \.id) { activity in
                    ActivityPickerRow(
                        activity: activity,
                        employee: employee,
                        timeTrackingManager: timeTrackingManager,
                        onSelect: onActivitySelected
                    )
                }
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white.opacity(0.03))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color(category.color).opacity(0.2), lineWidth: 1)
                )
        )
    }
}

struct ActivityPickerRow: View {
    let activity: TimeTrackingActivity
    let employee: Employee
    let timeTrackingManager: TimeTrackingManager
    let onSelect: () -> Void
    
    var body: some View {
        Button(action: {
            timeTrackingManager.startTimeEntry(
                employee: employee,
                activity: activity
            )
            onSelect()
        }) {
            HStack(spacing: 12) {
                Image(systemName: activity.icon)
                    .font(.title3)
                    .foregroundColor(Color(activity.color))
                    .frame(width: 30)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(activity.name)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.white)
                    
                    HStack(spacing: 12) {
                        Label(activity.category.rawValue, systemImage: activity.category.systemImage)
                            .font(.caption2)
                            .foregroundColor(.gray)
                        
                        if activity.billable {
                            Label("Billable", systemImage: "dollarsign.circle")
                                .font(.caption2)
                                .foregroundColor(Color("TreeShopGreen"))
                        }
                        
                        Label(activity.safetyLevel.rawValue, systemImage: activity.safetyLevel.systemImage)
                            .font(.caption2)
                            .foregroundColor(Color(activity.safetyLevel.color))
                    }
                }
                
                Spacer()
                
                Image(systemName: "play.circle.fill")
                    .font(.title2)
                    .foregroundColor(Color("TreeShopGreen"))
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.white.opacity(0.05))
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.white.opacity(0.1), lineWidth: 1)
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct CategoryFilterChip: View {
    let title: String
    let isSelected: Bool
    let icon: String?
    let color: Color
    let action: () -> Void
    
    init(title: String, isSelected: Bool, icon: String? = nil, color: Color = Color("TreeShopGreen"), action: @escaping () -> Void) {
        self.title = title
        self.isSelected = isSelected
        self.icon = icon
        self.color = color
        self.action = action
    }
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                if let icon = icon {
                    Image(systemName: icon)
                        .font(.caption)
                }
                
                Text(title)
                    .font(.caption)
                    .fontWeight(.medium)
            }
            .foregroundColor(isSelected ? .black : .gray)
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(isSelected ? color : Color.white.opacity(0.1))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(isSelected ? color : Color.white.opacity(0.2), lineWidth: 1)
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Time Entry Detail View

struct TimeEntryDetailView: View {
    let entry: TimeEntry
    let timeTrackingManager: TimeTrackingManager
    @Environment(\.presentationMode) var presentationMode
    
    @State private var notes: String
    @State private var showingStopConfirmation = false
    
    init(entry: TimeEntry, timeTrackingManager: TimeTrackingManager) {
        self.entry = entry
        self.timeTrackingManager = timeTrackingManager
        self._notes = State(initialValue: entry.notes)
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                Color("TreeShopBlack").ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Entry overview
                        entryOverviewSection
                        
                        // Activity details
                        activityDetailsSection
                        
                        // Notes section
                        notesSection
                        
                        // Controls
                        if entry.isActive {
                            stopTimerSection
                        } else {
                            completedEntrySection
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 2)
                    .padding(.bottom, 100)
                }
            }
            .navigationTitle(entry.isActive ? "Active Entry" : "Time Entry")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(
                leading: Button("Close") {
                    presentationMode.wrappedValue.dismiss()
                }
                .foregroundColor(.white),
                
                trailing: entry.isActive ? AnyView(
                    Button("Stop") {
                        showingStopConfirmation = true
                    }
                    .foregroundColor(.red)
                    .fontWeight(.semibold)
                ) : AnyView(EmptyView())
            )
            .alert("Stop Timer?", isPresented: $showingStopConfirmation) {
                Button("Cancel", role: .cancel) { }
                Button("Stop", role: .destructive) {
                    timeTrackingManager.stopTimeEntry(entry.id, notes: notes)
                    presentationMode.wrappedValue.dismiss()
                }
            } message: {
                Text("This will stop the timer and save the time entry.")
            }
        }
    }
    
    private var entryOverviewSection: some View {
        VStack(spacing: 16) {
            HStack {
                Image(systemName: "person.circle.fill")
                    .foregroundColor(Color("TreeShopGreen"))
                    .font(.title3)
                
                Text("Entry Overview")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                
                Spacer()
            }
            
            VStack(spacing: 12) {
                InfoRow(label: "Employee", value: "\(entry.employeeName) (\(entry.employeeCode))")
                InfoRow(label: "Started", value: entry.startTime.formatted(date: .abbreviated, time: .shortened))
                
                if let endTime = entry.endTime {
                    InfoRow(label: "Ended", value: endTime.formatted(date: .abbreviated, time: .shortened))
                }
                
                InfoRow(label: "Duration", value: entry.durationFormatted, valueColor: Color("TreeShopGreen"))
                
                if let location = entry.location {
                    InfoRow(label: "Location", value: location)
                }
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white.opacity(0.03))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.white.opacity(0.1), lineWidth: 1)
                )
        )
    }
    
    private var activityDetailsSection: some View {
        VStack(spacing: 16) {
            HStack {
                Image(systemName: entry.activity.icon)
                    .foregroundColor(Color(entry.activity.color))
                    .font(.title3)
                
                Text("Activity Details")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                
                Spacer()
            }
            
            VStack(spacing: 12) {
                InfoRow(label: "Activity", value: entry.activity.name)
                InfoRow(label: "Category", value: entry.activity.category.rawValue)
                InfoRow(
                    label: "Billable", 
                    value: entry.activity.billable ? "Yes" : "No",
                    valueColor: entry.activity.billable ? Color("TreeShopGreen") : .gray
                )
                InfoRow(
                    label: "Safety Level", 
                    value: entry.activity.safetyLevel.rawValue,
                    valueColor: Color(entry.activity.safetyLevel.color)
                )
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white.opacity(0.03))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color(entry.activity.color).opacity(0.2), lineWidth: 1)
                )
        )
    }
    
    private var notesSection: some View {
        VStack(spacing: 16) {
            HStack {
                Image(systemName: "note.text")
                    .foregroundColor(Color("TreeShopGreen"))
                    .font(.title3)
                
                Text("Notes")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                
                Spacer()
            }
            
            TextField("Add notes about this activity...", text: $notes, axis: .vertical)
                .textFieldStyle(PlainTextFieldStyle())
                .foregroundColor(.white)
                .padding(12)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.white.opacity(0.05))
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.white.opacity(0.1), lineWidth: 1)
                        )
                )
                .lineLimit(3...)
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white.opacity(0.03))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.white.opacity(0.1), lineWidth: 1)
                )
        )
    }
    
    private var stopTimerSection: some View {
        VStack(spacing: 12) {
            Button(action: {
                showingStopConfirmation = true
            }) {
                HStack {
                    Image(systemName: "stop.circle.fill")
                    Text("Stop Timer")
                }
                .font(.headline)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(Color.red)
                .cornerRadius(12)
            }
            
            Text("Timer will stop and entry will be saved")
                .font(.caption)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
        }
        .padding(.horizontal, 20)
    }
    
    private var completedEntrySection: some View {
        VStack(spacing: 8) {
            HStack {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(Color("TreeShopGreen"))
                
                Text("Entry Completed")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
            }
            
            Text("This time entry has been completed and saved")
                .font(.caption)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
        }
        .padding(.vertical, 20)
    }
}

struct InfoRow: View {
    let label: String
    let value: String
    let valueColor: Color
    
    init(label: String, value: String, valueColor: Color = .white) {
        self.label = label
        self.value = value
        self.valueColor = valueColor
    }
    
    var body: some View {
        HStack {
            Text(label)
                .font(.subheadline)
                .foregroundColor(.gray)
            
            Spacer()
            
            Text(value)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(valueColor)
        }
    }
}

#Preview {
    NavigationView {
        BasicTimeTrackingView()
            .environmentObject(AppStateManager())
    }
}