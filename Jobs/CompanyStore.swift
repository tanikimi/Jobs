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
