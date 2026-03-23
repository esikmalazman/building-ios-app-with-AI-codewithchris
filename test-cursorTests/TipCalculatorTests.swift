//
//  TipCalculatorTests.swift
//  test-cursorTests
//
//  Created by esikmalazman on 18/03/2026.
//
//  HOW TO RUN:
//  1. In Xcode: File > New > Target > Unit Testing Bundle
//  2. Name it "test-cursorTests", ensure it tests the "test-cursor" scheme
//  3. Drag this file into that new target (or it auto-syncs if you use a folder reference)
//  4. Press ⌘U to run all tests
//

import XCTest
@testable import test_cursor

final class TipCalculatorTests: XCTestCase {

    // MARK: - parseBillAmount

    func test_parseBillAmount_validInteger() {
        XCTAssertEqual(TipCalculator.parseBillAmount("100"), 100.0)
    }

    func test_parseBillAmount_validDecimal() {
        XCTAssertEqual(TipCalculator.parseBillAmount("49.99"), 49.99)
    }

    func test_parseBillAmount_emptyString() {
        XCTAssertEqual(TipCalculator.parseBillAmount(""), 0)
    }

    func test_parseBillAmount_loneDecimalPoint() {
        XCTAssertEqual(TipCalculator.parseBillAmount("."), 0)
    }

    func test_parseBillAmount_letters() {
        XCTAssertEqual(TipCalculator.parseBillAmount("abc"), 0)
    }

    // MARK: - safeTipPercentage

    func test_safeTipPercentage_validOptions() {
        XCTAssertEqual(TipCalculator.safeTipPercentage(10), 10)
        XCTAssertEqual(TipCalculator.safeTipPercentage(15), 15)
        XCTAssertEqual(TipCalculator.safeTipPercentage(20), 20)
    }

    func test_safeTipPercentage_invalidFallsBackToDefault() {
        XCTAssertEqual(TipCalculator.safeTipPercentage(0), 15)
        XCTAssertEqual(TipCalculator.safeTipPercentage(99), 15)
        XCTAssertEqual(TipCalculator.safeTipPercentage(-5), 15)
    }

    // MARK: - safePeopleCount

    func test_safePeopleCount_clampsBelowOne() {
        XCTAssertEqual(TipCalculator.safePeopleCount(0), 1)
        XCTAssertEqual(TipCalculator.safePeopleCount(-3), 1)
    }

    func test_safePeopleCount_validValues() {
        XCTAssertEqual(TipCalculator.safePeopleCount(1), 1)
        XCTAssertEqual(TipCalculator.safePeopleCount(5), 5)
        XCTAssertEqual(TipCalculator.safePeopleCount(20), 20)
    }

    // MARK: - tipAmount

    func test_tipAmount_zeroBill() {
        XCTAssertEqual(TipCalculator.tipAmount(bill: 0, tipPercentage: 15), 0)
    }

    func test_tipAmount_10Percent() {
        XCTAssertEqual(TipCalculator.tipAmount(bill: 100, tipPercentage: 10), 10.0)
    }

    func test_tipAmount_15Percent() {
        XCTAssertEqual(TipCalculator.tipAmount(bill: 50, tipPercentage: 15), 7.5)
    }

    func test_tipAmount_20Percent() {
        XCTAssertEqual(TipCalculator.tipAmount(bill: 200, tipPercentage: 20), 40.0)
    }

    func test_tipAmount_decimalBill() {
        XCTAssertEqual(TipCalculator.tipAmount(bill: 35.50, tipPercentage: 10), 3.55, accuracy: 0.001)
    }

    func test_tipAmount_invalidPercentageFallsBackToDefault() {
        // Invalid tip % should fall back to 15%
        XCTAssertEqual(TipCalculator.tipAmount(bill: 100, tipPercentage: 99), 15.0)
    }

    // MARK: - totalAmount

    func test_totalAmount_zeroBill() {
        XCTAssertEqual(TipCalculator.totalAmount(bill: 0, tipPercentage: 15), 0)
    }

    func test_totalAmount_standard() {
        // $50 + 15% tip ($7.50) = $57.50
        XCTAssertEqual(TipCalculator.totalAmount(bill: 50, tipPercentage: 15), 57.5)
    }

    func test_totalAmount_largeGroupBill() {
        // $200 + 20% tip ($40) = $240
        XCTAssertEqual(TipCalculator.totalAmount(bill: 200, tipPercentage: 20), 240.0)
    }

    func test_totalAmount_smallBill() {
        // $12.80 + 10% ($1.28) = $14.08
        XCTAssertEqual(TipCalculator.totalAmount(bill: 12.80, tipPercentage: 10), 14.08, accuracy: 0.001)
    }

    // MARK: - amountPerPerson

    func test_amountPerPerson_zeroBill() {
        XCTAssertEqual(TipCalculator.amountPerPerson(bill: 0, tipPercentage: 15, numberOfPeople: 2), 0)
    }

    func test_amountPerPerson_onePerson_returnsTotal() {
        // 1 person → returns full total
        let total = TipCalculator.totalAmount(bill: 50, tipPercentage: 15)
        XCTAssertEqual(TipCalculator.amountPerPerson(bill: 50, tipPercentage: 15, numberOfPeople: 1), total)
    }

    func test_amountPerPerson_twoPeople() {
        // $57.50 ÷ 2 = $28.75
        XCTAssertEqual(TipCalculator.amountPerPerson(bill: 50, tipPercentage: 15, numberOfPeople: 2), 28.75)
    }

    func test_amountPerPerson_fourPeople() {
        // $240 ÷ 4 = $60
        XCTAssertEqual(TipCalculator.amountPerPerson(bill: 200, tipPercentage: 20, numberOfPeople: 4), 60.0)
    }

    func test_amountPerPerson_zeroOrNegativePeopleClampsToOne() {
        let total = TipCalculator.totalAmount(bill: 100, tipPercentage: 15)
        XCTAssertEqual(TipCalculator.amountPerPerson(bill: 100, tipPercentage: 15, numberOfPeople: 0), total)
        XCTAssertEqual(TipCalculator.amountPerPerson(bill: 100, tipPercentage: 15, numberOfPeople: -1), total)
    }

    // MARK: - sanitizeBillInput

    func test_sanitize_lettersAreStripped() {
        XCTAssertEqual(TipCalculator.sanitizeBillInput("12abc"), "12")
    }

    func test_sanitize_symbolsAreStripped() {
        XCTAssertEqual(TipCalculator.sanitizeBillInput("$50.00"), "50.00")
    }

    func test_sanitize_validInputPassesThrough() {
        XCTAssertEqual(TipCalculator.sanitizeBillInput("49.99"), "49.99")
    }

    func test_sanitize_multipleDecimalPointsCollapsed() {
        XCTAssertEqual(TipCalculator.sanitizeBillInput("12.3.4"), "12.34")
    }

    func test_sanitize_emptyStringPassesThrough() {
        XCTAssertEqual(TipCalculator.sanitizeBillInput(""), "")
    }
}
