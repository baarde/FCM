import JWTKit
import Testing
import VaporTesting
@testable import FCM

@Suite("FCM Concurrency Tests")
struct FCMConcurrencyTests {
    @Test(
        "Sending message right away should not crash",
        .bug("https://github.com/MihaelIsaev/FCM/issues/57")
    )
    func sendMessageRightAwayAndDoNotCrash() async throws {
        let message = FCMMessageDefault(token: "SOME_TOKEN", notification: nil)
        try await withApp { app in
            // Preload the request so we may use it right away
            let request = request(on: app)
            app.clients.use(.fcmTestResponder(.default))
            app.fcm.configuration = .testing
            _ = try await request.fcm.send(message)
            try await waitForCacheWarmup()
        }
    }
    
    @Test(
        "Shutting the application down right away should not crash",
        .bug("https://github.com/MihaelIsaev/FCM/issues/57")
    )
    func shutApplicationDownRightAwayAndDoNotCrash() async throws {
        for _ in 0..<1000 {
            try await withApp { app in
                app.fcm.configuration = .testing
            }
        }
        try await waitForCacheWarmup()
    }
    
    @Test(
        "Resetting the configuration should not crash",
        .bug("https://github.com/MihaelIsaev/FCM/issues/57")
    )
    func resetConfigurationAndDoNotCrash() async throws {
        try await withApp { app in
            for _ in 0..<1000 {
                app.fcm.configuration = .testing
                app.fcm.configuration = nil
            }
            try await waitForCacheWarmup()
        }
    }
    
    @Test(
        "Changing the configuration should invalidate credentials",
        .bug("https://github.com/MihaelIsaev/FCM/issues/57")
    )
    func changeConfigurationAndInvalidateCredentials() async throws {
        let newAccessToken = "NEW_ACCESS_TOKEN"
        let newMessageName = "NEW_MESSAGE_NAME"
        let newEmail = "new@test.aim.gserviceaccount.com"
        
        var newResponder = FCMTestResponder.default
        newResponder.accessToken { request in
            let jwt = try #require(request.content.decode([String: String].self)["assertion"])
            let payload = try await JWTKeyCollection().unverified(jwt, as: GAuthPayload.self)
            #expect(payload.iss.value == newEmail)
            return newAccessToken
        }
        newResponder.sendMessage { request in
            #expect(request.headers.bearerAuthorization?.token == newAccessToken)
            return newMessageName
        }
        
        let message = FCMMessageDefault(token: "SOME_TOKEN", notification: nil)
        try await withApp { app in
            app.clients.use(.fcmTestResponder(.default))
            app.fcm.configuration = .testing
            try await waitForCacheWarmup()
            _ = try await request(on: app).fcm.send(message)
            
            app.clients.use(.fcmTestResponder(newResponder))
            app.fcm.configuration = .testing(email: newEmail)
            try await waitForCacheWarmup()
            _ = try await request(on: app).fcm.send(message)
        }
    }
    
    func request(on app: Application) -> Request {
        Request(application: app, on: app.eventLoopGroup.any())
    }
    
    func waitForCacheWarmup() async throws  {
        // FCM perform a background task after changing the configuration.
        // Not waiting for task to complete may cause race conditions.
        try await Task.sleep(for: .milliseconds(100))
    }
}
