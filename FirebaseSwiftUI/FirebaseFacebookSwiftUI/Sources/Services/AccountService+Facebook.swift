// Copyright 2025 Google LLC
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

//
//  AccountService+Facebook.swift
//  FirebaseUI
//
//  Created by Russell Wheatley on 14/05/2025.
//

@preconcurrency import FirebaseAuth
import FirebaseAuthSwiftUI
import Observation

protocol FacebookOperationReauthentication {
  var facebookProvider: FacebookProviderAuthUI { get }
}

extension FacebookOperationReauthentication {
  @MainActor func reauthenticate() async throws -> AuthenticationToken {
    guard let user = Auth.auth().currentUser else {
      throw AuthServiceError.reauthenticationRequired("No user currently signed-in")
    }

    do {
      let credential = try await facebookProvider
        .signInWithFacebook(isLimitedLogin: facebookProvider.isLimitedLogin)
      try await user.reauthenticate(with: credential)

      return .firebase("")
    } catch {
      throw AuthServiceError.signInFailed(underlying: error)
    }
  }
}

@MainActor
class FacebookDeleteUserOperation: AuthenticatedOperation,
  @preconcurrency FacebookOperationReauthentication {
  let facebookProvider: FacebookProviderAuthUI
  init(facebookProvider: FacebookProviderAuthUI) {
    self.facebookProvider = facebookProvider
  }

  func callAsFunction(on user: User) async throws {
    try await callAsFunction(on: user) {
      try await user.delete()
    }
  }
}
