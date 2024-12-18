//
//  HiAPIRequest.swift
//  feat_network
//
//  Created by netcanis on 11/24/24.
//

import Foundation

/// A generic structure representing an API request with an endpoint and optional body.
public struct HiAPIRequest<T: Codable> {
    /// API endpoint information.
    public let endpoint: HiEndpoint

    /// Request body conforming to Codable, optional.
    public let body: T?

    /// Initializes a new API request.
    /// - Parameters:
    ///   - endpoint: The API endpoint details.
    ///   - body: The request body (optional).
    public init(endpoint: HiEndpoint, body: T? = nil) {
        self.endpoint = endpoint
        self.body = body
    }
}
