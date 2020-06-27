//
//  Fonts.swift
//  Horo
//
//  Created by Andrey Chernyshev on 05/12/2019.
//  Copyright © 2019 Andrey Chernyshev. All rights reserved.
//

import UIKit

final class Font {
    final class Poppins {
        static func regular(size: CGFloat) -> UIFont {
            UIFont(name: "Poppins-Regular", size: size)!
        }
        
        static func bold(size: CGFloat) -> UIFont {
            UIFont(name: "Poppins-Bold", size: size)!
        }
        
        static func medium(size: CGFloat) -> UIFont {
            UIFont(name: "Poppins-Medium", size: size)!
        }
        
        static func semibold(size: CGFloat) -> UIFont {
            UIFont(name: "Poppins-SemiBold", size: size)!
        }
    }
    
    final class OpenSans {
        static func regular(size: CGFloat) -> UIFont {
            UIFont(name: "OpenSans-Regular", size: size)!
        }
        
        static func bold(size: CGFloat) -> UIFont {
            UIFont(name: "OpenSans-Bold", size: size)!
        }
        
        static func semibold(size: CGFloat) -> UIFont {
            UIFont(name: "OpenSans-SemiBold", size: size)!
        }
        
        static func light(size: CGFloat) -> UIFont {
            UIFont(name: "OpenSans-Light", size: size)!
        }
    }
    
    final class Barlow {
        static func regular(size: CGFloat) -> UIFont {
            UIFont(name: "Barlow-Regular", size: size)!
        }
        
        static func bold(size: CGFloat) -> UIFont {
            UIFont(name: "Barlow-Bold", size: size)!
        }
        
        static func extraBold(size: CGFloat) -> UIFont {
            UIFont(name: "Barlow-ExtraBold", size: size)!
        }
        
        static func semibold(size: CGFloat) -> UIFont {
            UIFont(name: "Barlow-SemiBold", size: size)!
        }
        
        static func light(size: CGFloat) -> UIFont {
            UIFont(name: "Barlow-Light", size: size)!
        }
        
        static func medium(size: CGFloat) -> UIFont {
            UIFont(name: "Barlow-Medium", size: size)!
        }
        
        static func thin(size: CGFloat) -> UIFont {
            UIFont(name: "Barlow-Thin", size: size)!
        }
    }
}
