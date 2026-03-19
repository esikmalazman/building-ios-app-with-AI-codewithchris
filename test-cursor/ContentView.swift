//
//  ContentView.swift
//  test-cursor
//
//  Created by esikmalazman on 18/03/2026.
//

import SwiftUI

// MARK: - Design System

private enum DS {
    /// Red violet — warm, premium, distinct from generic fintech green.
    static let accent = Color(red: 0.710, green: 0.200, blue: 0.541)

    /// Warm blush background: clearly tinted in light mode, deep plum in dark mode.
    /// Uses UIColor for proper adaptive rendering — opacity overlays on grey don't carry warmth.
    static let warmBackground = Color(UIColor { trait in
        trait.userInterfaceStyle == .dark
            ? UIColor(red: 0.10, green: 0.06, blue: 0.09, alpha: 1) // deep warm plum
            : UIColor(red: 0.97, green: 0.92, blue: 0.95, alpha: 1) // soft blush rose
    })

    /// Card surface that sits cleanly on the warm background.
    static let cardSurface = Color(UIColor { trait in
        trait.userInterfaceStyle == .dark
            ? UIColor(red: 0.17, green: 0.11, blue: 0.15, alpha: 1)
            : UIColor(red: 1.00, green: 1.00, blue: 1.00, alpha: 1)
    })

    static let cardRadius: CGFloat = 16
    static let labelFont = Font.system(size: 11, weight: .bold)
    static let labelTracking: CGFloat = 1.2

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
            .background(DS.warmBackground.ignoresSafeArea())
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
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundStyle(.primary.opacity(0.3))

                TextField("0.00", text: $viewModel.billAmount)
                    .font(.system(size: 54, weight: .black, design: .rounded).monospacedDigit())
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
                        .font(.system(size: 17, weight: .semibold, design: .rounded).monospacedDigit())
                        .foregroundStyle(DS.accent)
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
                        Text("$0.00")
                            .foregroundStyle(DS.accent.opacity(0.18))
                            .transition(.opacity)
                    } else {
                        Text(viewModel.amountPerPerson, format: .currency(code: "USD").presentation(.narrow))
                            .foregroundStyle(DS.accent)
                            .contentTransition(.numericText())
                            .animation(DS.Anim.value, value: viewModel.amountPerPerson)
                            .transition(.opacity)
                    }
                }
                .font(.system(size: 58, weight: .black, design: .rounded).monospacedDigit())
                .tracking(-0.5)
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
        .resultCard()
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
                .overlay {
                    Circle()
                        .strokeBorder(DS.accent.opacity(0.5), lineWidth: 1.5)
                }
        }
        .buttonStyle(.plain)
        .foregroundStyle(DS.accent)
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
                .font(.system(size: 15, weight: .bold, design: .rounded))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 11)
                .background(isSelected ? DS.accent : Color.clear)
                .foregroundStyle(isSelected ? Color.white : .primary)
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .overlay {
                    RoundedRectangle(cornerRadius: 8)
                        .strokeBorder(
                            isSelected ? DS.accent : Color.primary.opacity(0.18),
                            lineWidth: 1.5
                        )
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
            .background(DS.cardSurface)
            .clipShape(RoundedRectangle(cornerRadius: DS.cardRadius))
            .overlay {
                RoundedRectangle(cornerRadius: DS.cardRadius)
                    .strokeBorder(Color.primary.opacity(0.07), lineWidth: 1)
            }
    }

    /// Result card: same white surface with a soft accent border to distinguish it.
    func resultCard() -> some View {
        self
            .background(DS.cardSurface)
            .clipShape(RoundedRectangle(cornerRadius: DS.cardRadius))
            .overlay {
                RoundedRectangle(cornerRadius: DS.cardRadius)
                    .strokeBorder(DS.accent.opacity(0.15), lineWidth: 1)
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
