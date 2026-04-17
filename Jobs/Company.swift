//
//  Company.swift
//  Jobs
//
//  Created by 谷川 木穣 on 2026/03/07.
//

import Foundation


struct Company: Identifiable, Codable, Hashable {
    var id = UUID()
    var updatedAt: Date = Date.distantPast
    var name: String
    var status: Status
    var favoriteLevel: Int = 0
    var websiteURL: String
    var links: [Link] = []
    var memo: String
    var entrySheets: [EntrySheetItem] = []
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
        var startTime: Date? = nil
        var endTime: Date? = nil
        var url: String = ""
        var isCompleted: Bool = false
    }
    
    struct Link: Identifiable, Codable, Hashable {
        var id = UUID()
        var title: String
        var url: String
    }
    
    struct EntrySheetItem: Identifiable, Codable, Hashable {
        var id = UUID()
        var title: String = ""
        var text: String = ""
    }
    
    // JSONのキーを定義
    enum CodingKeys: String, CodingKey {
        case id, updatedAt, name, status, favoriteLevel, websiteURL, links, memo, entrySheets, events
        case entrySheet // 👈 旧形式のキーを残しておく
    }

    // カスタムデコード処理
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        // 基本プロパティのデコード
        id = try container.decode(UUID.self, forKey: .id)
        updatedAt = try container.decode(Date.self, forKey: .updatedAt)
        name = try container.decode(String.self, forKey: .name)
        status = try container.decode(Status.self, forKey: .status)
        favoriteLevel = try container.decode(Int.self, forKey: .favoriteLevel)
        websiteURL = try container.decode(String.self, forKey: .websiteURL)
        links = try container.decode([Link].self, forKey: .links)
        memo = try container.decode(String.self, forKey: .memo)
        events = try container.decode([Event].self, forKey: .events)

        // マイグレーション・ロジック
        if let newItems = try? container.decode([EntrySheetItem].self, forKey: .entrySheets) {
            // すでに新形式のデータがある場合
            entrySheets = newItems
        } else if let oldText = try? container.decode(String.self, forKey: .entrySheet), !oldText.isEmpty {
            // 旧形式のデータ（String）が見つかった場合、新形式に変換
            entrySheets = [EntrySheetItem(title: "以前のES", text: oldText)]
        } else {
            // どちらもない、または空の場合は「最初の1つ」をここで用意する
            entrySheets = [EntrySheetItem(title: "", text: "")]
        }

        // さらに、もし読み込んだ配列が「空（[]）」だった場合も1つ追加しておく（念押し）
        if entrySheets.isEmpty {
            entrySheets = [EntrySheetItem(title: "", text: "")]
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(id, forKey: .id)
        try container.encode(updatedAt, forKey: .updatedAt)
        try container.encode(name, forKey: .name)
        try container.encode(status, forKey: .status)
        try container.encode(favoriteLevel, forKey: .favoriteLevel)
        try container.encode(websiteURL, forKey: .websiteURL)
        try container.encode(links, forKey: .links)
        try container.encode(memo, forKey: .memo)
        try container.encode(entrySheets, forKey: .entrySheets) // 新しい形式のみ保存
        try container.encode(events, forKey: .events)
    }
    
    // 通常の初期化用（addCompanyなどで使用）
    init(name: String, status: Status, websiteURL: String, memo: String, entrySheets: [EntrySheetItem], events: [Event]) {
        self.name = name
        self.status = status
        self.websiteURL = websiteURL
        self.memo = memo
        self.entrySheets = entrySheets
        self.events = events
    }
}
