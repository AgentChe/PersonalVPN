//
//  PaygateService.swift
//  PersonalVPN
//
//  Created by Andrey Chernyshev on 27.06.2020.
//  Copyright © 2020 org. All rights reserved.
//

import RxSwift

final class PaygateService {}

// MARK: Retrieve

extension PaygateService {
    static func retrievePaygate() -> Single<PaygateMapper.PaygateResponse?> {
        let request = GetPaygateRequest(userToken: NetworkConfiguration.userToken,
                                        version: UIDevice.appVersion ?? "1",
                                        appInstallKey: UserDefaultsStorage.shared.uniqRandomId)
        
        return RestAPITransport()
            .callServerApi(requestBody: request)
            .map { PaygateMapper.parse(response: $0, productsPrices: nil) }
    }
}

// MARK: Prepare prices

extension PaygateService {
    static func prepareProductsPrices(for paygate: PaygateMapper.PaygateResponse) -> Single<PaygateMapper.PaygateResponse?> {
        guard !paygate.productsIds.isEmpty else {
            return .deferred { .just(paygate) }
        }
        
        return PurchaseService
            .productsPrices(ids: paygate.productsIds)
            .map { PaygateMapper.parse(response: paygate.json, productsPrices: $0.retrievedPrices) }
    }
}
