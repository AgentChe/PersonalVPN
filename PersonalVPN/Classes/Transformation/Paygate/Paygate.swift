//
//  Paygate.swift
//  SleepWell
//
//  Created by Andrey Chernyshev on 12/06/2020.
//  Copyright © 2020 Andrey Chernyshev. All rights reserved.
//

import Foundation.NSAttributedString

struct Paygate {
    let main: PaygateMain
    let specialOffer: PaygateSpecialOffer?
}

struct PaygateMain {
    let greeting: NSAttributedString?
    let text: NSAttributedString?
    let options: [PaygateOption]?
    let button: NSAttributedString?
    let subButton: NSAttributedString?
    let restore: NSAttributedString?
}

struct PaygateOption {
    let productId: String
    let title: NSAttributedString?
    let caption: NSAttributedString?
    let subCaption: NSAttributedString?
    let save: NSAttributedString?
    let bottomLine: NSAttributedString?
}

struct PaygateSpecialOffer {
    let productId: String
    let title: String?
    let subTitle: String?
    let text: String?
    let time: String?
    let oldPrice: String?
    let price: String?
    let button: String?
    let subButton: String?
    let restore: String?
}
