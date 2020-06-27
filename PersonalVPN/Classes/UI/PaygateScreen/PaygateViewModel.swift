//
//  PaygateViewModel.swift
//  PersonalVPN
//
//  Created by Andrey Chernyshev on 27.06.2020.
//  Copyright © 2020 org. All rights reserved.
//

import RxSwift
import RxCocoa

final class PaygateViewModel {
//     Input
    let buySubscription = PublishRelay<String>()
    let restoreSubscription = PublishRelay<String>()

//     Output
    private(set) lazy var purchaseCompleted = buy()
    private(set) lazy var restoredCompleted = restore()
    
    let purchaseProcessing = RxActivityIndicator()
    let restoreProcessing = RxActivityIndicator()
    let retrieveCompleted = BehaviorRelay<Bool>(value: false)
    
    private(set) lazy var error = _error.asDriver(onErrorJustReturn: "")
    private let _error = PublishRelay<String>()
}

// MARK: Get paygate content

extension PaygateViewModel {
    func retrieve() -> Driver<(Paygate?, Bool)> {
        let paygate = PaygateService
            .retrievePaygate()
            .asDriver(onErrorJustReturn: nil)
        
        let prices = paygate
            .flatMapLatest { response -> Driver<PaygateMapper.PaygateResponse?> in
                guard let response = response else {
                    return .deferred { .just(nil) }
                }
                
                return PaygateService
                    .prepareProductsPrices(for: response)
                    .asDriver(onErrorJustReturn: nil)
            }
        
        return Driver
            .merge([paygate.map { ($0?.paygate, false) },
                    prices.map { ($0?.paygate, true) }])
                .do(onNext: { [weak self] stub in
                    self?.retrieveCompleted.accept(stub.1)
                })
    }
}

// MARK: Make purchase

private extension PaygateViewModel {
    func buy() -> Signal<Void> {
        let purchase = buySubscription
            .flatMapLatest { [purchaseProcessing] productId -> Observable<Void> in
                PurchaseService
                    .buySubscription(productId: productId)
                    .flatMap { PurchaseService.paymentValidate() }
                    .map { _ in Void() }
                    .trackActivity(purchaseProcessing)
                    .do(onError: { [weak self] _ in
                        self?._error.accept("Paygate.FailedPurchase".localized)
                    })
                    .catchError { _ in .never() }
                }
        
        return purchase
            .asSignal(onErrorSignalWith: .never())
    }
    
    func restore() -> Signal<Void> {
        let purchase = restoreSubscription
            .flatMapLatest { [restoreProcessing] productId -> Observable<Void> in
                PurchaseService
                    .restoreSubscription(productId: productId)
                    .flatMap { PurchaseService.paymentValidate() }
                    .map { _ in Void() }
                    .trackActivity(restoreProcessing)
                    .do(onError: { [weak self] _ in
                        self?._error.accept("Paygate.FailedRestore".localized)
                    })
                    .catchError { _ in .never() }
            }
        
        return purchase
            .asSignal(onErrorSignalWith: .never())
    }
}
