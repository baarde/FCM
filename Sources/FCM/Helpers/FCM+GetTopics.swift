import Foundation
import Vapor

extension FCM {
    public func getTopics(token: String, on eventLoop: EventLoop) async throws -> [String] {
        let url = self.iidURL + "info/\(token)?details=true"
        
        let accessToken = try await getAccessToken()
        var headers = HTTPHeaders()
        headers.bearerAuthorization = .init(token: accessToken)
        headers.add(name: "access_token_auth", value: "true")

        let response = try await self.client.get(URI(string: url), headers: headers)
        
        struct Result: Codable {
            let rel: Relations

            struct Relations: Codable {
                let topics: [String: TopicMetadata]
            }

            struct TopicMetadata: Codable {
                let addDate: String
            }
        }
        let result = try response.content.decode(Result.self, using: JSONDecoder())
        return Array(result.rel.topics.keys)
    }
}
