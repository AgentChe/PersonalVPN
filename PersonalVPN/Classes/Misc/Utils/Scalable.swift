//
//  Scalable.swift
//  SleepWell
//
//  Created by Andrey Chernyshev on 12/06/2020.
//  Copyright © 2020 Andrey Chernyshev. All rights reserved.
//

import UIKit

protocol Scalable {
    var scale: Self { get }
}

extension CGFloat: Scalable {
    var scale: CGFloat {
        let designScreenWidth: CGFloat = 375
        let currentScreenWidth = UIScreen.main.bounds.size.width
        return self * currentScreenWidth / designScreenWidth
    }
}

extension Int {
    var scale: CGFloat {
        CGFloat(self).scale
    }
}

extension Double {
    var scale: CGFloat {
        CGFloat(self).scale
    }
}

extension CGPoint: Scalable {
    var scale: CGPoint {
        CGPoint(x: x.scale, y: y.scale)
    }
}

extension CGSize: Scalable {
    var scale: CGSize {
        CGSize(width: width.scale, height: height.scale)
    }
}

extension CGRect: Scalable {
    var scale: CGRect {
        CGRect(origin: origin.scale, size: size.scale)
    }
}

extension UIFont {
    var scale: UIFont {
        UIFont(name: fontName, size: pointSize.scale) ?? UIFont.systemFont(ofSize: pointSize.scale)
    }
}

extension UIEdgeInsets: Scalable {
    var scale: UIEdgeInsets {
        UIEdgeInsets(top: top.scale, left: left.scale, bottom: bottom.scale, right: right.scale)
    }
}
