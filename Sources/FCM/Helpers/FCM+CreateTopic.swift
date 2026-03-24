import Foundation
import Vapor

extension FCM {
//    public func createTopic(_ name: String? = nil, tokens: String...) async throws -> String {
//        try await createTopic(name, tokens: tokens)
//    }
//
//    public func createTopic(_ name: String? = nil, tokens: String..., on eventLoop: EventLoop) async throws -> String {
//        try await createTopic(name, tokens: tokens).hop(to: eventLoop)
//    }

    public func createTopic(_ name: String? = nil, tokens: [String]) async throws -> String {
        try await _createTopic(name, tokens: tokens)
    }

//    public func createTopic(_ name: String? = nil, tokens: [String], on eventLoop: EventLoop) async throws -> String {
//        try await _createTopic(name, tokens: tokens).hop(to: eventLoop)
//    }

    private func _createTopic(_ name: String? = nil, tokens: [String]) async throws -> String {
        let url = self.iidURL + "batchAdd"
        let name = name ?? UUID().uuidString
        
        let accessToken = try await getAccessToken()
        var headers = HTTPHeaders()
        headers.bearerAuthorization = .init(token: accessToken)
        headers.add(name: "access_token_auth", value: "true")

        let response = try await self.client.post(URI(string: url), headers: headers) { (req) in
            struct Payload: Content {
                let to: String
                let registration_tokens: [String]
                
                init(to: String, registration_tokens: [String]) {
                    self.to = "/topics/\(to)"
                    self.registration_tokens = registration_tokens
                }
            }
            let payload = Payload(to: name, registration_tokens: tokens)
            try req.content.encode(payload)
        }
        
        guard 200 ..< 300 ~= response.status.code else {
            if let error = try? response.content.decode(GoogleError.self) {
                throw error
            }
            let body = response.body.map(String.init) ?? ""
            throw Abort(.internalServerError, reason: "FCM: Unexpected error '\(body)'")
        }
        
        return name
    }
}
