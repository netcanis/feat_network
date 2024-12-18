# **feat_network**

A **Swift Package** for managing network operations, including RESTful API requests, file uploads, WebSocket communication, and TCP socket connections in iOS.

---

## **Overview**

`feat_network` is a lightweight and modular Swift package that provides:

- RESTful API communication with **GET**, **POST**, **PUT**, **DELETE**, and **PATCH** methods.
- Support for **Bearer Token** authentication.
- File upload support with **multipart/form-data**.
- TCP Socket connections for real-time communication.
- WebSocket communication for **text** and **binary** data transfer.

This module is compatible with **iOS 16 and above** and supports integration via **Swift Package Manager (SPM)**.

---

## **Features**

- ✅ **RESTful API Support**: Simplified API requests with JSON encoding and decoding.
- ✅ **File Upload**: Support for `multipart/form-data` file uploads.
- ✅ **Bearer Token Management**: Easily set, update, and clear Bearer tokens for authentication.
- ✅ **WebSocket Communication**: Send and receive text or binary messages.
- ✅ **TCP Socket Support**: Manage TCP connections for sending and receiving data.

---

## **Requirements**

| Requirement     | Minimum Version         |
|------------------|-------------------------|
| **iOS**         | 16.0                    |
| **Swift**       | 5.7                     |
| **Xcode**       | 14.0                    |

---

## **Installation**

### **Swift Package Manager (SPM)**

1. Open your project in **Xcode**.
2. Navigate to **File > Add Packages...**.
3. Enter the repository URL:  https://github.com/netcanis/feat_network.git
4. Select the version and integrate the package into your project.

---

## **Usage**

### **1. RESTful API Requests**

#### Codable-based API Request
```swift
import feat_network

struct RequestBody: Codable {
 let key: String
}

struct ResponseData: Codable {
 let message: String
}

let endpoint = HiEndpoint(path: "/api/v1/test", method: .POST)
let request = HiAPIRequest(endpoint: endpoint, body: RequestBody(key: "value"))

HiNetworkManager.shared.request(apiRequest: request, baseURL: "https://example.com") { (result: Result<ResponseData, Error>) in
 switch result {
 case .success(let response):
     print("Response: \(response.message)")
 case .failure(let error):
     print("Error: \(error.localizedDescription)")
 }
}
```

#### Dictionary-based API Request
```swift
let endpoint = HiEndpoint(path: "/api/v1/test", method: .POST)

HiNetworkManager.shared.request(endpoint: endpoint, baseURL: "https://example.com", parameters: ["key": "value"]) { (result: Result<ResponseData, Error>) in
    switch result {
    case .success(let response):
        print("Response: \(response.message)")
    case .failure(let error):
        print("Error: \(error.localizedDescription)")
    }
}
```

### **2. File Upload**
```swift
let endpoint = HiEndpoint(path: "/api/v1/upload", method: .POST)
guard let fileURL = Bundle.main.url(forResource: "example", withExtension: "jpg"),
    let fileData = try? Data(contentsOf: fileURL) else {
    print("File load failed.")
    return
}
HiNetworkManager.shared.uploadFile(
    endpoint: endpoint,
    baseURL: "https://example.com",
    fileData: fileData,
    fileName: "example.jpg",
    mimeType: "image/jpeg"
) { (result: Result<ResponseData, Error>) in
    switch result {
    case .success(let response):
        print("File upload successful: \(response.message)")
    case .failure(let error):
        print("Error uploading file: \(error.localizedDescription)")
    }
}
```

### **3. Bearer Token Management**
```swift
HiNetworkManager.shared.setBearerToken("your_bearer_token")
HiNetworkManager.shared.clearBearerToken()
```

### **4. TCP Socket Connection**
```swift
import feat_network

let socketManager = HiSocketManager()
socketManager.connect(to: "example.com", port: 8080)

let message = "Hello, Server".data(using: .utf8)!
socketManager.send(data: message)

socketManager.receive { data in
    if let data = data, let response = String(data: data, encoding: .utf8) {
        print("Received: \(response)")
    }
}

socketManager.disconnect()
```

### **5. WebSocket Communication**
```swift
import feat_network

let webSocketManager = HiWebSocketManager()
webSocketManager.connect(to: URL(string: "wss://example.com/socket")!)

webSocketManager.onMessageReceived = { result in
    switch result {
    case .success(.text(let text)):
        print("Received text message: \(text)")
    case .success(.binary(let data)):
        print("Received binary data: \(data.count) bytes")
    case .failure(let error):
        print("Error: \(error.localizedDescription)")
    }
}

webSocketManager.send(message: "Hello WebSocket")
webSocketManager.disconnect()
```

---

## **License**

feat_qr is available under the MIT License. See the LICENSE file for details.

---

## **Contributing**

Contributions are welcome! To contribute:

1. Fork this repository.
2. Create a feature branch:
```
git checkout -b feature/your-feature
```
3. Commit your changes:
```
git commit -m "Add feature: description"
```
4. Push to the branch:
```
git push origin feature/your-feature
```
5. Submit a Pull Request.

---

## **Author**

### **netcanis**
GitHub: https://github.com/netcanis

---
