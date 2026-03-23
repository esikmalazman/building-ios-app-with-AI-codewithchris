//
//  TipCalculatorViewModel.swift
//  test-cursor
//
//  Created by esikmalazman on 18/03/2026.
//

import Foundation
import Observation

@Observable
final class TipCalculatorViewModel {

    // MARK: - Stored State (persisted across launches)

    var billAmount: String = "" {
        didSet { UserDefaults.standard.set(billAmount, forKey: StorageKey.billAmount) }
    }

    var selectedTipPercentage: Int = TipCalculator.defaultTipPercentage {
        didSet { UserDefaults.standard.set(selectedTipPercentage, forKey: StorageKey.tipPercentage) }
    }

    var numberOfPeople: Int = TipCalculator.defaultNumberOfPeople {
        didSet { UserDefaults.standard.set(numberOfPeople, forKey: StorageKey.numberOfPeople) }
    }

    // MARK: - Transient State

    var billAmountError: String?

    // MARK: - Computed Values

    var parsedBillAmount: Double    { TipCalculator.parseBillAmount(billAmount) }
    var billIsEmpty: Bool           { parsedBillAmount == 0 }
    var activeTipPercentage: Int    { TipCalculator.safeTipPercentage(selectedTipPercentage) }
    var safePeopleCount: Int        { TipCalculator.safePeopleCount(numberOfPeople) }

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

    var isResetDisabled: Bool {
        billIsEmpty
            && selectedTipPercentage == TipCalculator.defaultTipPercentage
            && numberOfPeople == TipCalculator.defaultNumberOfPeople
    }

    // MARK: - Init

    init() {
        let defaults = UserDefaults.standard
        billAmount            = defaults.string(forKey: StorageKey.billAmount) ?? ""
        selectedTipPercentage = (defaults.object(forKey: StorageKey.tipPercentage) as? Int) ?? TipCalculator.defaultTipPercentage
        numberOfPeople        = (defaults.object(forKey: StorageKey.numberOfPeople) as? Int) ?? TipCalculator.defaultNumberOfPeople
    }

    // MARK: - Actions

    /// Sanitizes raw bill input, stripping non-numeric characters.
    /// Shows a timed error if characters were removed.
    func updateBillAmount(_ input: String) {
        let sanitized = TipCalculator.sanitizeBillInput(input)
        if sanitized != input { showError("Enter numbers only") }
        billAmount = sanitized
    }

    /// Resets all inputs to their default values and clears persisted storage.
    func reset() {
        billAmount = ""
        selectedTipPercentage = TipCalculator.defaultTipPercentage
        numberOfPeople = TipCalculator.defaultNumberOfPeople
        billAmountError = nil
    }

    // MARK: - Private

    private func showError(_ message: String) {
        billAmountError = message
        Task { @MainActor [weak self] in
            try? await Task.sleep(for: .seconds(2))
            self?.billAmountError = nil
        }
    }

    private enum StorageKey {
        static let billAmount    = "lastBillAmount"
        static let tipPercentage = "lastTipPercentage"
        static let numberOfPeople = "lastNumberOfPeople"
    }
}
