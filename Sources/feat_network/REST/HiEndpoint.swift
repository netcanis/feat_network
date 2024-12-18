//
//  HiEndpoint.swift
//  feat_network
//
//  Created by netcanis on 11/24/24.
//

import Foundation

/// A structure representing API endpoint information.
public struct HiEndpoint {
    /// The URL path for the endpoint.
    public let path: String

    /// HTTP method for the request (e.g., GET, POST).
    public let method: HTTPMethod

    /// Optional headers for the request.
    public let headers: [String: String]?

    /// Optional query parameters for the request.
    public let queryItems: [URLQueryItem]?

    /// Initializes an API endpoint with the provided details.
    /// - Parameters:
    ///   - path: The URL path for the endpoint.
    ///   - method: HTTP method.
    ///   - headers: Optional request headers.
    ///   - queryItems: Optional query parameters.
    public init(path: String, method: HTTPMethod, headers: [String: String]? = nil, queryItems: [URLQueryItem]? = nil) {
        self.path = path
        self.method = method
        self.headers = headers
        self.queryItems = queryItems
    }
}

/// Enum representing the HTTP methods used for network requests.
public enum HTTPMethod: String {
    case GET, POST, PUT, DELETE, PATCH
}
