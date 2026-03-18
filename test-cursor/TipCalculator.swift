//
//  TipCalculator.swift
//  test-cursor
//
//  Created by esikmalazman on 18/03/2026.
//

import Foundation

/// Pure calculation model for the Tip Calculator.
/// No SwiftUI dependencies — fully unit testable.
struct TipCalculator {

    // MARK: - Constants

    static let tipOptions = [10, 15, 20]
    static let defaultTipPercentage = 15
    static let defaultNumberOfPeople = 2

    // MARK: - Input Parsing

    /// Parses a raw bill string into a Double.
    /// A lone "." is treated as empty (returns 0).
    static func parseBillAmount(_ raw: String) -> Double {
        let trimmed = raw.trimmingCharacters(in: CharacterSet(charactersIn: "."))
        return Double(trimmed) ?? 0
    }

    /// Returns a safe tip percentage, falling back to the default if the value is not in the allowed list.
    static func safeTipPercentage(_ percentage: Int) -> Int {
        tipOptions.contains(percentage) ? percentage : defaultTipPercentage
    }

    /// Clamps the people count to a minimum of 1.
    static func safePeopleCount(_ count: Int) -> Int {
        max(1, count)
    }

    // MARK: - Calculations

    /// F-003: Tip amount = bill × tip% ÷ 100. Returns 0 when bill is zero.
    static func tipAmount(bill: Double, tipPercentage: Int) -> Double {
        guard bill > 0 else { return 0 }
        return bill * Double(safeTipPercentage(tipPercentage)) / 100
    }

    /// F-004: Total = bill + tip. Returns 0 when bill is zero.
    static func totalAmount(bill: Double, tipPercentage: Int) -> Double {
        guard bill > 0 else { return 0 }
        return bill + tipAmount(bill: bill, tipPercentage: tipPercentage)
    }

    /// F-006: Amount per person = total ÷ people.
    /// Returns totalAmount directly when there is only 1 person.
    static func amountPerPerson(bill: Double, tipPercentage: Int, numberOfPeople: Int) -> Double {
        let total = totalAmount(bill: bill, tipPercentage: tipPercentage)
        guard total > 0 else { return 0 }
        let people = safePeopleCount(numberOfPeople)
        guard people > 1 else { return total }
        return total / Double(people)
    }

    // MARK: - Input Sanitization

    /// Strips non-numeric characters, allowing digits and a single decimal point.
    static func sanitizeBillInput(_ input: String) -> String {
        let allowed = CharacterSet.decimalDigits.union(CharacterSet(charactersIn: "."))
        let filtered = String(input.unicodeScalars.filter { allowed.contains($0) }.map(Character.init))
        return enforceOneDecimalPoint(filtered)
    }

    /// Ensures at most one decimal point in a numeric string.
    static func enforceOneDecimalPoint(_ input: String) -> String {
        let parts = input.components(separatedBy: ".")
        guard parts.count > 2 else { return input }
        return parts[0] + "." + parts[1...].joined()
    }
}
