//
// Created by Anton Serov on 26.10.2019.
// Copyright (c) 2019 org. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

struct ItemViewModel {
    enum Kind {
        case restorePurchases
        case privacyPolicy
        case termsOfService
        case contactUs
    }

    let kind: Kind
    let title: String
    let imageName: String?
}

class MoreViewModel {
    // MARK: - Inputs
    let selectItem: AnyObserver<ItemViewModel>

    // MARK: - Outputs
    let items: Observable<[ItemViewModel]> =
        Observable.of([
                          ItemViewModel(kind: .restorePurchases, title: "Restore Purchases", imageName: "bag"),
                          ItemViewModel(kind: .privacyPolicy, title: "Privacy Policy", imageName: nil),
                          ItemViewModel(kind: .termsOfService, title: "Terms of Service", imageName: nil),
                          ItemViewModel(kind: .contactUs, title: "Contact Us", imageName: nil)
                      ])
    var handleItem: Observable<ItemViewModel>
    let alertMessage: Observable<String>
    let activity = BehaviorRelay<Bool>(value: false)

    let _alertMessage = PublishSubject<String>()

    // MARK :-
    var storage: Storage
    let payment: PurchaseService
    var client: PaymentsClient

    init(storage: Storage, payment: PurchaseService, client: PaymentsClient) {
        self.storage = storage
        self.payment = payment
        self.client = client

        alertMessage = _alertMessage.asObservable()

        let _selectItem = PublishSubject<ItemViewModel>()
        self.selectItem = _selectItem.asObserver()
        self.handleItem = _selectItem.asObservable()

        handleItem = handleItem.do(onNext: {[weak self] item in
            if item.kind == .restorePurchases {
                self?.activity.accept(true)
                self?.payment.restorePurchases()
            }
        })
    }

    private func validate() {
        client.validate(receipt: AppProducts.receipt) { [weak self] response, error in
            if let error = error {
                print("Fail to validate receipt with error \(error)")
                self?._alertMessage.onNext("Could not validate your payment. Try to restore it again.")
                return
            }
            else if let response = response {
                NetworkConfiguration.userToken = response.userToken
                self?.storage.activeSubscription = response.activeSubscription
                self?.storage.needPayment = response.needPayment
                self?.storage.userId = response.userId
            }
            else {
                print("Empty response!")
            }
            let acs = self?.storage.activeSubscription ?? false
            if !acs {
                self?._alertMessage.onNext("There is no active subscription.\nPlease purchase to get access to VPN.")
            }
        }
    }
}
