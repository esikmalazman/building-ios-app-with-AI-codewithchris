//
//  ContentView.swift
//  test-cursor
//
//  Created by esikmalazman on 18/03/2026.
//

import SwiftUI

struct ContentView: View {
    // MARK: - State (wired up in later build steps)
    @State private var billAmount: String = ""
    @State private var selectedTipIndex: Int = 1
    @State private var numberOfPeople: Int = 2

    private let tipOptions = [10, 15, 20]

    // MARK: - Computed placeholders
    private var tipAmount: Double { 0 }
    private var totalAmount: Double { 0 }
    private var amountPerPerson: Double { 0 }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {

                    // MARK: Bill Amount Section
                    SectionCard(title: "Bill Amount") {
                        HStack {
                            Text("$")
                                .font(.title2)
                                .foregroundStyle(.secondary)
                            TextField("0.00", text: $billAmount)
                                .font(.title2)
                                .keyboardType(.decimalPad)
                        }
                        .padding(.horizontal, 4)
                    }

                    // MARK: Tip Percentage Section
                    SectionCard(title: "Tip Percentage") {
                        Picker("Tip", selection: $selectedTipIndex) {
                            ForEach(tipOptions.indices, id: \.self) { index in
                                Text("\(tipOptions[index])%").tag(index)
                            }
                        }
                        .pickerStyle(.segmented)
                    }

                    // MARK: Summary Section
                    SectionCard(title: "Summary") {
                        VStack(spacing: 16) {
                            SummaryRow(label: "Tip Amount", value: tipAmount)
                            Divider()
                            SummaryRow(label: "Total Amount", value: totalAmount)
                                .fontWeight(.semibold)
                        }
                    }

                    // MARK: Split Bill Section
                    SectionCard(title: "Split Bill") {
                        VStack(spacing: 16) {
                            HStack {
                                Text("Number of People")
                                    .foregroundStyle(.primary)
                                Spacer()
                                Stepper(
                                    value: $numberOfPeople,
                                    in: 1...20
                                ) {
                                    Text("\(numberOfPeople)")
                                        .font(.title3)
                                        .fontWeight(.medium)
                                        .frame(minWidth: 32, alignment: .trailing)
                                }
                            }
                            Divider()
                            SummaryRow(label: "Per Person", value: amountPerPerson)
                                .fontWeight(.semibold)
                        }
                    }

                }
                .padding(.horizontal)
                .padding(.vertical, 12)
            }
            .navigationTitle("Tip Calculator")
            .background(Color(.systemGroupedBackground))
        }
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

#Preview {
    ContentView()
}
