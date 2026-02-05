import Foundation
import JWT

extension FCM {
    func generateJWT() async throws -> String {
        guard let pemData = configuration.key.data(using: .utf8) else {
            fatalError("FCM unable to prepare PEM data for JWT")
        }
        self.gAuth = gAuth.updated()
        let pk = try Insecure.RSA.PrivateKey(pem: pemData)
        let keys = await JWTKeyCollection().add(rsa: pk, digestAlgorithm: .sha256)
        return try await keys.sign(gAuth)
    }
    
    func getJWT() async throws -> String {
        if !gAuth.hasExpired, let jwt = jwt {
            return jwt
        }
        let jwt = try await generateJWT()
        self.jwt = jwt
        return jwt
    }
}
