//
//  Company.swift
//  Jobs
//
//  Created by 谷川 木穣 on 2026/03/07.
//

import Foundation

struct Company: Identifiable, Codable, Hashable {
    var id = UUID()
    var name: String
    var status: Status
    var websiteURL: String
    var memo: String
    var events: [Event]
    
    //  選考ステータス
    enum Status: String, Codable, CaseIterable, Hashable {
        case interested = "気になる"
        case applied = "応募済み"
        case interview = "面接中"
        case offered = "内定"
        case rejected = "不合格"
        case declined = "辞退"
    }
    
    //　イベントの日程
    struct Event: Identifiable, Codable, Hashable {
        var id = UUID()
        var title: String
        var date: Date
    }
}
