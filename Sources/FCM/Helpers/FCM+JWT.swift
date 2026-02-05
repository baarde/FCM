import Foundation
import JWT

extension FCM {
    func generateJWT(for gAuth: GAuthPayload) async throws -> String {
        let pemData = Data(configuration.key.utf8)
        let pk = try Insecure.RSA.PrivateKey(pem: pemData)
        let keys = await JWTKeyCollection().add(rsa: pk, digestAlgorithm: .sha256)
        return try await keys.sign(gAuth)
    }
    
    func getJWT() async throws -> String {
        if !gAuth.hasExpired, let jwt = jwt {
            return jwt
        }
        let gAuth = gAuth.updated()
        let jwt = try await generateJWT(for: gAuth)
        store(gAuth: gAuth, jwt: jwt)
        return jwt
    }
}
