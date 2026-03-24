import Foundation
import Vapor

public struct RegisterAPNSID {
    let appBundleId: String
    let sandbox: Bool

    public init (appBundleId: String, sandbox: Bool = false) {
        self.appBundleId = appBundleId
        self.sandbox = sandbox
    }
}

extension RegisterAPNSID {
    public static var env: RegisterAPNSID {
        guard let appBundleId = Environment.get("FCM_APP_BUNDLE_ID") else {
            fatalError("FCM: Register APNS: missing FCM_APP_BUNDLE_ID environment variable")
        }
        return .init(appBundleId: appBundleId)
    }
}

extension RegisterAPNSID {
    public static var envSandbox: RegisterAPNSID {
        .init(appBundleId: RegisterAPNSID.env.appBundleId, sandbox: true)
    }
}

public struct APNSToFirebaseToken {
    public let registration_token, apns_token: String
    public let isRegistered: Bool
}

extension FCM {
    /// Helper method which registers your pure APNS token in Firebase Cloud Messaging
    /// and returns firebase tokens for each APNS token
    ///
    /// Convenient way
    ///
    /// Declare `RegisterAPNSID` via extension
    /// ```swift
    /// extension RegisterAPNSID {
    ///     static var myApp: RegisterAPNSID { .init(appBundleId: "com.myapp") }
    /// }
    /// ```
    ///
    public func registerAPNS(
        _ id: RegisterAPNSID,
        tokens: String...
    ) async throws -> [APNSToFirebaseToken] {
        try await registerAPNS(appBundleId: id.appBundleId, sandbox: id.sandbox, tokens: tokens)
    }

    /// Helper method which registers your pure APNS token in Firebase Cloud Messaging
    /// and returns firebase tokens for each APNS token
    ///
    /// Convenient way
    ///
    /// Declare `RegisterAPNSID` via extension
    /// ```swift
    /// extension RegisterAPNSID {
    ///     static var myApp: RegisterAPNSID { .init(appBundleId: "com.myapp") }
    /// }
    /// ```
    ///
    public func registerAPNS(
        _ id: RegisterAPNSID,
        tokens: [String]
    ) async throws -> [APNSToFirebaseToken] {
        try await registerAPNS(appBundleId: id.appBundleId, sandbox: id.sandbox, tokens: tokens)
    }

    /// Helper method which registers your pure APNS token in Firebase Cloud Messaging
    /// and returns firebase tokens for each APNS token
    public func registerAPNS(
        appBundleId: String,
        sandbox: Bool = false,
        tokens: String...
    ) async throws -> [APNSToFirebaseToken] {
        try await registerAPNS(appBundleId: appBundleId, sandbox: sandbox, tokens: tokens)
    }

    /// Helper method which registers your pure APNS token in Firebase Cloud Messaging
    /// and returns firebase tokens for each APNS token
    public func registerAPNS(
        appBundleId: String,
        sandbox: Bool = false,
        tokens: [String]
    ) async throws -> [APNSToFirebaseToken] {
        guard tokens.count <= 100 else {
            throw Abort(.internalServerError, reason: "FCM: Register APNS: tokens count should be less or equal 100")
        }
        
        guard tokens.count > 0 else {
            return []
        }
        
        let url = iidURL + "batchImport"
        
        let accessToken = try await getAccessToken()
        var headers = HTTPHeaders()
        headers.bearerAuthorization = .init(token: accessToken)
        headers.add(name: "access_token_auth", value: "true")
        
        let response = try await self.client.post(URI(string: url), headers: headers) { req in
            struct Payload: Content {
                let application: String
                let sandbox: Bool
                let apns_tokens: [String]
            }
            let payload = Payload(application: appBundleId, sandbox: sandbox, apns_tokens: tokens)
            try req.content.encode(payload)
        }
        
        try response.validate()
        
        struct Result: Codable {
            struct Result: Codable {
                let registration_token, apns_token, status: String
            }
            let results: [Result]
        }
        
        let result = try response.content.decode(Result.self)
        return result.results.map {
            .init(registration_token: $0.registration_token, apns_token: $0.apns_token, isRegistered: $0.status == "OK")
        }
    }
}
