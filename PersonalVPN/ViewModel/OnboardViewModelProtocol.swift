//
// Created by Anton Serov on 24.12.2019.
// Copyright (c) 2019 org. All rights reserved.
//

import Foundation

typealias TextViewLink = (title: String, url: NSURL)

protocol OnboardViewModelProtocol {
    var termsURL: TextViewLink { get }
    var privacyURL: TextViewLink { get}
    var imageName: String { get }
    var welcomeText: String { get }
    var privacyAndTermsFormat: String { get }
    var acceptText: String { get }
}
