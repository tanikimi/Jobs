import Foundation
import Observation

@Observable
class CompanyStore {
    var companies: [Company] = [] {
        didSet{ save() }
    }
    
    private let saveURL = URL.documentsDirectory.appending(path: "companies.json")
    
    init() {
        load()
    }

    func add(_ company: Company) {
        companies.append(company)
    }

    func delete(_ company: Company) {
        companies.removeAll { $0.id == company.id }
    }

    func update(_ company: Company) {
        if let index = companies.firstIndex(where: { $0.id == company.id }) {
            companies[index] = company
        }
    }
    
    private func save() {
        do {
            let data = try JSONEncoder().encode(companies)
            try data.write(to: saveURL)
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
    }
}
