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
    // MARK: - Outputs
    let items: Observable<[ItemViewModel]> =
        Observable.of([
                          ItemViewModel(kind: .restorePurchases, title: "Restore Purchases", imageName: "bag"),
                          ItemViewModel(kind: .privacyPolicy, title: "Privacy Policy", imageName: nil),
                          ItemViewModel(kind: .termsOfService, title: "Terms of Service", imageName: nil),
                          ItemViewModel(kind: .contactUs, title: "Contact Us", imageName: nil)
                      ])
    
    let handleItem = PublishRelay<ItemViewModel>()
}
