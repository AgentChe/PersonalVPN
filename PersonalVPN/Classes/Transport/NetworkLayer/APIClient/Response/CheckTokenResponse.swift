//
// Created by Anton Serov on 29.10.2019.
// Copyright (c) 2019 org. All rights reserved.
//

import Foundation

enum CheckTokenResponseCreationError: Error {
    case missingValue
}

struct CheckTokenResponse: ResponseProtocol {
    let needPayment: Bool
    let userToken: String
    let activeSubscription: Bool
    let userId: String?

    init(rawResponse: Dictionary<String, AnyObject>) throws {
        let _userToken: String? = rawResponse["user_token"] as? String
        let _activeSubscription: Bool? = rawResponse["active_subscription"] as? Bool
        let _needPayment: Bool? = rawResponse["_need_payment"] as? Bool
        let _userId: Int? = rawResponse["user_id"] as? Int

        guard let ut = _userToken, let acs = _activeSubscription, let np = _needPayment, let ui = _userId else {
            throw CheckTokenResponseCreationError.missingValue
        }

        self.userToken = ut
        self.activeSubscription = acs
        self.userId = String(ui)
        self.needPayment = np
    }
}
