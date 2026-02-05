import Foundation
import Vapor

extension FCM {
    func getAccessToken() async throws -> String {
        if !gAuth.hasExpired, let token = accessToken {
            return token
        }
        
        let jwt = try await self.getJWT()
        
        let response = try await client.post(URI(string: audience)) { (req) in
            try req.content.encode([
                "grant_type": "urn:ietf:params:oauth:grant-type:jwt-bearer",
                "assertion": jwt,
            ])
        }
        
        try response.validate()
        
        struct Result: Codable {
            let access_token: String
        }

        return try response.content.decode(Result.self, using: JSONDecoder()).access_token
    }
}
