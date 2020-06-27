//
//  CheckTokenResponseMapper.swift
//  PersonalVPN
//
//  Created by Andrey Chernyshev on 27.06.2020.
//  Copyright © 2020 org. All rights reserved.
//

final class CheckTokenResponseMapper {
    static func map(from response: Any) -> CheckTokenResponse? {
        guard
            let json = response as? [String: Any],
            let data = json["_data"] as? [String: Any]
        else {
            return nil
        }
        
        guard
            let userToken = data["user_token"] as? String,
            let activeSubscription = data["active_subscription"] as? Bool
        else {
            return nil
        }
        
        let needPayment = json["_need_payment"] as? Bool
        
        let userIdInt = data["user_id"] as? Int
        var userId: String?
        if let userIdInt = userIdInt {
            userId = String(userIdInt)
        }
        
        return CheckTokenResponse(needPayment: needPayment ?? true,
                                  userToken: userToken,
                                  activeSubscription: activeSubscription,
                                  userId: userId)
    }
}
