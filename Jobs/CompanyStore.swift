import Foundation
import Observation

@Observable
class CompanyStore {
    var companies: [Company] = []

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
}
