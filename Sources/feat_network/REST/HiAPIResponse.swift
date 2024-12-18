//
//  HiAPIResponse.swift
//  feat_network
//
//  Created by netcanis on 11/24/24.
//

import Foundation

/// A generic structure representing an API response.
public struct HiAPIResponse<T: Codable>: Codable {
    /// The response data conforming to Codable.
    public let data: T

    /// HTTP status code of the response.
    public let statusCode: Int

    /// A message describing the response.
    public let message: String
}
