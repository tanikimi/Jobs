import Foundation
import Observation
import AppKit

@Observable
class CompanyStore {
    var companies: [Company] = [] {
        didSet { save() }
    }
    var trashedCompanies: [Company] = [] {
        didSet { save() }
    }
    var faviconCache: [String: NSImage] = [:]

    private let saveURL = URL.documentsDirectory.appending(path: "companies.json")
    private let trashURL = URL.documentsDirectory.appending(path: "trashedCompanies.json")
    private let faviconCacheURL = URL.documentsDirectory.appending(path: "faviconCache.json")

    init() {
        load()
        loadFaviconCache()
    }

    func add(_ company: Company) {
        companies.append(company)
    }

    func delete(_ company: Company) {
        companies.removeAll { $0.id == company.id }
        trashedCompanies.append(company)
    }

    func restore(_ company: Company) {
        trashedCompanies.removeAll { $0.id == company.id }
        companies.append(company)
    }

    func deletePermanently(_ company: Company) {
        trashedCompanies.removeAll { $0.id == company.id }
    }

    func emptyTrash() {
        trashedCompanies.removeAll()
    }

    func update(_ company: Company) {
        if let index = companies.firstIndex(where: { $0.id == company.id }) {
            let oldURL = companies[index].websiteURL
            companies[index] = company
            if oldURL != company.websiteURL {
                faviconCache.removeValue(forKey: oldURL)
                faviconCache.removeValue(forKey: company.websiteURL)
            }
        }
    }

    func cachedFavicon(for url: String) -> NSImage? {
        return faviconCache[url]
    }

    func cacheFavicon(_ image: NSImage, for url: String) {
        faviconCache[url] = image
        saveFaviconCache()
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
                cacheFavicon(loaded, for: url)
            }
        } catch {
            // print("Favicon取得失敗: \(error)")
        }
    }

    private func save() {
        do {
            // 保存前にバックアップを作成
            if FileManager.default.fileExists(atPath: saveURL.path) {
                let backupURL = URL.documentsDirectory.appending(path: "companies_backup.json")
                try? FileManager.default.removeItem(at: backupURL)
                try? FileManager.default.copyItem(at: saveURL, to: backupURL)
            }
            let data = try JSONEncoder().encode(companies)
            try data.write(to: saveURL)

            if FileManager.default.fileExists(atPath: trashURL.path) {
                let backupTrashURL = URL.documentsDirectory.appending(path: "trashedCompanies_backup.json")
                try? FileManager.default.removeItem(at: backupTrashURL)
                try? FileManager.default.copyItem(at: trashURL, to: backupTrashURL)
            }
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
            // デコード失敗時は上書きしない
            print("読み込み失敗: \(error)")
        }
        do {
            let trashData = try Data(contentsOf: trashURL)
            trashedCompanies = try JSONDecoder().decode([Company].self, from: trashData)
        } catch {
            print("ゴミ箱読み込み失敗: \(error)")
        }
    }

    private func saveFaviconCache() {
        let data = faviconCache.compactMapValues { $0.tiffRepresentation }
        if let encoded = try? JSONEncoder().encode(data) {
            try? encoded.write(to: faviconCacheURL)
        }
    }

    private func loadFaviconCache() {
        guard let data = try? Data(contentsOf: faviconCacheURL),
              let decoded = try? JSONDecoder().decode([String: Data].self, from: data)
        else { return }
        faviconCache = decoded.compactMapValues { NSImage(data: $0) }
    }
}
