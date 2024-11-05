import XCTest
@testable import Typesense

final class CreateURLQueryParamsTests: XCTestCase {
    struct Car: Codable {
        var name = "Fast"
        var age: Int = 20
        var price: Int64 = 2000
        var page: Int? = 1
        var groupLimit: Int64? = 0
        var speed: Double = 120.555
        var mileage: Float = 120.5
        var isElectric = true
        var inStock: Bool = false
        var empty: String? = nil

        enum CodingKeys: String, CodingKey {
            case name
            case age
            case price
            case page
            case groupLimit = "group_limit"
            case speed
            case mileage
            case isElectric = "is_electric"
            case inStock = "in_stock"
            case empty
        }
    }
    func testCreateURLQueryParams() {
        do {
            let queryParams = try createURLQuery(forSchema: Car())
            print(queryParams)
            XCTAssertEqual(queryParams.count, 9)
            XCTAssertTrue(queryParams.contains(URLQueryItem(name: "name", value: "Fast")))
            XCTAssertTrue(queryParams.contains(URLQueryItem(name: "age", value: "20")))
            XCTAssertTrue(queryParams.contains(URLQueryItem(name: "price", value: "2000")))
            XCTAssertTrue(queryParams.contains(URLQueryItem(name: "page", value: "1")))
            XCTAssertTrue(queryParams.contains(URLQueryItem(name: "group_limit", value: "0")))
            XCTAssertTrue(queryParams.contains(URLQueryItem(name: "speed", value: "120.555")))
            XCTAssertTrue(queryParams.contains(URLQueryItem(name: "mileage", value: "120.5")))
            XCTAssertTrue(queryParams.contains(URLQueryItem(name: "is_electric", value: "true")))
            XCTAssertTrue(queryParams.contains(URLQueryItem(name: "in_stock", value: "false")))
            XCTAssertFalse(queryParams.contains(URLQueryItem(name: "empty", value: "null")))
        } catch (let error) {
            print(error)
            XCTAssertTrue(false)
        }
    }

    struct People: Codable {
        var obj = ["isHooman": true]
    }

    func testCreateURLQueryParamsThrowsError() {
        do {
            let _ = try createURLQuery(forSchema: People())
        } catch DataError.unableToParse(let msg){
            if !msg.contains("Unknown data type"){
                XCTAssertTrue(false)
            }
        } catch (let error) {
            print(error)
            XCTAssertTrue(false)
        }
    }
}
