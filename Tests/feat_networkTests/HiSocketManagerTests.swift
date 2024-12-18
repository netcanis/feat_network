//
//  HiSocketManagerTests.swift
//  feat_network
//
//  Created by netcanis on 11/24/24.
//

import XCTest
@testable import feat_network

final class HiSocketManagerTests: XCTestCase {
    func testSocketConnection() {
        let socketManager = HiSocketManager()
        socketManager.connect(to: "example.com", port: 80)
        
        let message = "Hello, Server".data(using: .utf8)!
        socketManager.send(data: message)
        
        socketManager.receive { data in
            if let data = data, let response = String(data: data, encoding: .utf8) {
                print("Received: \(response)")
            } else {
                XCTFail("No data received")
            }
        }
        
        socketManager.disconnect()
    }
}
