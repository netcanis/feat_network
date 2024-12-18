//
//  HiWebSocketManagerTests.swift
//  feat_network
//
//  Created by netcanis on 11/24/24.
//

import XCTest
@testable import feat_network

final class HiWebSocketManagerTests: XCTestCase {
    func testWebSocketConnection() {
        let webSocketManager = HiWebSocketManager()
        let url = URL(string: "wss://echo.websocket.org")!
        webSocketManager.connect(to: url)
        
        webSocketManager.send(message: "Hello, WebSocket")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            webSocketManager.disconnect()
        }
    }
}
