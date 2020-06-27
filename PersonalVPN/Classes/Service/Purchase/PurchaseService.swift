//
//  PaymentService.swift
//  SleepWell
//
//  Created by Andrey Chernyshev on 25/10/2019.
//  Copyright © 2019 Andrey Chernyshev. All rights reserved.
//

import RxSwift
import SwiftyStoreKit

final class PurchaseService {
    static func register() {
        SwiftyStoreKit.completeTransactions { purchases in
            for purchase in purchases {
                let state = purchase.transaction.transactionState
                if state == .purchased || state == .restored {
                    SwiftyStoreKit.finishTransaction(purchase.transaction)
                }
            }
        }
    }
}

// MARK: Purchase

extension PurchaseService {
    static func buySubscription(productId: String) -> Single<Void> {
        Single<Void>.create { single in
            SwiftyStoreKit.purchaseProduct(productId, quantity: 1, atomically: true) { result in
                switch result {
                case .success(_):
                    single(.success(Void()))
                case .error(_):
                    single(.error(PurchaseError.failedPurchaseProduct))
                }
            }
            
            return Disposables.create()
        }
    }
    
    static func restoreSubscription(productId: String) -> Single<Void> {
        Single<Void>.create { single in
            SwiftyStoreKit.restorePurchases(atomically: true) { result in
                if result.restoredPurchases.isEmpty {
                    single(.error(PurchaseError.nonProductsForRestore))
                } else if result.restoredPurchases.contains(where: { $0.productId == productId }) {
                    single(.success(Void()))
                } else {
                    single(.error(PurchaseError.failedRestorePurchases))
                }
            }
            
            return Disposables.create()
        }
    }
}

// MARK: Validate

extension PurchaseService {
    static func paymentValidate(receipt: String) -> Single<CheckTokenResponse?> {
        Single<CheckTokenResponse?>
            .create { event in
                guard let client = ClientContainer.sharedContainer.container.resolve(Client.self) as? (CheckClient & PaymentsClient & VpnClient) else {
                    event(.success(nil))
                    return Disposables.create()
                }
                
                client.validate(receipt: receipt) { response, _ in
                    event(.success(response))
                }
                
                return Disposables.create()
            }
            .do(onSuccess: { response in
                guard let response = response else {
                    return
                }
                
                NetworkConfiguration.userToken = response.userToken
                UserDefaultsStorage.shared.activeSubscription = response.activeSubscription
                UserDefaultsStorage.shared.needPayment = response.needPayment
                UserDefaultsStorage.shared.userId = response.userId
            })
    }
    
    static func paymentValidate() -> Single<CheckTokenResponse?> {
        return receipt
            .flatMap { receiptBase64 -> Single<CheckTokenResponse?> in
                guard let receipt = receiptBase64 else {
                    return .just(nil)
                }
                
                return paymentValidate(receipt: receipt)
            }
    }
}

// MARK: Price

extension PurchaseService {
    static func productsPrices(ids: [String]) -> Single<RetrievedProductsPrices> {
        Single<RetrievedProductsPrices>.create { event in
            SwiftyStoreKit.retrieveProductsInfo(Set(ids)) { products in
                let retrieved: [ProductPrice] = products
                    .retrievedProducts
                    .compactMap { ProductPrice(product: $0) }
                
                let invalidated = products
                    .invalidProductIDs
                
                let result = RetrievedProductsPrices(retrievedPrices: retrieved, invalidatedIds: Array(invalidated))
                
                event(.success(result))
            }
            
            return Disposables.create()
        }
    }
}

// MARK: Receipt

extension PurchaseService {
    static var receipt: Single<String?> {
        Single<String?>.create { single in
            let receipt = SwiftyStoreKit.localReceiptData?.base64EncodedString()
            
            single(.success(receipt))
            
            return Disposables.create()
        }
    }
}
