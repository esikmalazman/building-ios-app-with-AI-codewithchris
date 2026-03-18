//
//  ContentView.swift
//  test-cursor
//
//  Created by esikmalazman on 18/03/2026.
//

import SwiftUI

struct ContentView: View {

    // MARK: - Dependencies

    @State private var viewModel = TipCalculatorViewModel()
    @FocusState private var billFieldFocused: Bool

    // MARK: - Body

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 28) {
                    billAmountSection
                    tipPercentageSection
                    resultsSection
                    splitBillSection
                }
                .padding(.horizontal)
                .padding(.vertical, 16)
            }
            .navigationTitle("Tip Calculator")
            .navigationBarTitleDisplayMode(.large)
            .background(Color(.systemGroupedBackground))
            .toolbar { toolbarContent }
        }
    }

    // MARK: - Sections

    private var billAmountSection: some View {
        SectionCard(title: "Bill Amount") {
            VStack(alignment: .leading, spacing: 8) {
                HStack(alignment: .firstTextBaseline, spacing: 4) {
                    Text("$")
                        .font(.system(size: 32, weight: .semibold, design: .rounded))
                        .foregroundStyle(.secondary)

                    TextField("0.00", text: $viewModel.billAmount)
                        .font(.system(size: 48, weight: .bold, design: .rounded))
                        .keyboardType(.decimalPad)
                        .focused($billFieldFocused)
                        .onChange(of: viewModel.billAmount) { _, newValue in
                            viewModel.updateBillAmount(newValue)
                        }
                }
                .padding(.horizontal, 4)

                if let error = viewModel.billAmountError {
                    Label(error, systemImage: "exclamationmark.circle.fill")
                        .font(.caption)
                        .foregroundStyle(.red)
                        .padding(.horizontal, 4)
                        .transition(.move(edge: .top).combined(with: .opacity))
                }
            }
            .animation(.spring(response: 0.3, dampingFraction: 0.8), value: viewModel.billAmountError)
        }
    }

    private var tipPercentageSection: some View {
        SectionCard(title: "Tip Percentage") {
            Picker("Tip Percentage", selection: $viewModel.selectedTipPercentage) {
                ForEach(TipCalculator.tipOptions, id: \.self) { percentage in
                    Text("\(percentage)%")
                        .font(.system(.body, design: .rounded, weight: .medium))
                        .tag(percentage)
                }
            }
            .pickerStyle(.segmented)
        }
    }

    private var resultsSection: some View {
        SectionCard(title: "Results") {
            if viewModel.billIsEmpty {
                Text("Enter a bill amount above to see your totals.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
            } else {
                HStack(spacing: 12) {
                    ResultCard(label: "Tip", value: viewModel.tipAmount, highlighted: false)
                    ResultCard(label: "Total", value: viewModel.totalAmount, highlighted: true)
                }
            }
        }
        .animation(.spring(response: 0.35, dampingFraction: 0.85), value: viewModel.billIsEmpty)
    }

    private var splitBillSection: some View {
        SectionCard(title: "Split Bill") {
            VStack(spacing: 20) {
                peopleStepper

                if !viewModel.billIsEmpty {
                    Divider()
                    perPersonResult
                }
            }
            .animation(.spring(response: 0.35, dampingFraction: 0.85), value: viewModel.billIsEmpty)
        }
    }

    private var peopleStepper: some View {
        HStack {
            VStack(alignment: .leading, spacing: 3) {
                Text("Number of People")
                    .font(.body)
                Text(viewModel.safePeopleCount == 1 ? "1 person" : "\(viewModel.safePeopleCount) people")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Stepper(value: $viewModel.numberOfPeople, in: 1...20) {
                EmptyView()
            }
            .onChange(of: viewModel.numberOfPeople) { _, newValue in
                if newValue < 1 { viewModel.numberOfPeople = 1 }
            }
            .labelsHidden()
        }
    }

    private var perPersonResult: some View {
        VStack(spacing: 4) {
            Text(viewModel.safePeopleCount == 1 ? "You pay" : "Each person pays")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            Text(viewModel.amountPerPerson, format: .currency(code: "USD"))
                .font(.system(size: 40, weight: .bold, design: .rounded))
                .foregroundStyle(.tint)
                .contentTransition(.numericText())
                .animation(.spring(response: 0.3, dampingFraction: 0.8), value: viewModel.amountPerPerson)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 4)
    }

    // MARK: - Toolbar

    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .topBarTrailing) {
            Button("Reset", action: viewModel.reset)
                .disabled(viewModel.isResetDisabled)
        }

        ToolbarItemGroup(placement: .keyboard) {
            Spacer()
            Button("Done") { billFieldFocused = false }
                .fontWeight(.semibold)
        }
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
        .background(highlighted ? Color.accentColor.opacity(0.1) : Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .overlay {
            if highlighted {
                RoundedRectangle(cornerRadius: 14)
                    .stroke(Color.accentColor.opacity(0.25), lineWidth: 1)
            }
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
