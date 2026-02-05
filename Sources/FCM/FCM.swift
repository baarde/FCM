import Foundation
import JWT
import NIOConcurrencyHelpers
import Vapor

// MARK: Engine

public final class FCM: Sendable {
    public let client: Client
    public let configuration: FCMConfiguration

    let scope = "https://www.googleapis.com/auth/cloud-platform"
    let audience = "https://www.googleapis.com/oauth2/v4/token"
    let actionsBaseURL = "https://fcm.googleapis.com/v1/projects/"
    let iidURL = "https://iid.googleapis.com/iid/v1:"
    let batchURL = "https://fcm.googleapis.com/batch"

    private let cache: NIOLockedValueBox<Cache>

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
        self.cache = NIOLockedValueBox(Cache(email: configuration.email, scope: scope, audience: audience))
        warmUpCache()
    }
}

// MARK: Cache

extension FCM {
    var gAuth: GAuthPayload {
        cache.withLockedValue(\.gAuth)
    }

    var jwt: String? {
        cache.withLockedValue(\.jwt)
    }

    var accessToken: String? {
        cache.withLockedValue(\.accessToken)
    }

    func store(gAuth: GAuthPayload, jwt: String?) {
        cache.withLockedValue { cache in
            cache.gAuth = gAuth
            cache.jwt = jwt
        }
    }

    private struct Cache {
        var gAuth: GAuthPayload
        var jwt: String?
        var accessToken: String?

        init(email: String, scope: String, audience: String) {
            gAuth = GAuthPayload(iss: email, sub: email, scope: scope, aud: audience)
        }
    }

    private func warmUpCache() {
        Task {
            do {
                _ = try await getJWT()
            } catch {
                fatalError("FCM Unable to generate JWT: \(error)")
            }
        }
    }
}
