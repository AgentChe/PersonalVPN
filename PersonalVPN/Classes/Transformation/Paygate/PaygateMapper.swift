//
//  PaygateMapper.swift
//  SleepWell
//
//  Created by Andrey Chernyshev on 12/06/2020.
//  Copyright © 2020 Andrey Chernyshev. All rights reserved.
//

import Foundation.NSAttributedString
import UIKit.UIColor

final class PaygateMapper {
    typealias PaygateResponse = (json: [String: Any], paygate: Paygate, productsIds: [String])
    
    static func parse(response: Any, productsPrices: [ProductPrice]?) -> PaygateResponse? {
        guard
            let json = response as? [String: Any],
            let data = json["_data"] as? [String: Any]
        else {
            return nil
        }
        
        let mainJSON = data["main"] as? [String: Any]
        guard let main = map(main: mainJSON, productsPrices: productsPrices) else {
            return nil 
        }
        
        let specialOfferJSON = data["special_offer"] as? [String: Any]
        let specialOffer = map(specialOffer: specialOfferJSON, productsPrices: productsPrices)
        
        let paygate = Paygate(main: main, specialOffer: specialOffer)
        
        let productIds = getProductIds(mainJSON: mainJSON, specialOfferJSON: specialOfferJSON)
        
        return PaygateResponse(json, paygate, productIds)
    }
}

// MARK: Private

private extension PaygateMapper {
    static func map(main: [String: Any]?, productsPrices: [ProductPrice]?) -> PaygateMain? {
        guard let main = main else {
            return nil
        }
        
        let heading1 = ((main["heading_1"] as? String) ?? "")
            .attributed(with: TextAttributes()
                .font(Font.Poppins.bold(size: 26.scale))
                .textColor(UIColor(red: 18 / 255, green: 18 / 255, blue: 23 / 255, alpha: 1))
                .lineHeight(28.scale)
                .letterSpacing(-0.04.scale))
        
        let heading2 = ((main["heading_2"] as? String) ?? "")
            .attributed(with: TextAttributes()
                .font(Font.Poppins.regular(size: 26.scale))
                .textColor(UIColor(red: 18 / 255, green: 18 / 255, blue: 23 / 255, alpha: 1))
                .lineHeight(28.scale)
                .letterSpacing(-0.04.scale))
        
        let greeting = NSMutableAttributedString()
        greeting.append(heading1)
        greeting.append(NSAttributedString(string: " "))
        greeting.append(heading2)
        
        let text = (main["text"] as? String ?? "")
            .attributed(with: TextAttributes()
                .font(Font.Poppins.regular(size: 17.scale))
                .textColor(UIColor(red: 18 / 255, green: 18 / 255, blue: 23 / 255, alpha: 1))
                .lineHeight(19.scale)
                .letterSpacing(-0.5.scale))
        
        let button = (main["button"] as? String ?? "")
            .uppercased()
            .attributed(with: TextAttributes()
                .font(Font.Poppins.semibold(size: 17.scale))
                .textColor(UIColor(red: 18 / 255, green: 18 / 255, blue: 23 / 255, alpha: 1))
                .letterSpacing(0.02.scale)
                .lineHeight(22.scale))
        
        let subButton = (main["subbutton"] as? String ?? "")
            .attributed(with: TextAttributes()
                .font(Font.OpenSans.semibold(size: 13.scale))
                .textColor(UIColor(red: 18 / 255, green: 18 / 255, blue: 23 / 255, alpha: 1))
                .letterSpacing(-0.006.scale)
                .lineHeight(18.scale))
        
        let restore = (main["restore"] as? String ?? "")
            .attributed(with: TextAttributes()
                .font(Font.Poppins.regular(size: 18.scale))
                .lineHeight(27.scale)
                .textColor(UIColor(red: 18 / 255, green: 18 / 255, blue: 23 / 255, alpha: 0.5)))
        
        return PaygateMain(greeting: greeting,
                           text: text,
                           options: (main["options"] as? [[String: Any]])?.compactMap { map(option: $0, productsPrices: productsPrices) },
                           button: button,
                           subButton: subButton,
                           restore: restore)
    }
    
