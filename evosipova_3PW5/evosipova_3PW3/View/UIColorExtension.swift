//
//  UIColorExtension.swift
//  evosipova_3PW3
//
//  Created by Elizabeth on 29.10.2022.
//

import UIKit

extension UIColor : Comparable {
    var rgba: (red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat) {
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        return (red, green, blue, alpha)
    }
    
    public static func <(lhs: UIColor, rhs: UIColor) -> Bool {
        lhs.rgba.red < rhs.rgba.red && lhs.rgba.green < rhs.rgba.green && lhs.rgba.blue < rhs.rgba.blue
    }
}
