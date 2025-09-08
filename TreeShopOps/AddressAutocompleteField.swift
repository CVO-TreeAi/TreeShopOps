import SwiftUI
import MapKit
import Combine

struct AddressResult {
    let fullAddress: String
    let street: String
    let city: String
    let state: String
    let zipCode: String
    let coordinate: CLLocationCoordinate2D?
}

struct AddressAutocompleteField: View {
    @Binding var result: AddressResult?
    let placeholder: String
    let onAddressSelected: (AddressResult) -> Void
    
    @State private var searchText = ""
    @State private var completions: [MKLocalSearchCompletion] = []
    @State private var isSearching = false
    @StateObject private var searchCompleter = AddressSearchCompleter()
    
    init(result: Binding<AddressResult?>, 
         placeholder: String = "Search address...",
         onAddressSelected: @escaping (AddressResult) -> Void = { _ in }) {
        self._result = result
        self.placeholder = placeholder
        self.onAddressSelected = onAddressSelected
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Search field
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.gray)
                    .font(.system(size: 16))
                
                TextField(placeholder, text: $searchText)
                    .textFieldStyle(PlainTextFieldStyle())
                    .foregroundColor(.white)
                    .onChange(of: searchText) { newValue in
                        searchCompleter.search(newValue)
                    }
                
                if isSearching {
                    ProgressView()
                        .scaleEffect(0.8)
                        .progressViewStyle(CircularProgressViewStyle(tint: Color("TreeShopGreen")))
                } else if !searchText.isEmpty {
                    Button(action: {
                        searchText = ""
                        completions = []
                        result = nil
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.gray)
                    }
                }
            }
            .padding(12)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.white.opacity(0.05))
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.white.opacity(0.1), lineWidth: 1)
                    )
            )
            
            // Results dropdown
            if !completions.isEmpty && !searchText.isEmpty && result == nil {
                VStack(spacing: 0) {
                    ForEach(Array(completions.prefix(5).enumerated()), id: \.offset) { index, completion in
                        AddressCompletionRow(completion: completion) {
                            selectAddress(completion)
                        }
                        
                        if index < min(4, completions.count - 1) {
                            Divider()
                                .background(Color.white.opacity(0.1))
                        }
                    }
                }
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.white.opacity(0.08))
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.white.opacity(0.1), lineWidth: 1)
                        )
                )
                .padding(.top, 4)
            }
            
            // Selected address display
            if let selectedResult = result {
                HStack {
                    Image(systemName: "location.fill")
                        .foregroundColor(Color("TreeShopGreen"))
                        .font(.system(size: 14))
                    
                    Text(selectedResult.fullAddress)
                        .font(.subheadline)
                        .foregroundColor(.white)
                        .lineLimit(2)
                    
                    Spacer()
                    
                    Button("Change") {
                        result = nil
                        searchText = ""
                        completions = []
                    }
                    .font(.caption)
                    .foregroundColor(Color("TreeShopBlue"))
                }
                .padding(12)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color("TreeShopGreen").opacity(0.1))
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color("TreeShopGreen").opacity(0.2), lineWidth: 1)
                        )
                )
                .padding(.top, 4)
            }
        }
        .onReceive(searchCompleter.$completions) { newCompletions in
            withAnimation(.easeInOut(duration: 0.2)) {
                completions = newCompletions
                isSearching = false
            }
        }
        .onReceive(searchCompleter.$isSearching) { searching in
            isSearching = searching
        }
    }
    
    private func selectAddress(_ completion: MKLocalSearchCompletion) {
        isSearching = true
        searchText = completion.title
        
        let request = MKLocalSearch.Request(completion: completion)
        let search = MKLocalSearch(request: request)
        
        search.start { response, error in
            DispatchQueue.main.async {
                isSearching = false
                
                guard let response = response,
                      let mapItem = response.mapItems.first else {
                    return
                }
                
                let placemark = mapItem.placemark
                let addressResult = AddressResult(
                    fullAddress: "\(placemark.name ?? "") \(placemark.thoroughfare ?? "") \(placemark.locality ?? ""), \(placemark.administrativeArea ?? "") \(placemark.postalCode ?? "")",
                    street: "\(placemark.name ?? "") \(placemark.thoroughfare ?? "")".trimmingCharacters(in: .whitespaces),
                    city: placemark.locality ?? "",
                    state: placemark.administrativeArea ?? "",
                    zipCode: placemark.postalCode ?? "",
                    coordinate: placemark.coordinate
                )
                
                result = addressResult
                completions = []
                onAddressSelected(addressResult)
            }
        }
    }
}

struct AddressCompletionRow: View {
    let completion: MKLocalSearchCompletion
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 12) {
                Image(systemName: "location.circle.fill")
                    .foregroundColor(Color("TreeShopGreen"))
                    .font(.system(size: 16))
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(completion.title)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.white)
                        .lineLimit(1)
                    
                    if !completion.subtitle.isEmpty {
                        Text(completion.subtitle)
                            .font(.caption)
                            .foregroundColor(.gray)
                            .lineLimit(1)
                    }
                }
                
                Spacer()
                
                Image(systemName: "arrow.up.left.and.arrow.down.right")
                    .foregroundColor(.gray)
                    .font(.system(size: 12))
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .contentShape(Rectangle())
        }
        .buttonStyle(PlainButtonStyle())
    }
}

class AddressSearchCompleter: NSObject, ObservableObject, MKLocalSearchCompleterDelegate {
    @Published var completions: [MKLocalSearchCompletion] = []
    @Published var isSearching = false
    
    private let completer = MKLocalSearchCompleter()
    private var searchTimer: Timer?
    
    override init() {
        super.init()
        completer.delegate = self
        completer.resultTypes = .address
        completer.region = MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 39.8283, longitude: -98.5795), // Center of US
            span: MKCoordinateSpan(latitudeDelta: 50, longitudeDelta: 50)
        )
    }
    
    func search(_ query: String) {
        searchTimer?.invalidate()
        
        guard !query.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            completions = []
            isSearching = false
            return
        }
        
        isSearching = true
        
        searchTimer = Timer.scheduledTimer(withTimeInterval: 0.3, repeats: false) { _ in
            DispatchQueue.main.async {
                self.completer.queryFragment = query
            }
        }
    }
    
    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        DispatchQueue.main.async {
            self.completions = completer.results
            self.isSearching = false
        }
    }
    
    func completer(_ completer: MKLocalSearchCompleter, didFailWithError error: Error) {
        DispatchQueue.main.async {
            self.isSearching = false
            print("Address search error: \(error.localizedDescription)")
        }
    }
}