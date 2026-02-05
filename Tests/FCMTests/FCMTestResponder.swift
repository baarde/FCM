import Vapor

struct FCMTestResponder: Sendable {
    mutating func respond(to url: URI, with response: ClientResponse) {
        respond(to: url) { _ in response }
    }
    
    mutating func respond(to url: URI, with response: @Sendable @escaping (ClientRequest) async throws -> ClientResponse) {
        responses[url] = response
    }
    
    mutating func accessToken(with perform: @Sendable @escaping (ClientRequest) async throws -> String) {
        respond(to: "https://www.googleapis.com/oauth2/v4/token") { request in
            let accessToken = try await perform(request)
            var response = ClientResponse()
            try response.content.encode(["access_token": accessToken])
            return response
        }
    }
    
    mutating func sendMessage(with perform: @Sendable @escaping (ClientRequest) async throws -> String) {
        respond(to: "https://fcm.googleapis.com/v1/projects/test/messages:send") { request in
            let name = try await perform(request)
            var response = ClientResponse()
            try response.content.encode(["name": name])
            return response
        }
    }
    
    func client(application: Application) -> Client {
        Client(application: application, responder: self)
    }
    
    static let `default`: FCMTestResponder = {
        var responder = FCMTestResponder()
        responder.accessToken { _ in "DEFAULT_ACCESS_TOKEN" }
        responder.sendMessage { _ in "DEFAULT_MESSAGE_NAME" }
        return responder
    }()
    
    fileprivate var responses: [URI: @Sendable (ClientRequest) async throws -> ClientResponse] = [:]
}

extension FCMTestResponder {
    struct Client: Vapor.Client {
        let application: Application
        let responder: FCMTestResponder
        
        var eventLoop: EventLoop {
            application.eventLoopGroup.any()
        }
        
        func delegating(to eventLoop: EventLoop) -> Vapor.Client {
            self
        }
        
        func send(_ request: ClientRequest) -> EventLoopFuture<ClientResponse> {
            let url = request.url
            guard let response = responder.responses[url] else {
                let error = Abort(.notImplemented, reason: "No registered response for url: '\(url)'.")
                return eventLoop.future(error: error)
            }
            return eventLoop.makeFutureWithTask {
                try await response(request)
            }
        }
    }
}

extension Application.Clients.Provider {
    static func fcmTestResponder(_ responder: FCMTestResponder) -> Application.Clients.Provider {
        .init { application in
            application.clients.use { application in
                responder.client(application: application)
            }
        }
    }
}
