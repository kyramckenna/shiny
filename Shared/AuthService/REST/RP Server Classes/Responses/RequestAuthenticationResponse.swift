import Foundation

internal class RequestAuthenticationResponse: BaseNetworkResponse {
    
    // MARK: - Properties

    internal var w3cAuthenticationRequestRaw: String?
    internal var authenticationRequestId: String?
    internal var challenge: String?
    internal var credentialId: String?
    internal var userVerification: String?
    internal var assertionExtensions: [String: Any]?

    // MARK: - JSON Keys

    private let jsonW3CAuthenticationRequestKey = "w3cAuthenticationRequest"
    private let jsonAuthenticationRequestIdKey = "authenticationRequestId"

    // MARK: - Initialization

    override init(error: ServerOperationError?) {
        super.init(error: error)
    }

    override init(json: Any) {
        super.init(json: json)

        guard let jsonDict = json as? [String: Any] else {
            print("Top-level response is not a dictionary")
            return
        }

        self.authenticationRequestId = jsonDict[jsonAuthenticationRequestIdKey] as? String
        self.w3cAuthenticationRequestRaw = jsonDict[jsonW3CAuthenticationRequestKey] as? String

        // Parse the nested JSON string
        if let raw = w3cAuthenticationRequestRaw,
           let data = raw.data(using: .utf8) {
            do {
                if let parsedW3CRequest = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                    
                    // Parse getAssertionRequestV1
                    if let getAssertionRequestV1 = parsedW3CRequest["getAssertionRequestV1"] as? [String: Any] {
                        self.challenge = getAssertionRequestV1["challenge"] as? String
                        self.userVerification = getAssertionRequestV1["userVerification"] as? String

                        if let allowCredentials = getAssertionRequestV1["allowCredentials"] as? [[String: Any]],
                           let firstCredential = allowCredentials.first {
                            self.credentialId = firstCredential["id"] as? String
                        }
                    }

                    // Parse assertionExtensions
                    if let extensions = parsedW3CRequest["assertionExtensions"] as? [String: Any] {
                        self.assertionExtensions = extensions
                    }

                } else {
                    print("Parsed w3cAuthenticationRequest is not a dictionary")
                }
            } catch {
                print("Failed to parse w3cAuthenticationRequest: \(error.localizedDescription)")
            }
        } else {
            print("w3cAuthenticationRequest string is nil or invalid UTF-8")
        }
    }
}

