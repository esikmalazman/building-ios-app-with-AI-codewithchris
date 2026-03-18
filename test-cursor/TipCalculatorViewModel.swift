//
//  TipCalculatorViewModel.swift
//  test-cursor
//
//  Created by esikmalazman on 18/03/2026.
//

import Foundation
import Observation

/// Drives the Tip Calculator UI.
///
/// Owns all user-facing state, persists inputs across launches via `UserDefaults`,
/// and delegates every calculation to `TipCalculator`.
@Observable
@MainActor
final class TipCalculatorViewModel {

    // MARK: - Persisted Input

    var billAmount: String {
        didSet { defaults.set(billAmount, forKey: Keys.billAmount) }
    }

    var selectedTipPercentage: Int {
        didSet { defaults.set(selectedTipPercentage, forKey: Keys.tipPercentage) }
    }

    var numberOfPeople: Int {
        didSet { defaults.set(numberOfPeople, forKey: Keys.numberOfPeople) }
    }

    // MARK: - Transient State

    private(set) var billAmountError: String?

    // MARK: - Derived Values

    var parsedBillAmount: Double  { TipCalculator.parseBillAmount(billAmount) }
    var billIsEmpty: Bool         { parsedBillAmount == 0 }
    var safePeopleCount: Int      { TipCalculator.safePeopleCount(numberOfPeople) }

    var tipAmount: Double {
        TipCalculator.tipAmount(bill: parsedBillAmount, tipPercentage: selectedTipPercentage)
    }

    var totalAmount: Double {
        TipCalculator.totalAmount(bill: parsedBillAmount, tipPercentage: selectedTipPercentage)
    }

    var amountPerPerson: Double {
        TipCalculator.amountPerPerson(
            bill: parsedBillAmount,
            tipPercentage: selectedTipPercentage,
            numberOfPeople: numberOfPeople
        )
    }

    /// `true` when all inputs match their factory defaults — used to disable the Reset button.
    var isAtDefaults: Bool {
        billIsEmpty
            && selectedTipPercentage == TipCalculator.defaultTipPercentage
            && numberOfPeople == TipCalculator.defaultNumberOfPeople
    }

    // MARK: - Init

    /// - Parameter defaults: Injected `UserDefaults` instance; defaults to `.standard`.
    ///   Pass a custom suite in tests to avoid polluting the real store.
    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        billAmount = defaults.string(forKey: Keys.billAmount) ?? ""
        selectedTipPercentage = defaults.object(forKey: Keys.tipPercentage) as? Int
            ?? TipCalculator.defaultTipPercentage
        numberOfPeople = defaults.object(forKey: Keys.numberOfPeople) as? Int
            ?? TipCalculator.defaultNumberOfPeople
    }

    // MARK: - Actions

    /// Sanitizes raw bill input and flags an error when invalid characters are stripped.
    func handleBillInput(_ rawInput: String) {
        let sanitized = TipCalculator.sanitizeBillInput(rawInput)
        guard sanitized != billAmount else { return }
        if sanitized != rawInput { scheduleBillError("Enter numbers only") }
        billAmount = sanitized
    }

    /// Resets all inputs to factory defaults and clears any active error.
    func reset() {
        billAmount = ""
        selectedTipPercentage = TipCalculator.defaultTipPercentage
        numberOfPeople = TipCalculator.defaultNumberOfPeople
        billAmountError = nil
    }

    // MARK: - Private

    private let defaults: UserDefaults

    private func scheduleBillError(_ message: String) {
        billAmountError = message
        Task {
            try? await Task.sleep(for: .seconds(2))
            billAmountError = nil
        }
    }
}

// MARK: - Storage Keys

private extension TipCalculatorViewModel {
    enum Keys {
        static let billAmount     = "lastBillAmount"
        static let tipPercentage  = "lastTipPercentage"
        static let numberOfPeople = "lastNumberOfPeople"
    }
}
