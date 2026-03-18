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
                VStack(spacing: 28) {

                    // MARK: Bill Amount Section
                    SectionCard(title: "Bill Amount") {
                        VStack(alignment: .leading, spacing: 8) {
                            HStack(alignment: .firstTextBaseline, spacing: 4) {
                                Text("$")
                                    .font(.system(size: 32, weight: .semibold, design: .rounded))
                                    .foregroundStyle(.secondary)
                                TextField("0.00", text: $billAmount)
                                    .font(.system(size: 48, weight: .bold, design: .rounded))
                                    .keyboardType(.decimalPad)
                                    .focused($billFieldFocused)
                                    .onChange(of: billAmount) { _, newValue in
                                        billAmount = sanitizeBillInput(newValue, previous: billAmount)
                                    }
                            }
                            .padding(.horizontal, 4)

                            if let error = billAmountError {
                                Label(error, systemImage: "exclamationmark.circle.fill")
                                    .font(.caption)
                                    .foregroundStyle(.red)
                                    .padding(.horizontal, 4)
                                    .transition(.move(edge: .top).combined(with: .opacity))
                            }
                        }
                        .animation(.spring(response: 0.3, dampingFraction: 0.8), value: billAmountError)
                    }

                    // MARK: Tip Percentage Section
                    SectionCard(title: "Tip Percentage") {
                        Picker("Tip Percentage", selection: $selectedTipPercentage) {
                            ForEach(tipOptions, id: \.self) { percentage in
                                Text("\(percentage)%")
                                    .font(.system(.body, design: .rounded, weight: .medium))
                                    .tag(percentage)
                            }
                        }
                        .pickerStyle(.segmented)
                    }

                    // MARK: Results Section
                    SectionCard(title: "Results") {
                        if billIsEmpty {
                            Text("Enter a bill amount above to see your totals.")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                                .multilineTextAlignment(.center)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 8)
                        } else {
                            HStack(spacing: 12) {
                                ResultCard(label: "Tip", value: tipAmount, highlighted: false)
                                ResultCard(label: "Total", value: totalAmount, highlighted: true)
                            }
                        }
                    }
                    .animation(.spring(response: 0.35, dampingFraction: 0.85), value: billIsEmpty)

                    // MARK: Split Bill Section
                    SectionCard(title: "Split Bill") {
                        VStack(spacing: 20) {
                            HStack {
                                VStack(alignment: .leading, spacing: 3) {
                                    Text("Number of People")
                                        .font(.body)
                                        .foregroundStyle(.primary)
                                    Text(safePeopleCount == 1 ? "1 person" : "\(safePeopleCount) people")
                                        .font(.footnote)
                                        .foregroundStyle(.secondary)
                                }
                                Spacer()
                                Stepper(value: $numberOfPeople, in: 1...20) {
                                    EmptyView()
                                }
                                .onChange(of: numberOfPeople) { _, newValue in
                                    if newValue < 1 { numberOfPeople = 1 }
                                }
                                .labelsHidden()
                            }

                            if !billIsEmpty {
                                Divider()

                                VStack(spacing: 4) {
                                    Text(safePeopleCount == 1 ? "You pay" : "Each person pays")
                                        .font(.subheadline)
                                        .foregroundStyle(.secondary)
                                    Text(amountPerPerson, format: .currency(code: "USD"))
                                        .font(.system(size: 40, weight: .bold, design: .rounded))
                                        .foregroundStyle(.tint)
                                        .contentTransition(.numericText())
                                        .animation(.spring(response: 0.3, dampingFraction: 0.8), value: amountPerPerson)
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 4)
                            }
                        }
                        .animation(.spring(response: 0.35, dampingFraction: 0.85), value: billIsEmpty)
                    }

                }
                .padding(.horizontal)
                .padding(.vertical, 16)
            }
            .navigationTitle("Tip Calculator")
            .navigationBarTitleDisplayMode(.large)
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
                    .fontWeight(.semibold)
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
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.system(.subheadline, design: .default, weight: .semibold))
                .foregroundStyle(.secondary)
                .textCase(.uppercase)
                .tracking(0.6)
            content()
                .padding()
                .background(Color(.secondarySystemGroupedBackground))
                .clipShape(RoundedRectangle(cornerRadius: 16))
        }
    }
}

private struct ResultCard: View {
    let label: String
    let value: Double
    let highlighted: Bool

    var body: some View {
        VStack(spacing: 6) {
            Text(label)
                .font(.system(.subheadline, design: .rounded, weight: .medium))
                .foregroundStyle(.secondary)
            Text(value, format: .currency(code: "USD"))
                .font(.system(size: 26, weight: .bold, design: .rounded))
                .foregroundStyle(highlighted ? Color.accentColor : .primary)
                .contentTransition(.numericText())
                .animation(.spring(response: 0.3, dampingFraction: 0.8), value: value)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(
            highlighted
                ? Color.accentColor.opacity(0.1)
                : Color(.secondarySystemGroupedBackground)
        )
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .overlay(
            highlighted
                ? RoundedRectangle(cornerRadius: 14).stroke(Color.accentColor.opacity(0.25), lineWidth: 1)
                : nil
        )
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
