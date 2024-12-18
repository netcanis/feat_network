//
//  HiNetworkManager.swift
//  feat_network
//
//  Created by netcanis on 11/24/24.
//

import Foundation

/// A singleton class responsible for managing network requests.
/// Supports Bearer Token management, Codable-based API requests, Dictionary-based API requests, and file uploads.
public class HiNetworkManager: @unchecked Sendable {
    /// Shared singleton instance for the network manager.
    public static let shared = HiNetworkManager()

    /// Bearer token for authenticated requests.
    private var bearerToken: String?

    /// Key used to store the Bearer token in `UserDefaults`.
    private let tokenKey = "HiBearerToken"

    /// Private initializer to ensure the class is singleton.
    private init() {
        // Load Bearer token from UserDefaults if available.
        self.bearerToken = UserDefaults.standard.string(forKey: tokenKey)
    }

    // MARK: - Bearer Token Management

    /// Sets or updates the Bearer token and saves it to `UserDefaults`.
    /// - Parameter token: The Bearer token string.
    public func setBearerToken(_ token: String) {
        self.bearerToken = token
        UserDefaults.standard.set(token, forKey: tokenKey)
    }

    /// Clears the Bearer token from memory and `UserDefaults`.
    public func clearBearerToken() {
        self.bearerToken = nil
        UserDefaults.standard.removeObject(forKey: tokenKey)
    }

    // MARK: - Codable-based Request

    /// Sends a RESTful API request using a Codable request body and decodes the response into a Codable type.
    /// - Parameters:
    ///   - apiRequest: The API request containing endpoint and optional body.
    ///   - baseURL: The base URL for the API.
    ///   - completion: A completion handler returning the result as success or failure.
    public func request<T: Codable, U: Codable>(
        apiRequest: HiAPIRequest<T>,
        baseURL: String,
        completion: @escaping @Sendable (Result<U, Error>) -> Void
    ) {
        guard let url = URL(string: baseURL + apiRequest.endpoint.path) else {
            completion(.failure(URLError(.badURL)))
            return
        }

        // Build URLRequest with method, headers, and optional body.
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = apiRequest.endpoint.method.rawValue
        urlRequest.allHTTPHeaderFields = apiRequest.endpoint.headers

        // Add Bearer token to the request headers if available.
        if let token = bearerToken {
            urlRequest.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        // Attach query parameters if any.
        if let queryItems = apiRequest.endpoint.queryItems {
            var components = URLComponents(url: url, resolvingAgainstBaseURL: false)
            components?.queryItems = queryItems
            urlRequest.url = components?.url
        }

        // Attach the request body if provided.
        if let body = apiRequest.body {
            do {
                urlRequest.httpBody = try JSONEncoder().encode(body)
                urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
            } catch {
                completion(.failure(error))
                return
            }
        }

        // Execute the request.
        executeRequest(urlRequest: urlRequest, completion: completion)
    }

    // MARK: - Dictionary-based Request

    /// Sends a RESTful API request using a Dictionary of parameters.
    /// - Parameters:
    ///   - endpoint: The API endpoint details.
    ///   - baseURL: The base URL for the API.
    ///   - parameters: The request parameters in Dictionary format.
    ///   - completion: A completion handler returning the result as success or failure.
    public func request<U: Codable>(
        endpoint: HiEndpoint,
        baseURL: String,
        parameters: [String: Any]?,
        completion: @escaping @Sendable (Result<U, Error>) -> Void
    ) {
        guard let url = URL(string: baseURL + endpoint.path) else {
            completion(.failure(URLError(.badURL)))
            return
        }

        // Build URLRequest with method, headers, and optional body.
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = endpoint.method.rawValue
        urlRequest.allHTTPHeaderFields = endpoint.headers

        // Add Bearer token if available.
        if let token = bearerToken {
            urlRequest.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        // Attach query parameters if any.
        if let queryItems = endpoint.queryItems {
            var components = URLComponents(url: url, resolvingAgainstBaseURL: false)
            components?.queryItems = queryItems
            urlRequest.url = components?.url
        }

        // Attach the request body as JSON if parameters are provided.
        if let parameters = parameters {
            do {
                let jsonData = try JSONSerialization.data(withJSONObject: parameters, options: [])
                urlRequest.httpBody = jsonData
                urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
            } catch {
                completion(.failure(error))
                return
            }
        }

        // Execute the request.
        executeRequest(urlRequest: urlRequest, completion: completion)
    }

    // MARK: - File Upload Request

    /// Uploads a file using multipart/form-data.
    /// - Parameters:
    ///   - endpoint: The API endpoint details.
    ///   - baseURL: The base URL for the API.
    ///   - fileData: The file data to upload.
    ///   - fileName: The name of the file.
    ///   - mimeType: The MIME type of the file.
    ///   - additionalParameters: Additional form fields to include in the request.
    ///   - completion: A completion handler returning the result as success or failure.
    public func uploadFile<U: Codable>(
        endpoint: HiEndpoint,
        baseURL: String,
        fileData: Data,
        fileName: String,
        mimeType: String,
        additionalParameters: [String: String]? = nil,
        completion: @escaping @Sendable (Result<U, Error>) -> Void
    ) {
        guard let url = URL(string: baseURL + endpoint.path) else {
            completion(.failure(URLError(.badURL)))
            return
        }

        // Create a multipart form-data request.
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = endpoint.method.rawValue
        urlRequest.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")

        // Add Bearer token to the headers.
        if let token = bearerToken {
            urlRequest.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        // Generate the multipart body.
        let multipartData = createMultipartBody(
            fileData: fileData,
            fileName: fileName,
            mimeType: mimeType,
            parameters: additionalParameters
        )
        urlRequest.httpBody = multipartData

        // Execute the request.
        executeRequest(urlRequest: urlRequest, completion: completion)
    }

    // MARK: - Request Execution

    /// Executes the API request and handles the response.
    private func executeRequest<U: Codable>(
        urlRequest: URLRequest,
        completion: @escaping @Sendable (Result<U, Error>) -> Void
    ) {
        let task = URLSession.shared.dataTask(with: urlRequest) { [completion] data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let httpResponse = response as? HTTPURLResponse, let data = data else {
                completion(.failure(URLError(.badServerResponse)))
                return
            }

            if httpResponse.statusCode != 200 {
                completion(.failure(URLError(.badServerResponse)))
                return
            }

            do {
                let decodedResponse = try JSONDecoder().decode(U.self, from: data)
                completion(.success(decodedResponse))
            } catch {
                completion(.failure(error))
            }
        }
        task.resume()
    }

    // MARK: - Helper Functions

    /// Generates a unique boundary string for multipart form-data.
    private var boundary: String {
        return "Boundary-\(UUID().uuidString)"
    }

    /// Creates the multipart/form-data body.
    private func createMultipartBody(
        fileData: Data,
        fileName: String,
        mimeType: String,
        parameters: [String: String]?
    ) -> Data {
        var body = Data()

        if let parameters = parameters {
            for (key, value) in parameters {
                body.append("--\(boundary)\r\n".data(using: .utf8)!)
                body.append("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n".data(using: .utf8)!)
                body.append("\(value)\r\n".data(using: .utf8)!)
            }
        }

        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"file\"; filename=\"\(fileName)\"\r\n".data(using: .utf8)!)
        body.append("Content-Type: \(mimeType)\r\n\r\n".data(using: .utf8)!)
        body.append(fileData)
        body.append("\r\n".data(using: .utf8)!)
        body.append("--\(boundary)--\r\n".data(using: .utf8)!)

        return body
    }
}
