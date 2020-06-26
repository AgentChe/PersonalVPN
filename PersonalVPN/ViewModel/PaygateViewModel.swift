//
// Created by Anton Serov on 12.11.2019.
// Copyright (c) 2019 org. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

class PaygateViewModel {
    // MARK :- Inputs
    let subscribe: AnyObserver<Void>
    let restore: AnyObserver<Void>

    // MARK :- Outputs
    var handleSubscribe: Observable<Void>
    var handleRestore: Observable<Void>
    let alertMessage: Observable<String>
    let dismiss: Observable<Void>
    let activity = BehaviorRelay<Bool>(value: false)
    let paymentDetails: BehaviorRelay<(heading: String, caption: String, button: String)?> = BehaviorRelay(value: nil)

    let _alertMessage = PublishSubject<String>()
    let _dismiss = PublishSubject<Void>()

    // MARK :-
    var storage: Storage
    let payment: PurchaseService
    var client: PaymentsClient

    var subscribeId: String? {
        didSet {
            payment.validProductId = subscribeId
        }
    }

    init(storage: Storage, payment: PurchaseService, client: PaymentsClient) {
        self.storage = storage
        self.payment = payment
        self.client = client

        alertMessage = _alertMessage.asObservable()
        dismiss = _dismiss.asObservable()

        let _subscribe = PublishSubject<Void>()
        subscribe = _subscribe.asObserver()
        handleSubscribe = _subscribe.asObservable()

        let _restore = PublishSubject<Void>()
        restore = _restore.asObserver()
        handleRestore = _restore.asObservable()

        handleSubscribe = handleSubscribe.do(onNext: { [weak self] in
            self?.activity.accept(true)
            self?.payment.subscribe(subscribeId: self?.subscribeId)
        })

        handleRestore = handleRestore.do(onNext: {[weak self] in
            self?.activity.accept(true)
            self?.payment.restorePurchases()
        })

        NotificationCenter.default.addObserver(
            forName: .PurchaseCompleteValidationNotification,
            object: nil,
            queue: OperationQueue.main
        ) { [weak self] notification in
            self?.activity.accept(false)
            if let error = notification.userInfo?["error"] as? Error {
                if case PurchaseError.alreadyPayed = error {} else {
                    self?._alertMessage.onNext(error.localizedDescription)
                }
            }
            else {
                self?.processPurchase()
            }
        }

        client.paygate { [weak self] response, error in
            if let error = error {
                print("Fail to load payment info with error \(error)")
                self?._alertMessage.onNext("Could not load payment info. Check your connection and try again.")
                return
            }
            self?.payment.requestProducts(productIds: Set(arrayLiteral: response!.productId)) { success, products in
                guard success else {
                    print("Fail to load payment info for product \(response!.productId)")
                    self?._alertMessage.onNext("Could not load payment info. Check your connection and try again.")
                    return
                }
                if let product = products?.first {
                    self?.subscribeId = product.productIdentifier
                    let caption = response!.caption.replacingOccurrences(of: "@price", with: product.localizedPrice)
                    self?.paymentDetails.accept((heading: response?.heading ?? "", caption: caption, button: response!.button))
                }
            }
        }
    }

    private func processPurchase() {
        let acs = storage.activeSubscription ?? false
        if acs {
            _dismiss.onNext(())
        }
        else {
            _alertMessage.onNext("There is no active subscription.\nPlease purchase to get access to VPN.")
        }
    }

}
