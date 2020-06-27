//
// Created by Anton Serov on 25.12.2019.
// Copyright (c) 2019 org. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

class OnboardViewModel: OnboardViewModelProtocol {
    let termsURL: TextViewLink = ("Terms of Service", NSURL(string: LegalLinks.termsOfUse.rawValue)!)
    let privacyURL: TextViewLink = ("Privacy policy", NSURL(string: LegalLinks.privacyPolicy.rawValue)!)
    let imageName: String = ""
    let welcomeText: String = "Welcome to  the Personal VPN"
    let privacyAndTermsFormat: String = "Check out our Privacy policy.  Tap \"Accept and continue\"  to accept the Terms of Service. "
    let acceptText: String = "Accept and Continue"

    // MARK: - Inputs
    let accept: AnyObserver<Void>
    // MARK: - Outputs
    let didAccept: Observable<Void>

    init() {
        let _accept = PublishSubject<Void>()
        self.accept = _accept.asObserver()
        self.didAccept = _accept.asObservable()
    }
}
