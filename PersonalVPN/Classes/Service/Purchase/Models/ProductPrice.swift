//
//  ProductPrice.swift
//  SleepWell
//
//  Created by Andrey Chernyshev on 12/06/2020.
//  Copyright © 2020 Andrey Chernyshev. All rights reserved.
//

import StoreKit

struct ProductPrice {
    let id: String
    let priceLocalized: String
    let priceValue: Double
    let priceLocale: Locale
    let currency: String
}

// MARK: Make

extension ProductPrice {
    init(product: SKProduct) {
        id = product.productIdentifier
        priceLocalized = product.localizedPrice ?? ""
        priceValue = product.price.doubleValue
        priceLocale = product.priceLocale
        currency = product.priceLocale.currencyCode ?? ""
    }
}
