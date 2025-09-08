import SwiftUI
import CoreLocation

struct BasicTimeTrackingView: View {
    @EnvironmentObject var appState: AppStateManager
    @StateObject private var timeTrackingManager = TimeTrackingManager()
    
    @State private var selectedEmployee: Employee?
    @State private var showingEmployeePicker = false
    
    var body: some View {
        ZStack {
            Color("TreeShopBlack").ignoresSafeArea()
            
            VStack(spacing: 20) {
                // Header
                headerSection
                
                // Employee selection
                employeeSection
                
                // Timer section
                if selectedEmployee != nil {
                    timerSection
                }
                
                // Today's entries
                entriesSection
                
                Spacer()
            }
            .padding(.horizontal, 20)
            .padding(.top, 2)
        }
        .navigationTitle("Time Tracking")
        .navigationBarTitleDisplayMode(.large)
        .sheet(isPresented: $showingEmployeePicker) {
            SimpleEmployeePickerView(
                employees: appState.employeeManager.employees,
                selectedEmployee: $selectedEmployee
            )
        }
    }
    
    private var headerSection: some View {
        HStack {
            Image(systemName: "timer")
                .foregroundColor(Color("TreeShopGreen"))
                .font(.title2)
            
            Text("Employee Time Tracking")
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(.white)
            
            Spacer()
            
            Text("\(timeTrackingManager.activeEntries.count) active")
                .font(.subheadline)
                .foregroundColor(Color("TreeShopGreen"))
        }
        .padding(.vertical, 20)
    }
    
    private var employeeSection: some View {
        VStack(spacing: 12) {
            HStack {
                Text("Select Employee")
                    .font(.headline)
                    .foregroundColor(.white)
                Spacer()
            }
            
            if let employee = selectedEmployee {
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
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(.white)
                        
                        Text(employee.qualificationCode)
                            .font(.caption)
                            .foregroundColor(Color("TreeShopGreen"))
                    }
                    
                    Spacer()
                    
                    Button("Change") {
                        selectedEmployee = nil
                    }
                    .font(.caption)
                    .foregroundColor(Color("TreeShopBlue"))
                }
                .padding(16)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.white.opacity(0.05))
                )
            } else {
                Button(action: {
                    showingEmployeePicker = true
                }) {
                    HStack {
                        Image(systemName: "person.crop.circle.badge.plus")
                            .font(.title2)
                            .foregroundColor(Color("TreeShopGreen"))
                        
                        Text("Choose Employee")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(.white)
                        
                        Spacer()
                        
                        Image(systemName: "chevron.right")
                            .foregroundColor(.gray)
                    }
                    .padding(16)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.white.opacity(0.05))
                    )
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white.opacity(0.03))
        )
    }
    
    private var timerSection: some View {
        VStack(spacing: 16) {
            if let employee = selectedEmployee {
                let activeEntry = timeTrackingManager.activeEntries.first { $0.employeeId == employee.id }
                
                if let active = activeEntry {
                    // Active timer display
                    VStack(spacing: 12) {
                        Text("TIMER RUNNING")
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundColor(Color("TreeShopGreen"))
                        
                        TimerDisplayView(entry: active)
                        
                        Button("STOP TIMER") {
                            timeTrackingManager.stopTimeEntry(active.id)
                        }
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color.red)
                        .cornerRadius(12)
                    }
                    .padding(20)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color("TreeShopGreen").opacity(0.1))
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(Color("TreeShopGreen"), lineWidth: 2)
                            )
                    )
                } else {
                    // Start timer button
                    Button("START TIMER") {
                        startTimer(for: employee)
                    }
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(.black)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(Color("TreeShopGreen"))
                    .cornerRadius(12)
                }
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white.opacity(0.03))
        )
    }
    
    private var entriesSection: some View {
        VStack(spacing: 12) {
            HStack {
                Text("Today's Entries")
                    .font(.headline)
                    .foregroundColor(.white)
                Spacer()
            }
            
            let todayEntries = getTodaysEntries()
            
            if todayEntries.isEmpty {
                Text("No entries today")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .padding(.vertical, 20)
            } else {
                ForEach(todayEntries.prefix(3), id: \.id) { entry in
                    SimpleEntryRow(entry: entry)
                }
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white.opacity(0.03))
        )
    }
    
    private func startTimer(for employee: Employee) {
        let workActivity = TimeTrackingActivity(
            name: "Work Time",
            category: .coreWork,
            billable: true,
            requiresLocation: true,
            requiresEquipment: false,
            safetyLevel: .medium,
            icon: "hammer.fill",
            color: "TreeShopGreen",
            allowedRoles: PrimaryRole.allCases,
            minimumTier: 1,
            requiredCertifications: [],
            requiredEquipment: [],
            requiredLeadership: nil
        )
        
        timeTrackingManager.startTimeEntry(
            employee: employee,
            activity: workActivity
        )
    }
    
    private func getTodaysEntries() -> [TimeEntry] {
        let calendar = Calendar.current
        return timeTrackingManager.timeEntries.filter { entry in
            calendar.isDate(entry.startTime, inSameDayAs: Date())
        }
    }
}

struct TimerDisplayView: View {
    let entry: TimeEntry
    @State private var currentTime = ""
    @State private var timer: Timer?
    
    var body: some View {
        Text(currentTime)
            .font(.largeTitle)
            .fontWeight(.bold)
            .foregroundColor(.white)
            .onAppear { startTimer() }
            .onDisappear { stopTimer() }
    }
    
    private func startTimer() {
        updateTime()
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            updateTime()
        }
    }
    
    private func stopTimer() {
        timer?.invalidate()
    }
    
    private func updateTime() {
        currentTime = entry.durationFormatted
    }
}

struct SimpleEntryRow: View {
    let entry: TimeEntry
    
    var body: some View {
        HStack {
            Text(entry.employeeName)
                .font(.subheadline)
                .foregroundColor(.white)
            
            Spacer()
            
            Text(entry.durationFormatted)
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(Color("TreeShopGreen"))
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.white.opacity(0.05))
        )
    }
}

struct SimpleEmployeePickerView: View {
    let employees: [Employee]
    @Binding var selectedEmployee: Employee?
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            ZStack {
                Color("TreeShopBlack").ignoresSafeArea()
                
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(employees) { employee in
                            SimpleEmployeeRow(employee: employee) {
                                selectedEmployee = employee
                                presentationMode.wrappedValue.dismiss()
                            }
                        }
                    }
                    .padding(20)
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
    }
}

struct SimpleEmployeeRow: View {
    let employee: Employee
    let onSelect: () -> Void
    
    var body: some View {
        Button(action: onSelect) {
            HStack(spacing: 16) {
                Circle()
                    .fill(Color("TreeShopGreen"))
                    .frame(width: 40, height: 40)
                    .overlay(
                        Text(employee.personalInfo.firstName.prefix(1))
                            .font(.headline)
                            .fontWeight(.bold)
                            .foregroundColor(.black)
                    )
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(employee.fullName)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.white)
                    
                    Text(employee.qualificationCode)
                        .font(.caption)
                        .foregroundColor(Color("TreeShopGreen"))
                }
                
                Spacer()
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.white.opacity(0.05))
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    NavigationView {
        BasicTimeTrackingView()
            .environmentObject(AppStateManager())
    }
}