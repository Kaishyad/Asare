import SQLite
import Foundation

class FilterManager {
    static let shared = FilterManager()
    private var db: Connection?

    private let filters = Table("filters")
    private let filterId = SQLite.Expression<Int64>("id")
    private let filterName = SQLite.Expression<String>("name")
    
    private let defaultFilters = ["Vegetarian", "Quick", "Spicy", "High-Protein", "Gluten-Free", "Vegan", "Dairy-Free", "Keto"]

    private init() {
        db = ConnectionManager.shared.getConnection()
      //  dropFiltersTable()
        createFiltersTable()
    }
    private func dropFiltersTable() {
        do {
            try db?.run("DROP TABLE IF EXISTS filters")
            print("Filters table dropped successfully!")
        } catch {
            print("Error dropping filters table: \(error)")
        }
    }

    private func createFiltersTable() {
        do {
            try db?.run(filters.create(ifNotExists: true) { t in
                t.column(filterId, primaryKey: true)
                t.column(filterName, unique: true)
            })
            print("Filters table created successfully!")
            insertDefaultFilters()
        } catch {
            print("Error creating filters table: \(error)")
        }
    }

    func getAllFilters() -> [String] {
        do {
            return try db?.prepare(filters).map { $0[filterName] } ?? []
        } catch {
            print("Error fetching filters: \(error)")
            return []
        }
    }

    func getFilterIdByName(_ name: String) -> Int64? {
        do {
            let filterQuery = filters.filter(filterName == name)
            if let filter = try db?.pluck(filterQuery) {
                return filter[filterId]
            }
        } catch {
            print("Error fetching filter ID: \(error)")
        }
        return nil
    }

    //MARK: - Give access to the filters
    func getFiltersTable() -> Table {
        return filters
    }

    func getFilterIdExpression() -> SQLite.Expression<Int64> {
        return filterId
    }

    func getFilterNameExpression() -> SQLite.Expression<String> {
        return filterName
    }

    func addFilter(name: String) -> Bool {
        do {
            let existingFilter = filters.filter(filterName == name)
            if try db?.pluck(existingFilter) == nil {
                try db?.run(filters.insert(filterName <- name))
                return true
            }
        } catch {
            print("Error adding filter: \(error)")
        }
        return false
    }
    private func insertDefaultFilters() {
            do {
                for filter in defaultFilters {
                    let existingFilter = filters.filter(filterName == filter)
                    if try db?.pluck(existingFilter) == nil {
                        try db?.run(filters.insert(filterName <- filter))
                    }
                }
                print("Default filters added!")
            } catch {
                print("Error inserting default filters: \(error)")
            }
        }

    func deleteFilter(name: String) -> Bool {
        do {
            let filterToDelete = filters.filter(filterName == name)
            try db?.run(filterToDelete.delete())
            return true
        } catch {
            print("Error deleting filter: \(error)")
            return false
        }
    }
}