    static func map(option: [String: Any], productsPrices: [ProductPrice]?) -> PaygateOption? {
        guard
            let productId = option["product_id"] as? String
        else {
            return nil
        }
        
        let title = (option["title"] as? String)?
            .attributed(with: TextAttributes()
                .font(Font.Poppins.bold(size: 20.scale))
                .lineHeight(25.scale)
                .letterSpacing(-0.08)
                .textColor(UIColor.white))
        
        let subCaption = (option["subcaption"] as? String)?
            .attributed(with: TextAttributes()
                .font(Font.Poppins.regular(size: 10.scale))
                .letterSpacing(-0.08)
                .lineHeight(13.scale)
                .textColor(.white))
        
        let save = (option["save"] as? String)?
            .attributed(with: TextAttributes()
                .font(Font.Poppins.semibold(size: 13.scale))
                .letterSpacing(-0.08)
                .textColor(UIColor(red: 18 / 255, green: 18 / 255, blue: 23 / 255, alpha: 1))
                .lineHeight(18.scale))
        
        guard let productPrice = productsPrices?.first(where: { $0.id == productId }) else {
            return PaygateOption(productId: productId,
                                 title: title,
                                 caption: nil,
                                 subCaption: subCaption,
                                 save: save,
                                 bottomLine: nil)
        }
        
        let div = option["div"] as? Int ?? 1
        
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = productPrice.priceLocale
        
        let priceDiv: Double = productPrice.priceValue / Double(div)
        let priceDivLocalized: String
        if priceDiv < 100 {
            formatter.maximumFractionDigits = 1
            priceDivLocalized = formatter.string(from: NSNumber(value: (priceDiv * 10).rounded() / 10)) ?? ""
        } else {
            formatter.maximumFractionDigits = 0
            priceDivLocalized = formatter.string(from: NSNumber(value: round(priceDiv))) ?? ""
        }
        
        formatter.maximumFractionDigits = productPrice.priceValue.truncatingRemainder(dividingBy: 1) > 0 ? 2 : 0
        let priceLocalized = formatter.string(from: NSNumber(value: productPrice.priceValue)) ?? ""
        
        let caption = (option["caption"] as? String)?
            .replacingOccurrences(of: "@price_div", with: priceDivLocalized)
            .replacingOccurrences(of: "@price", with: priceLocalized)
        let captionAttrs = NSMutableAttributedString(string: caption ?? "",
                                                     attributes: TextAttributes()
                                                        .font(Font.OpenSans.semibold(size: 15.scale))
                                                        .lineHeight(25.scale)
                                                        .letterSpacing(-0.08)
                                                        .dictionary)
        let captionPriceLocalizedRange = NSString(string: caption ?? "").range(of: priceLocalized)
        captionAttrs.addAttributes(TextAttributes().font(Font.OpenSans.bold(size: 20.scale)).letterSpacing(-0.08).dictionary,
                                   range: captionPriceLocalizedRange)
        let captionPriceDivLocalizedRange = NSString(string: caption ?? "").range(of: priceDivLocalized)
        captionAttrs.addAttributes(TextAttributes().font(Font.OpenSans.bold(size: 20.scale)).letterSpacing(-0.08).dictionary,
                                   range: captionPriceDivLocalizedRange)
        
        let bottomLine = (option["bottom_line"] as? String)?
            .replacingOccurrences(of: "@price_div", with: priceDivLocalized)
            .replacingOccurrences(of: "@price", with: priceLocalized)
        let bottomLineAttrs = NSMutableAttributedString(string: bottomLine ?? "",
                                                        attributes: TextAttributes()
                                                            .font(Font.OpenSans.semibold(size: 15.scale))
                                                            .lineHeight(25.scale)
                                                            .dictionary)
        let bottomLinePriceLocalizedRange = NSString(string: bottomLine ?? "").range(of: priceLocalized)
        bottomLineAttrs.addAttributes(TextAttributes().font(Font.OpenSans.bold(size: 20.scale)).letterSpacing(-0.08).dictionary,
                                   range: bottomLinePriceLocalizedRange)
        let bottomLinePriceDivLocalizedRange = NSString(string: bottomLine ?? "").range(of: priceDivLocalized)
        bottomLineAttrs.addAttributes(TextAttributes().font(Font.OpenSans.bold(size: 20.scale)).letterSpacing(-0.08).dictionary,
                                   range: bottomLinePriceDivLocalizedRange)
        
        return PaygateOption(productId: productId,
                             title: title,
                             caption: captionAttrs,
                             subCaption: subCaption,
                             save: save,
                             bottomLine: bottomLineAttrs)
    }
    
    static func map(specialOffer: [String: Any]?, productsPrices: [ProductPrice]?) -> PaygateSpecialOffer? {
        guard
            let specialOffer = specialOffer,
            let productId = specialOffer["product_id"] as? String,
            let productPrice = productsPrices?.first(where: { $0.id == productId })
        else {
            return nil
        }
        
        let title = (specialOffer["title"] as? String)?
            .replacingOccurrences(of: "@price", with: productPrice.priceLocalized)
        
        let subTitle = (specialOffer["subtitle"] as? String)?
            .replacingOccurrences(of: "@price", with: productPrice.priceLocalized)
        
        let text = (specialOffer["text"] as? String)?
            .replacingOccurrences(of: "@price", with: productPrice.priceLocalized)
        
        let button = (specialOffer["button"] as? String)?
            .uppercased()
            .replacingOccurrences(of: "@price", with: productPrice.priceLocalized)
        
        let subButton = (specialOffer["subbutton"] as? String)?
            .replacingOccurrences(of: "@price", with: productPrice.priceLocalized)
        
        let multiplicator = specialOffer["special_offer_multiplicator"] as? Int ?? 1
        let oldPrice = productPrice.priceValue * Double(multiplicator)
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = productPrice.priceLocale
        formatter.string(from: NSNumber(value: oldPrice))
        let oldPriceLocalized = formatter.string(from: NSNumber(value: oldPrice)) ?? String(format: "%.1f", oldPrice)
        
        let currentPrice = (specialOffer["price_tag"] as? String)?
            .replacingOccurrences(of: "@price", with: productPrice.priceLocalized)
        
        return PaygateSpecialOffer(productId: productId,
                                   title: title,
                                   subTitle: subTitle,
                                   text: text,
                                   time: specialOffer["time_left"] as? String ?? "",
                                   oldPrice: oldPriceLocalized,
                                   price: currentPrice,
                                   button: button,
                                   subButton: subButton,
                                   restore: specialOffer["restore"] as? String)
    }
    
    static func getProductIds(mainJSON: [String: Any]?, specialOfferJSON: [String: Any]?) -> [String] {
        var ids = [String]()
        
        let optionsJSON = mainJSON?["options"] as? [[String: Any]] ?? []
        for optionJSON in optionsJSON {
            if let id = optionJSON["product_id"] as? String {
                ids.append(id)
            }
        }
        
        if let specialOfferProductId = specialOfferJSON?["product_id"] as? String {
            ids.append(specialOfferProductId)
        }
        
        return ids
    }
}
