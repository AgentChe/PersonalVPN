//
//  UIDeviceUtils.swift
//  SleepWell
//
//  Created by Andrey Chernyshev on 20/01/2020.
//  Copyright © 2020 Andrey Chernyshev. All rights reserved.
//

import Foundation.NSLocale
import UIKit

extension UIDevice {
    static var deviceLanguageCode: String? {
        guard let mainPreferredLanguage = Locale.preferredLanguages.first else {
            return nil
        }
        
        return Locale(identifier: mainPreferredLanguage).languageCode
    }
    
    static var appVersion: String? {
        Bundle.main.infoDictionary?["CFBundleVersion"] as? String
    }
}

enum ScreenSize {
    static let bounds: CGRect = (UIScreen.main.bounds)
    static let width: CGFloat = (bounds.width)
    static let height: CGFloat = (bounds.height)
    static let maxLength: CGFloat = (max(width, height))
    static let minLength: CGFloat = (min(width, height))
    
    static let isIpad = (UI_USER_INTERFACE_IDIOM() == .pad)
    static let isIphone = (UI_USER_INTERFACE_IDIOM() == .phone)
    static let isRetina = (UIScreen.main.scale >= 2.0)
    static let isIphone4 = (isIphone && maxLength < 568.0)
    static let isIphone5 = (isIphone && maxLength == 568.0)
    static let isIphone6 = (isIphone && maxLength == 667.0)
    static let isIphone6Plus = (isIphone && maxLength == 736.0)
    static let isIphoneX = (isIphone && maxLength == 812.0)
    static let isIphoneXMax = (isIphone && maxLength == 896.0)
    static let isIphoneXFamily = (isIphone && maxLength / minLength > 2.0)
    
    static let topOffset: CGFloat = isIphoneXFamily ? 24.0 : 0.0
    static let bottomOffset: CGFloat = isIphoneXFamily ? 34.0 : 0.0
    
    static let statusBarSize = UIApplication.shared.statusBarFrame.size
    static let statusBarHeight = statusBarSize.height
    
    static let tabBarHeight: CGFloat = 49
    static let customTabBarHeight: CGFloat = 74.scale
}
