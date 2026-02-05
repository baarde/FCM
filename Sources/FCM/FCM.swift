import Foundation
import JWT
import Vapor

// MARK: Engine

public class FCM: @unchecked Sendable {
    let client: Client
    let configuration: FCMConfiguration

    var gAuth: GAuthPayload
    var accessToken: String?
    var jwt: String?

    let scope = "https://www.googleapis.com/auth/cloud-platform"
    let audience = "https://www.googleapis.com/oauth2/v4/token"
    let actionsBaseURL = "https://fcm.googleapis.com/v1/projects/"
    let iidURL = "https://iid.googleapis.com/iid/v1:"
    let batchURL = "https://fcm.googleapis.com/batch"

    // MARK: Default configurations

    public var apnsDefaultConfig: FCMApnsConfig<FCMApnsPayload>? {
        configuration.apnsDefaultConfig
    }

    public var androidDefaultConfig: FCMAndroidConfig? {
        configuration.androidDefaultConfig
    }

    public var webpushDefaultConfig: FCMWebpushConfig? {
        configuration.webpushDefaultConfig
    }

    // MARK: Initialization

    public init(client: Client, configuration: FCMConfiguration) {
        self.client = client
        self.configuration = configuration
        self.gAuth = GAuthPayload(iss: configuration.email, sub: configuration.email, scope: scope, aud: audience)
        warmUpCache()
    }
}

// MARK: Cache

extension FCM {
    private func warmUpCache() {
        Task {
            do {
                jwt = try await generateJWT()
            } catch {
                fatalError("FCM Unable to generate JWT: \(error)")
            }
        }
    }
}
