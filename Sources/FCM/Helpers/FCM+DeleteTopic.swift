import Foundation
import Vapor

extension FCM {
    public func deleteTopic(_ name: String, tokens: String...) -> EventLoopFuture<Void> {
        deleteTopic(name, tokens: tokens)
    }

    public func deleteTopic(_ name: String, tokens: String..., on eventLoop: EventLoop) -> EventLoopFuture<Void> {
        deleteTopic(name, tokens: tokens).hop(to: eventLoop)
    }

    public func deleteTopic(_ name: String, tokens: [String]) -> EventLoopFuture<Void> {
        _deleteTopic(name, tokens: tokens)
    }

    public func deleteTopic(_ name: String, tokens: [String], on eventLoop: EventLoop) -> EventLoopFuture<Void> {
        _deleteTopic(name, tokens: tokens).hop(to: eventLoop)
    }

    private func _deleteTopic(_ name: String, tokens: [String]) -> EventLoopFuture<Void> {
        guard let configuration = self.configuration else {
            fatalError("FCM not configured. Use app.fcm.configuration = ...")
        }
        let url = self.iidURL + "batchRemove"
        return getAccessToken().flatMap { accessToken -> EventLoopFuture<ClientResponse> in
            var headers = HTTPHeaders()
            headers.bearerAuthorization = .init(token: accessToken)
            headers.add(name: "access_token_auth", value: "true")

            return self.client.post(URI(string: url), headers: headers) { (req) in
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
        }
        .validate()
        .map { _ in () }
    }
}
