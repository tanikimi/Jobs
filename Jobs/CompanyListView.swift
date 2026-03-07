//
//  CompanyListView.swift
//  Jobs
//
//  Created by 谷川 木穣 on 2026/03/08.
//

import SwiftUI

struct CompanyListView: View {
    let companies: [Company]
    @Binding var selectedCompany: Company?

    var body: some View {
        List(companies, selection: $selectedCompany) { company in
            VStack(alignment: .leading) {
                Text(company.name)
                    .font(.headline)
                Text(company.status.rawValue)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .tag(company)
        }
        .navigationTitle("企業リスト")
    }
}

