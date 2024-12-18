//
//  HiNetworkManagerTests.swift
//  feat_network
//
//  Created by netcanis on 11/24/24.
//

import XCTest
@testable import feat_network

final class HiNetworkManagerTests: XCTestCase {
    func testGETRequest() {
        let endpoint = HiEndpoint(path: "/users", method: .GET)
        let request = HiAPIRequest<Empty>(endpoint: endpoint)
        let expectation = XCTestExpectation(description: "GET request should return users")

        HiNetworkManager.shared.request(apiRequest: request, baseURL: "https://jsonplaceholder.typicode.com") { (result: Result<[User], Error>) in
            switch result {
            case .success(let users):
                XCTAssertFalse(users.isEmpty, "Users list should not be empty")
                expectation.fulfill()
            case .failure(let error):
                XCTFail("Request failed with error: \(error)")
            }
        }

        wait(for: [expectation], timeout: 10.0)
    }
}

struct Empty: Codable {}

struct User: Codable {
    let id: Int
    let name: String
    let username: String
    let email: String
}

