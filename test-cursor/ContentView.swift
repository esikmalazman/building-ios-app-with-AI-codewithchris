//
//  ContentView.swift
//  test-cursor
//
//  Created by esikmalazman on 18/03/2026.
//

import SwiftUI

struct ContentView: View {
    // MARK: - State
    @State private var billAmount: String = ""
    @State private var billAmountError: String? = nil
    @State private var selectedTipPercentage: Int = 15
    @State private var numberOfPeople: Int = 2

    private let tipOptions = [10, 15, 20]
    private let defaultTipPercentage = 15

    // MARK: - Derived bill value
    var parsedBillAmount: Double {
        Double(billAmount) ?? 0
    }

    /// Returns the active tip percentage, falling back to the default if selection is somehow invalid.
    var activeTipPercentage: Int {
        tipOptions.contains(selectedTipPercentage) ? selectedTipPercentage : defaultTipPercentage
    }

    // MARK: - Calculations

    /// F-003: Tip amount = bill × tip% ÷ 100. Returns 0 when no bill is entered (D-001).
    var tipAmount: Double {
        guard parsedBillAmount > 0 else { return 0 }
        return parsedBillAmount * Double(activeTipPercentage) / 100
    }

    /// F-004: Total amount = bill + tip. Returns 0 if inputs are empty.
    var totalAmount: Double {
        guard parsedBillAmount > 0 else { return 0 }
        return parsedBillAmount + tipAmount
    }

    /// F-005: Safe people count — clamps to 1 if numberOfPeople is somehow below 1 (D-003).
    var safePeopleCount: Int {
        max(1, numberOfPeople)
    }

    /// F-006: Amount per person = total ÷ number of people.
    /// Returns totalAmount directly when safePeopleCount is 1 (avoids divide-by-zero and satisfies spec).
    var amountPerPerson: Double {
        guard totalAmount > 0 else { return 0 }
        guard safePeopleCount > 1 else { return totalAmount }
        return totalAmount / Double(safePeopleCount)
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {

                    // MARK: Bill Amount Section
                    SectionCard(title: "Bill Amount") {
                        VStack(alignment: .leading, spacing: 6) {
                            HStack {
                                Text("$")
                                    .font(.title2)
                                    .foregroundStyle(.secondary)
                                TextField("0.00", text: $billAmount)
                                    .font(.title2)
                                    .keyboardType(.decimalPad)
                                    .onChange(of: billAmount) { _, newValue in
                                        billAmount = sanitizeBillInput(newValue, previous: billAmount)
                                    }
                            }
                            .padding(.horizontal, 4)

                            if let error = billAmountError {
                                Text(error)
                                    .font(.caption)
                                    .foregroundStyle(.red)
                                    .padding(.horizontal, 4)
                                    .transition(.opacity)
                            }
                        }
                        .animation(.easeInOut(duration: 0.2), value: billAmountError)
                    }

                    // MARK: Tip Percentage Section
                    SectionCard(title: "Tip Percentage") {
                        VStack(alignment: .leading, spacing: 10) {
                            Picker("Tip Percentage", selection: $selectedTipPercentage) {
                                ForEach(tipOptions, id: \.self) { percentage in
                                    Text("\(percentage)%").tag(percentage)
                                }
                            }
                            .pickerStyle(.segmented)

                            Text("Selected: \(activeTipPercentage)%")
                                .font(.footnote)
                                .foregroundStyle(.secondary)
                        }
                    }

                    // MARK: Summary Section
                    SectionCard(title: "Summary") {
                        VStack(spacing: 16) {
                            SummaryRow(label: "Tip Amount", value: tipAmount)
                            Divider()
                            SummaryRow(label: "Total Amount", value: totalAmount)
                                .fontWeight(.semibold)
                        }
                    }

                    // MARK: Split Bill Section
                    SectionCard(title: "Split Bill") {
                        VStack(spacing: 16) {
                            HStack {
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("Number of People")
                                        .foregroundStyle(.primary)
                                    Text(safePeopleCount == 1 ? "1 person" : "\(safePeopleCount) people")
                                        .font(.footnote)
                                        .foregroundStyle(.secondary)
                                }
                                Spacer()
                                Stepper(
                                    value: $numberOfPeople,
                                    in: 1...20
                                ) {
                                    EmptyView()
                                }
                                .onChange(of: numberOfPeople) { _, newValue in
                                    if newValue < 1 { numberOfPeople = 1 }
                                }
                                .labelsHidden()
                            }
                            Divider()
                            SummaryRow(label: "Per Person", value: amountPerPerson)
                                .fontWeight(.semibold)
                        }
                    }

                }
                .padding(.horizontal)
                .padding(.vertical, 12)
            }
            .navigationTitle("Tip Calculator")
            .background(Color(.systemGroupedBackground))
        }
    }
    // MARK: - Bill Input Validation

    /// Strips non-numeric characters (letters, symbols) from bill input.
    /// Allows digits and a single decimal point only.
    /// Sets `billAmountError` when invalid characters are removed.
    private func sanitizeBillInput(_ input: String, previous: String) -> String {
        let allowedCharacters = CharacterSet.decimalDigits.union(CharacterSet(charactersIn: "."))
        let filtered = input.unicodeScalars
            .filter { allowedCharacters.contains($0) }
            .map(Character.init)

        let result = enforceOneDecimalPoint(String(filtered))

        if result != input {
            billAmountError = "Enter numbers only"
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                billAmountError = nil
            }
        }

        return result
    }

    /// Ensures the string contains at most one decimal point.
    private func enforceOneDecimalPoint(_ input: String) -> String {
        let parts = input.components(separatedBy: ".")
        guard parts.count > 2 else { return input }
        return parts[0] + "." + parts[1...].joined()
    }
}

// MARK: - Reusable Components

private struct SectionCard<Content: View>: View {
    let title: String
    @ViewBuilder let content: () -> Content

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.headline)
                .foregroundStyle(.secondary)
                .textCase(.uppercase)
                .tracking(0.5)
            VStack(spacing: 0) {
                content()
            }
            .padding()
            .background(Color(.secondarySystemGroupedBackground))
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }
}

private struct SummaryRow: View {
    let label: String
    let value: Double

    var body: some View {
        HStack {
            Text(label)
                .foregroundStyle(.primary)
            Spacer()
            Text(value, format: .currency(code: "USD"))
                .font(.title3)
                .foregroundStyle(.primary)
        }
    }
}

#Preview {
    ContentView()
}
