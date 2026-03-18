//
//  ContentView.swift
//  test-cursor
//
//  Created by esikmalazman on 18/03/2026.
//

import SwiftUI

struct ContentView: View {
    // MARK: - Persisted state (D-004: saved across launches via UserDefaults)
    @AppStorage("lastBillAmount") private var billAmount: String = ""
    @AppStorage("lastTipPercentage") private var selectedTipPercentage: Int = 15
    @AppStorage("lastNumberOfPeople") private var numberOfPeople: Int = 2

    // MARK: - Transient state
    @State private var billAmountError: String? = nil
    @FocusState private var billFieldFocused: Bool

    private let tipOptions = TipCalculator.tipOptions
    private let defaultTipPercentage = TipCalculator.defaultTipPercentage

    // MARK: - Derived values (delegated to TipCalculator)

    var parsedBillAmount: Double { TipCalculator.parseBillAmount(billAmount) }
    var billIsEmpty: Bool { parsedBillAmount == 0 }
    var activeTipPercentage: Int { TipCalculator.safeTipPercentage(selectedTipPercentage) }
    var safePeopleCount: Int { TipCalculator.safePeopleCount(numberOfPeople) }

    var tipAmount: Double {
        TipCalculator.tipAmount(bill: parsedBillAmount, tipPercentage: selectedTipPercentage)
    }
    var totalAmount: Double {
        TipCalculator.totalAmount(bill: parsedBillAmount, tipPercentage: selectedTipPercentage)
    }
    var amountPerPerson: Double {
        TipCalculator.amountPerPerson(bill: parsedBillAmount, tipPercentage: selectedTipPercentage, numberOfPeople: numberOfPeople)
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
                                    .focused($billFieldFocused)
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
                            if billIsEmpty {
                                Text("Enter a bill amount above to see your totals.")
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                                    .frame(maxWidth: .infinity, alignment: .center)
                                    .padding(.vertical, 4)
                            } else {
                                SummaryRow(label: "Tip Amount", value: tipAmount)
                                Divider()
                                SummaryRow(label: "Total Amount", value: totalAmount)
                                    .fontWeight(.semibold)
                            }
                        }
                        .animation(.easeInOut(duration: 0.2), value: billIsEmpty)
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
                            if billIsEmpty {
                                Text("Enter a bill amount to calculate the split.")
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                                    .frame(maxWidth: .infinity, alignment: .center)
                                    .padding(.vertical, 4)
                            } else {
                                SummaryRow(label: "Per Person", value: amountPerPerson)
                                    .fontWeight(.semibold)
                            }
                        }
                        .animation(.easeInOut(duration: 0.2), value: billIsEmpty)
                    }

                }
                .padding(.horizontal)
                .padding(.vertical, 12)
            }
            .navigationTitle("Tip Calculator")
            .background(Color(.systemGroupedBackground))
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Reset") {
                        resetToDefaults()
                    }
                    .disabled(billIsEmpty && selectedTipPercentage == defaultTipPercentage && numberOfPeople == 2)
                }
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    Button("Done") {
                        billFieldFocused = false
                    }
                }
            }
        }
    }
    // MARK: - Reset

    private func resetToDefaults() {
        billFieldFocused = false
        billAmount = ""
        selectedTipPercentage = defaultTipPercentage
        numberOfPeople = 2
        billAmountError = nil
    }

    // MARK: - Bill Input Validation

    private func sanitizeBillInput(_ input: String, previous: String) -> String {
        let result = TipCalculator.sanitizeBillInput(input)
        if result != input {
            billAmountError = "Enter numbers only"
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                billAmountError = nil
            }
        }
        return result
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

// MARK: - Previews

#Preview("Empty State") {
    ContentView()
}

#Preview("Standard — $50, 15%, 2 people") {
    let _ = UserDefaults.standard.set("50", forKey: "lastBillAmount")
    let _ = UserDefaults.standard.set(15, forKey: "lastTipPercentage")
    let _ = UserDefaults.standard.set(2, forKey: "lastNumberOfPeople")
    return ContentView()
}

#Preview("Large Bill — $200, 20%, 4 people") {
    let _ = UserDefaults.standard.set("200", forKey: "lastBillAmount")
    let _ = UserDefaults.standard.set(20, forKey: "lastTipPercentage")
    let _ = UserDefaults.standard.set(4, forKey: "lastNumberOfPeople")
    return ContentView()
}

#Preview("Solo — $35.50, 10%, 1 person") {
    let _ = UserDefaults.standard.set("35.50", forKey: "lastBillAmount")
    let _ = UserDefaults.standard.set(10, forKey: "lastTipPercentage")
    let _ = UserDefaults.standard.set(1, forKey: "lastNumberOfPeople")
    return ContentView()
}
