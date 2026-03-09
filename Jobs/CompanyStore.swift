import SwiftUI
import Foundation
import Observation

@Observable
class CompanyStore {
    var companies: [Company] = [] {
        didSet { save() }
    }
    var trashedCompanies: [Company] = [] {
        didSet { save() }
    }

    private let saveURL = URL.documentsDirectory.appending(path: "companies.json")
    private let trashURL = URL.documentsDirectory.appending(path: "trashedCompanies.json")

    init() {
        load()
    }

    func add(_ company: Company) {
        companies.append(company)
    }
    
    func update(_ company: Company) {
        if let index = companies.firstIndex(where: { $0.id == company.id }) {
            let oldURL = companies[index].websiteURL
            companies[index] = company
            // URLが変わったときだけキャッシュを削除
            if oldURL != company.websiteURL {
                faviconCache.removeValue(forKey: oldURL)
                faviconCache.removeValue(forKey: company.websiteURL)
            }
        }
    }

    // ゴミ箱に移動
    func delete(_ company: Company) {
        companies.removeAll { $0.id == company.id }
        trashedCompanies.append(company)
    }

    // ゴミ箱から復元
    func restore(_ company: Company) {
        trashedCompanies.removeAll { $0.id == company.id }
        companies.append(company)
    }

    // ゴミ箱から完全削除
    func deletePermanently(_ company: Company) {
        trashedCompanies.removeAll { $0.id == company.id }
    }

    // ゴミ箱を空にする
    func emptyTrash() {
        trashedCompanies.removeAll()
    }
    
    // faviconを頻繁にみてGoogleに迷惑をかけないようにするための処理
    var faviconCache: [String: NSImage] = [:]

    func cachedFavicon(for url: String) -> NSImage? {
        return faviconCache[url]
    }

    func cacheFavicon(_ image: NSImage, for url: String) {
        faviconCache[url] = image
    }
    
    func fetchFavicon(for url: String) async {
        guard !url.isEmpty,
              faviconCache[url] == nil,
              let siteURL = URL(string: url),
              let host = siteURL.host,
              let faviconURL = URL(string: "https://www.google.com/s2/favicons?domain=\(host)&sz=256")
        else { return }

        // print("🌐 Favicon取得: \(url)")
        do {
            let (data, _) = try await URLSession.shared.data(from: faviconURL)
            if let loaded = NSImage(data: data) {
                faviconCache[url] = loaded
            }
        } catch {
            print("Favicon取得失敗: \(error)")
        }
    }

    private func save() {
        do {
            let data = try JSONEncoder().encode(companies)
            try data.write(to: saveURL)
            let trashData = try JSONEncoder().encode(trashedCompanies)
            try trashData.write(to: trashURL)
        } catch {
            print("保存失敗: \(error)")
        }
    }

    private func load() {
        do {
            let data = try Data(contentsOf: saveURL)
            companies = try JSONDecoder().decode([Company].self, from: data)
        } catch {
            companies = []
        }
        do {
            let trashData = try Data(contentsOf: trashURL)
            trashedCompanies = try JSONDecoder().decode([Company].self, from: trashData)
        } catch {
            trashedCompanies = []
        }
    }
}
