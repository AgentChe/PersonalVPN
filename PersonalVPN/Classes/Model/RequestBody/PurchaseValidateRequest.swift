//
//  PurchaseValidateRequest.swift
//  PersonalVPN
//
//  Created by Andrey Chernyshev on 27.06.2020.
//  Copyright © 2020 org. All rights reserved.
//

import Alamofire

struct PurchaseValidateRequest: APIRequestBody {
    private let receipt: String
    private let userToken: String?
    private let version: String?
    
    init(receipt: String, userToken: String?, version: String?) {
        self.receipt = receipt
        self.userToken = userToken
        self.version = version
    }
    
    var method: Alamofire.HTTPMethod {
        .post
    }
    
    var url: String {
        GlobalDefinitions.domainUrl + "/api/payments/validate"
    }
    
    var parameters: Alamofire.Parameters? {
        var params = [
            "receipt": receipt,
            "version": version ?? "1",
            "_api_key": GlobalDefinitions.apiKey
        ]
        
        if let userToken = userToken {
            params["_user_token"] = userToken
        }
        
        return params
    }
}
