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
    var favoriteLevel: Int = 0
    var websiteURL: String
    var memo: String
    var events: [Event]
    
    //  選考ステータス
    enum Status: String, Codable, CaseIterable, Hashable {
        case interested = "気になる"
        case applied    = "書類提出"
        case interview  = "選考中"
        case offered    = "内定"
        case rejected   = "不合格"
        case declined   = "辞退"

        var icon: String {
            switch self {
            case .interested: return "eyes"
            case .applied:    return "doc"
            case .interview:  return "person.2"
            case .offered:    return "checkmark.seal"
            case .rejected:   return "xmark.circle"
            case .declined:   return "hand.raised"
            }
        }
    }
    
    //　イベントの日程
    struct Event: Identifiable, Codable, Hashable {
        var id = UUID()
        var title: String
        var date: Date
        var url: String = ""
    }
}
