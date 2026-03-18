//
//  ContentView.swift
//  test-cursor
//
//  Created by esikmalazman on 18/03/2026.
//

import SwiftUI

struct ContentView: View {

    @State private var viewModel = TipCalculatorViewModel()
    @FocusState private var isBillFieldFocused: Bool

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 28) {
                    billSection
                    tipSection
                    resultsSection
                    splitSection
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
}

// MARK: - Sections

private extension ContentView {

    @ViewBuilder
    var billSection: some View {
        @Bindable var vm = viewModel

        SectionCard(title: "Bill Amount") {
            VStack(alignment: .leading, spacing: 8) {
                HStack(alignment: .firstTextBaseline, spacing: 4) {
                    Text("$")
                        .font(.system(size: 32, weight: .semibold, design: .rounded))
                        .foregroundStyle(.secondary)
                    TextField("0.00", text: $vm.billAmount)
                        .font(.system(size: 48, weight: .bold, design: .rounded))
                        .keyboardType(.decimalPad)
                        .focused($isBillFieldFocused)
                        .onChange(of: vm.billAmount) { _, newValue in
                            viewModel.handleBillInput(newValue)
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

    @ViewBuilder
    var tipSection: some View {
        @Bindable var vm = viewModel

        SectionCard(title: "Tip Percentage") {
            Picker("Tip Percentage", selection: $vm.selectedTipPercentage) {
                ForEach(TipCalculator.tipOptions, id: \.self) { percentage in
                    Text("\(percentage)%")
                        .font(.system(.body, design: .rounded, weight: .medium))
                        .tag(percentage)
                }
            }
            .pickerStyle(.segmented)
        }
    }

    var resultsSection: some View {
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
                    ResultCard(label: "Tip",   value: viewModel.tipAmount,   highlighted: false)
                    ResultCard(label: "Total", value: viewModel.totalAmount, highlighted: true)
                }
            }
        }
        .animation(.spring(response: 0.35, dampingFraction: 0.85), value: viewModel.billIsEmpty)
    }

    @ViewBuilder
    var splitSection: some View {
        @Bindable var vm = viewModel

        SectionCard(title: "Split Bill") {
            VStack(spacing: 20) {
                HStack {
                    VStack(alignment: .leading, spacing: 3) {
                        Text("Number of People")
                            .font(.body)
                        Text(viewModel.safePeopleCount == 1 ? "1 person" : "\(viewModel.safePeopleCount) people")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                    Stepper(value: $vm.numberOfPeople, in: 1...20) { EmptyView() }
                        .labelsHidden()
                }

                if !viewModel.billIsEmpty {
                    Divider()

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
            }
            .animation(.spring(response: 0.35, dampingFraction: 0.85), value: viewModel.billIsEmpty)
        }
    }

    @ToolbarContentBuilder
    var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .topBarTrailing) {
            Button("Reset") {
                viewModel.reset()
                isBillFieldFocused = false
            }
            .disabled(viewModel.isAtDefaults)
        }
        ToolbarItemGroup(placement: .keyboard) {
            Spacer()
            Button("Done") { isBillFieldFocused = false }
                .fontWeight(.semibold)
        }
    }
}

// MARK: - Components

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
