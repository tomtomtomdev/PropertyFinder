import SwiftUI

struct FilterSheetView: View {
    @Bindable var viewModel: SearchViewModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            Form {
                Section("Property Type") {
                    Picker("Type", selection: $viewModel.selectedType) {
                        Text("Any").tag(Property.PropertyType?.none)
                        ForEach(Property.PropertyType.allCases, id: \.self) { type in
                            Text(type.rawValue.capitalized).tag(Optional(type))
                        }
                    }
                    .pickerStyle(.segmented)
                }

                Section("Purpose") {
                    Picker("Purpose", selection: $viewModel.selectedPurpose) {
                        Text("Any").tag(Property.PropertyPurpose?.none)
                        ForEach(Property.PropertyPurpose.allCases, id: \.self) { purpose in
                            Text(purpose.rawValue.capitalized).tag(Optional(purpose))
                        }
                    }
                    .pickerStyle(.segmented)
                }

                Section("Price Range (AED)") {
                    HStack {
                        TextField("Min Price", value: $viewModel.minPrice, format: .number)
                            .textFieldStyle(.roundedBorder)
                            .keyboardType(.numberPad)
                        Text("to")
                            .foregroundStyle(.secondary)
                        TextField("Max Price", value: $viewModel.maxPrice, format: .number)
                            .textFieldStyle(.roundedBorder)
                            .keyboardType(.numberPad)
                    }
                }

                Section("Bedrooms") {
                    Picker("Minimum Bedrooms", selection: $viewModel.minBedrooms) {
                        Text("Any").tag(Int?.none)
                        ForEach(0..<8, id: \.self) { count in
                            Text(count == 0 ? "Studio" : "\(count)+").tag(Optional(count))
                        }
                    }
                }

                Section("Location") {
                    Picker("Location", selection: $viewModel.selectedLocation) {
                        Text("Any").tag(String?.none)
                        ForEach(FilterOptions.default.availableLocations, id: \.self) { location in
                            Text(location).tag(Optional(location))
                        }
                    }
                }

                Section {
                    Button("Clear All Filters", role: .destructive) {
                        viewModel.clearFilters()
                    }
                }
            }
            .navigationTitle("Filters")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Apply") { viewModel.applyFilters() }
                        .bold()
                }
            }
        }
    }
}
