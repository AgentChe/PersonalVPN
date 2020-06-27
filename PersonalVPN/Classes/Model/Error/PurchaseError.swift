//
//  PurchaseError.swift
//  SleepWell
//
//  Created by Andrey Chernyshev on 25/10/2019.
//  Copyright © 2019 Andrey Chernyshev. All rights reserved.
//

enum PurchaseError: Error {
    case nonProductsForRestore, failedRestorePurchases, failedPurchaseProduct, alreadyPayed
}
