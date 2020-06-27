//
//  RestApiTransport.swift
//  PersonalVPN
//
//  Created by Andrey Chernyshev on 27.06.2020.
//  Copyright © 2020 org. All rights reserved.
//

import RxSwift
import Alamofire

final class RestAPITransport {
    func callServerApi(requestBody: APIRequestBody) -> Single<Any> {
        Single
            .create { event in
                let session = Alamofire.Session.default
                session.sessionConfiguration.timeoutIntervalForRequest = 30
            
                let encodedUrl = requestBody.url.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!
                
                let request = session.request(encodedUrl,
                                              method: requestBody.method,
                                              parameters: requestBody.parameters,
                                              encoding: requestBody.encoding,
                                              headers: requestBody.headers)
                    .validate(statusCode: [200, 201])
                    .responseJSON(completionHandler: { response in
                        switch response.result {
                        case .success(let json):
                            event(.success(json))
                        case .failure(_):
                            event(.error(ApiError.serverUnavailable))
                        }
                    })
            
                return Disposables.create {
                    request.cancel()
                }
            }
    }
}

