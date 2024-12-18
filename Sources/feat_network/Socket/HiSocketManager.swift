//
//  HiSocketManager.swift
//  feat_network
//
//  Created by netcanis on 11/24/24.
//

import Foundation
import Network

/// A class for managing TCP socket connections and data transfer.
public class HiSocketManager: @unchecked Sendable {
    /// The active socket connection.
    private var connection: NWConnection?

    /// A serial queue for socket operations.
    private let queue = DispatchQueue(label: "HiSocketManager.Queue")

    /// Initializes a new instance of `HiSocketManager`.
    public init() {}

    /// Establishes a TCP socket connection to the specified host and port.
    /// - Parameters:
    ///   - host: The hostname or IP address of the server.
    ///   - port: The port number to connect to.
    public func connect(to host: String, port: UInt16) {
        // Define the endpoint for the connection.
        let endpoint = NWEndpoint.hostPort(host: NWEndpoint.Host(host), port: NWEndpoint.Port(integerLiteral: port))

        // Create a new TCP connection.
        connection = NWConnection(to: endpoint, using: .tcp)

        // Monitor the connection state.
        connection?.stateUpdateHandler = { state in
            switch state {
            case .ready:
                print("Socket connected to \(host):\(port)")
            case .failed(let error):
                print("Socket connection failed: \(error.localizedDescription)")
            case .waiting(let error):
                print("Socket waiting for connection: \(error.localizedDescription)")
            default:
                break
            }
        }

        // Start the connection on the defined queue.
        connection?.start(queue: queue)
    }

    /// Sends data over the socket connection.
    /// - Parameter data: The data to be sent.
    public func send(data: Data) {
        connection?.send(content: data, completion: .contentProcessed({ error in
            if let error = error {
                print("Send error: \(error.localizedDescription)")
            } else {
                print("Data sent successfully")
            }
        }))
    }

    /// Receives data from the socket connection.
    /// - Parameter completion: A closure called with the received data or `nil` if an error occurred.
    public func receive(completion: @escaping @Sendable (Data?) -> Void) {
        connection?.receive(minimumIncompleteLength: 1, maximumLength: 1024) { data, _, isComplete, error in
            if let error = error {
                print("Receive error: \(error.localizedDescription)")
                completion(nil)
            } else if isComplete {
                print("Connection closed")
                completion(nil)
            } else {
                completion(data)
            }
        }
    }

    /// Closes the socket connection.
    public func disconnect() {
        connection?.cancel()
        print("Socket disconnected")
    }
}
