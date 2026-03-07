//
//  CompanyDetailView.swift
//  Jobs
//
//  Created by 谷川 木穣 on 2026/03/08.
//

import SwiftUI

struct CompanyDetailView: View {
    let company: Company
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16){
            Text(company.name)
                .font(.largeTitle)
                .bold()
            
            Text(company.status.rawValue)
                .font(.headline)
                .foregroundStyle(.secondary)
            
            Divider()
            
            Text("メモ")
                .font(.headline)
            Text(company.memo.isEmpty ? "メモなし" : company.memo)
                .foregroundStyle(company.memo.isEmpty ? .secondary : .primary)
            
            Spacer()
        }
        .padding(24)
    }
}
