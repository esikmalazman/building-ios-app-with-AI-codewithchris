//
//  ContentView.swift
//  test-cursor
//
//  Created by esikmalazman on 18/03/2026.
//

import SwiftUI

// MARK: - Design System

private enum DS {
    /// Wise / Cash App signature green
    static let accent = Color(red: 0.0, green: 0.78, blue: 0.35)
    static let cardRadius: CGFloat = 16
    static let labelFont = Font.system(size: 11, weight: .bold)
    static let labelTracking: CGFloat = 1.8

    enum Anim {
        /// Numeric value updates — clean roll, zero bounce.
        static let value: Animation  = .smooth(duration: 0.2)
        /// Structural reveal / hide — decelerates into place, no overshoot.
        static let reveal: Animation = .easeOut(duration: 0.25)
        /// Immediate interactive feedback (selection, button state).
        static let snap: Animation   = .snappy(duration: 0.18)
    }
}

struct ContentView: View {

    // MARK: - Dependencies

    @State private var viewModel = TipCalculatorViewModel()
    @FocusState private var billFieldFocused: Bool

    // MARK: - Body

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    inputCard
                    resultHero
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 16)
            }
            .navigationTitle("Tip Calculator")
            .navigationBarTitleDisplayMode(.large)
            .background(Color(.systemGroupedBackground))
            .toolbar { toolbarContent }
        }
    }

    // MARK: - Cards

    /// Inputs: bill amount + tip selector in one card.
    /// These are controls — they recede so the result can dominate.
    private var inputCard: some View {
        VStack(alignment: .leading, spacing: 0) {
            rowLabel("Bill Amount")
                .padding(.bottom, 10)

            HStack(alignment: .firstTextBaseline, spacing: 2) {
                Text("$")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundStyle(.primary.opacity(0.3))

                TextField("0.00", text: $viewModel.billAmount)
                    .font(.system(size: 54, weight: .black).monospacedDigit())
                    .keyboardType(.decimalPad)
                    .focused($billFieldFocused)
                    .onChange(of: viewModel.billAmount) { _, newValue in
                        viewModel.updateBillAmount(newValue)
                    }
            }

            if let error = viewModel.billAmountError {
                Label(error, systemImage: "exclamationmark.circle.fill")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(.red)
                    .padding(.top, 6)
                    .transition(.opacity)
            }

            Rectangle()
                .fill(Color.primary.opacity(0.07))
                .frame(height: 1)
                .padding(.vertical, 20)

            rowLabel("Tip")
                .padding(.bottom, 10)

            HStack(spacing: 8) {
                ForEach(TipCalculator.tipOptions, id: \.self) { percentage in
                    TipButton(
                        label: "\(percentage)%",
                        isSelected: viewModel.selectedTipPercentage == percentage
                    ) {
                        viewModel.selectedTipPercentage = percentage
                    }
                }
            }
        }
        .padding(20)
        .card()
        .animation(DS.Anim.reveal, value: viewModel.billAmountError != nil)
    }

    /// The result card. Configure split first, then read the answer below it.
    private var resultHero: some View {
        VStack(spacing: 0) {

            // Step 1 — configure split count before the answer is shown.
            VStack(alignment: .leading, spacing: 14) {
                rowLabel("Split Between")

                HStack {
                    stepperButton(systemImage: "minus", isDisabled: viewModel.numberOfPeople <= 1) {
                        if viewModel.numberOfPeople > 1 { viewModel.numberOfPeople -= 1 }
                    }

                    Spacer()

                    Text(viewModel.safePeopleCount == 1 ? "1 person" : "\(viewModel.safePeopleCount) people")
                        .font(.system(size: 17, weight: .semibold).monospacedDigit())
                        .contentTransition(.numericText())
                        .animation(DS.Anim.value, value: viewModel.numberOfPeople)

                    Spacer()

                    stepperButton(systemImage: "plus", isDisabled: viewModel.numberOfPeople >= 20) {
                        if viewModel.numberOfPeople < 20 { viewModel.numberOfPeople += 1 }
                    }
                }
            }
            .padding(20)

            Rectangle()
                .fill(Color.primary.opacity(0.07))
                .frame(height: 1)

            // Step 2 — the payoff. The number is already correct for the split above.
            VStack(spacing: 6) {
                rowLabel(viewModel.safePeopleCount == 1 ? "You Pay" : "Each Person Pays")
                    .id(viewModel.safePeopleCount == 1)
                    .transition(.opacity)
                    .animation(DS.Anim.reveal, value: viewModel.safePeopleCount == 1)

                Group {
                    if viewModel.billIsEmpty {
                        Text("—")
                            .foregroundStyle(.primary.opacity(0.12))
                            .transition(.opacity)
                    } else {
                        Text(viewModel.amountPerPerson, format: .currency(code: "USD"))
                            .foregroundStyle(DS.accent)
                            .contentTransition(.numericText())
                            .animation(DS.Anim.value, value: viewModel.amountPerPerson)
                            .transition(.opacity)
                    }
                }
                .font(.system(size: 58, weight: .black).monospacedDigit())
                .animation(DS.Anim.reveal, value: viewModel.billIsEmpty)
            }
            .frame(maxWidth: .infinity)
            .padding(.top, 28)
            .padding(.bottom, 24)

            // Step 3 — breakdown. Always rendered; opacity-only keeps card height stable.
            Rectangle()
                .fill(Color.primary.opacity(viewModel.billIsEmpty ? 0 : 0.07))
                .frame(height: 1)
                .animation(DS.Anim.reveal, value: viewModel.billIsEmpty)

            HStack(spacing: 0) {
                statCell(label: "Tip", value: viewModel.tipAmount)
                    .padding(.leading, 20)
                Rectangle()
                    .fill(Color.primary.opacity(viewModel.billIsEmpty ? 0 : 0.07))
                    .frame(width: 1)
                    .animation(DS.Anim.reveal, value: viewModel.billIsEmpty)
                statCell(label: "Total", value: viewModel.totalAmount)
                    .padding(.leading, 20)
            }
            .opacity(viewModel.billIsEmpty ? 0 : 1)
            .animation(DS.Anim.reveal, value: viewModel.billIsEmpty)
        }
        .card()
    }

    // MARK: - Helpers

    private func rowLabel(_ text: String) -> some View {
        Text(text.uppercased())
            .font(DS.labelFont)
            .foregroundStyle(.secondary)
            .tracking(DS.labelTracking)
    }

    private func statCell(label: String, value: Double) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label.uppercased())
                .font(DS.labelFont)
                .tracking(DS.labelTracking)
                .foregroundStyle(.secondary)
            Text(value, format: .number.precision(.fractionLength(2)))
                .font(.system(size: 17, weight: .medium).monospacedDigit())
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.vertical, 12)
    }

    private func stepperButton(systemImage: String, isDisabled: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: systemImage)
                .font(.system(size: 14, weight: .bold))
                .frame(width: 40, height: 40)
                .background(Color.primary.opacity(0.06))
                .clipShape(Circle())
        }
        .buttonStyle(.plain)
        .foregroundStyle(.primary)
        .disabled(isDisabled)
    }

    // MARK: - Toolbar

    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .topBarTrailing) {
            Button("Reset", action: viewModel.reset)
                .font(.system(size: 15, weight: .semibold))
                .disabled(viewModel.isResetDisabled)
        }

        ToolbarItemGroup(placement: .keyboard) {
            Spacer()
            Button("Done") { billFieldFocused = false }
                .font(.system(size: 15, weight: .bold))
        }
    }
}

// MARK: - Components

private struct TipButton: View {
    let label: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(label)
                .font(.system(size: 15, weight: .bold))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 11)
                .background(isSelected ? Color.primary : Color.clear)
                .foregroundStyle(isSelected ? Color(.systemBackground) : .primary)
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .overlay {
                    if !isSelected {
                        RoundedRectangle(cornerRadius: 8)
                            .strokeBorder(Color.primary.opacity(0.18), lineWidth: 1.5)
                    }
                }
        }
        .buttonStyle(.plain)
        .animation(DS.Anim.snap, value: isSelected)
    }
}

// MARK: - View Modifier

private extension View {
    func card() -> some View {
        self
            .background(Color(.secondarySystemGroupedBackground))
            .clipShape(RoundedRectangle(cornerRadius: DS.cardRadius))
            .overlay {
                RoundedRectangle(cornerRadius: DS.cardRadius)
                    .strokeBorder(Color.primary.opacity(0.07), lineWidth: 1)
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
