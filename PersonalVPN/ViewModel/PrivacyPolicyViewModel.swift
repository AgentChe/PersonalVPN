//
// Created by Anton Serov on 24.10.2019.
// Copyright (c) 2019 org. All rights reserved.
//

import Foundation
import RxSwift

class PrivacyPolicyViewModel {
    // MARK: - Inputs
    let accept: AnyObserver<Void>
    // MARK: - Outputs
    var didAccept: Observable<Void>
    // MARK: -
    let url: URL?

    init(url: URL?) {
        let _accept = PublishSubject<Void>()
        self.accept = _accept.asObserver()
        self.didAccept = _accept.asObservable()
        self.didAccept = self.didAccept.do(onNext: {
            UserDefaults.standard.set(true, forKey: "privacy")
        })
        self.url = url
    }
}
