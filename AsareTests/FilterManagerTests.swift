import XCTest
@testable import Asare

class FilterManagerTests: XCTestCase {
    
    func testDatabaseConnection() {
        let dbConnection = ConnectionManager.shared.getConnection()
        XCTAssertNotNil(dbConnection, "Database connection should be established.")
    }
    
    //Test that default filters are added to the database
    func testInsertDefaultFilters() {
        let filterManager = FilterManager.shared
        let filters = filterManager.getAllFilters()
        
        XCTAssertEqual(filters.count, 8, "There should be 8 default filters.")
        XCTAssertTrue(filters.contains("Vegetarian"), "The 'Vegetarian' filter should be added.")
        XCTAssertTrue(filters.contains("Quick"), "The 'Quick' filter should be added.")
        XCTAssertTrue(filters.contains("Spicy"), "The 'Spicy' filter should be added.")
    }
    
    func testAddFilter() {
        let filterManager = FilterManager.shared
        let newFilterName = "Low-Carb"
        let added = filterManager.addFilter(name: newFilterName)
        
        XCTAssertTrue(added, "The filter should be added successfully.")
        let filters = filterManager.getAllFilters()
        XCTAssertTrue(filters.contains(newFilterName), "The filter should be present in the database.")
    }
    
    func testAddDuplicateFilter() {
        let filterManager = FilterManager.shared
        let filterName = "Vegetarian"
        
        let added = filterManager.addFilter(name: filterName)
        
        XCTAssertFalse(added, "The duplicate filter should not be added.")
    }
    
    func testDeleteFilter() {
        let filterManager = FilterManager.shared
        let filterName = "Keto"
        let deleted = filterManager.deleteFilter(name: filterName)
        
        XCTAssertTrue(deleted, "The filter should be deleted successfully.")
        let filters = filterManager.getAllFilters()
        XCTAssertFalse(filters.contains(filterName), "The filter should not exist after deletion.")
    }
    
    func testGetFilterIdByName() {
        let filterManager = FilterManager.shared
        let filterName = "Vegetarian"
        if let filterId = filterManager.getFilterIdByName(filterName) {
            XCTAssertNotNil(filterId, "The filter ID should be found for \(filterName).")
        } else {
            XCTFail("The filter ID for \(filterName) should be found.")
        }
    }
    
    func testGetFilterIdByInvalidName() {
        let filterManager = FilterManager.shared
        let invalidFilterName = "NonExistentFilter"
        let filterId = filterManager.getFilterIdByName(invalidFilterName)
        XCTAssertNil(filterId, "The filter ID should be nil for a non-existent filter.")
    }
}
