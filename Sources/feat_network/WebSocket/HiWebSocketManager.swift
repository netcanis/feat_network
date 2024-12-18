//
//  HiWebSocketManager.swift
//  feat_network
//
//  Created by netcanis on 11/24/24.
//

import Foundation

/// A class for managing WebSocket connections and handling message transmission.
public class HiWebSocketManager: NSObject, @unchecked Sendable, URLSessionWebSocketDelegate {
    /// The WebSocket task for handling the connection.
    private var webSocketTask: URLSessionWebSocketTask?

    /// The URLSession used for WebSocket communication.
    private let session: URLSession

    /// Enumeration representing WebSocket message types.
    public enum Message {
        /// A text message.
        case text(String)
        /// A binary data message.
        case binary(Data)
    }

    /// Callback for receiving messages from the WebSocket.
    public var onMessageReceived: ((Result<Message, Error>) -> Void)?

    /// Initializes the WebSocket manager.
    public override init() {
        let configuration = URLSessionConfiguration.default
        session = URLSession(configuration: configuration, delegate: nil, delegateQueue: OperationQueue())
        super.init()
    }

    // MARK: - WebSocket Connection Management

    /// Establishes a WebSocket connection to the specified URL.
    /// - Parameter url: The URL to connect to.
    public func connect(to url: URL) {
        webSocketTask = session.webSocketTask(with: url)
        webSocketTask?.resume()
        print("WebSocket connected to \(url)")
        listen() // Start listening for messages.
    }

    /// Disconnects the WebSocket connection.
    public func disconnect() {
        webSocketTask?.cancel(with: .goingAway, reason: nil)
        print("WebSocket disconnected")
    }

    // MARK: - Message Transmission

    /// Sends a text message over the WebSocket connection.
    /// - Parameter message: The message to send as a string.
    public func send(message: String) {
        let message = URLSessionWebSocketTask.Message.string(message)
        webSocketTask?.send(message) { error in
            if let error = error {
                print("WebSocket send error: \(error.localizedDescription)")
            } else {
                print("Message sent")
            }
        }
    }

    /// Sends binary data over the WebSocket connection.
    /// - Parameter data: The binary data to send.
    public func send(data: Data) {
        let message = URLSessionWebSocketTask.Message.data(data)
        webSocketTask?.send(message) { error in
            if let error = error {
                print("WebSocket send error: \(error.localizedDescription)")
            } else {
                print("Binary data sent")
            }
        }
    }

    // MARK: - Message Reception

    /// Starts listening for incoming messages from the WebSocket connection.
    private func listen() {
        webSocketTask?.receive { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let message):
                switch message {
                case .string(let text):
                    self.onMessageReceived?(.success(.text(text)))
                case .data(let data):
                    self.onMessageReceived?(.success(.binary(data)))
                @unknown default:
                    print("Unknown message type")
                }
            case .failure(let error):
                self.onMessageReceived?(.failure(error))
            }
            // Continue listening for additional messages.
            self.listen()
        }
    }
}
