//
//  PasskeyChecker.swift
//  Shiny
//
//  Created by kmckenna2 on 01/07/2025.
//  Copyright © 2025 Apple. All rights reserved.
//


import AuthenticationServices

class PasskeyChecker: NSObject, ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding {
    private var completion: ((Bool) -> Void)?
    private let provider: ASAuthorizationPlatformPublicKeyCredentialProvider
    private let challengeData: Data
    private weak var presentationAnchor: ASPresentationAnchor?

    init(challenge: String, relyingPartyID: String, presentationAnchor: ASPresentationAnchor) {
        self.provider = ASAuthorizationPlatformPublicKeyCredentialProvider(relyingPartyIdentifier: relyingPartyID)
        self.challengeData = Data(base64Encoded: challenge) ?? Data()
        self.presentationAnchor = presentationAnchor
    }

    func checkLocalPasskeyAvailability(completion: @escaping (Bool) -> Void) {
        self.completion = completion

        let assertionRequest = provider.createCredentialAssertionRequest(challenge: challengeData)
        let authController = ASAuthorizationController(authorizationRequests: [assertionRequest])
        authController.delegate = self
        authController.presentationContextProvider = self

        authController.performRequests(options: .preferImmediatelyAvailableCredentials)
    }

    // MARK: - ASAuthorizationControllerDelegate

    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        // If we get here, credentials exist and succeeded!
        completion?(true)
        completion = nil
    }

    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        if let authError = error as? ASAuthorizationError, authError.code == .canceled {
            // No credentials found locally
            print("No local passkeys available or user canceled")
            completion?(false)
        } else {
            print("Authorization failed with error: \(error)")
            completion?(false)
        }
        completion = nil
    }

    // MARK: - ASAuthorizationControllerPresentationContextProviding

    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return presentationAnchor ?? ASPresentationAnchor()
    }
}
