//
//  Extensions.swift
//  Networking
//
//  Created by Alexey Efimov on 01/10/2018.
//  Copyright © 2018 Alexey Efimov. All rights reserved.
//

import UIKit

let primaryColor = UIColor(red: 210/255, green: 109/255, blue: 128/255, alpha: 1)
let secondaryColor = UIColor(red: 107/255, green: 148/255, blue: 230/255, alpha: 1)

extension UIView {
    
    func addVerticalGradientLayer(topColor:UIColor, bottomColor:UIColor) {
        let gradient = CAGradientLayer()
        gradient.frame = self.bounds
        gradient.colors = [topColor.cgColor, bottomColor.cgColor]
        gradient.locations = [0.0, 1.0]
        gradient.startPoint = CGPoint(x: 0, y: 0)
        gradient.endPoint = CGPoint(x: 0, y: 1)
        self.layer.insertSublayer(gradient, at: 0)
    }
}

//extension UIColor {
//    convenience init? (hexValue: String, alpha: CGFloat) {
//        if hexValue.hasPrefix("#") {
//
//            let scanner = Scanner(string: hexValue)
//            if #available(iOS 12.0, *) {
//                scanner.scanLocation = 1
//            }
//
//            var hexInt32: UInt32 = 0
//            if hexValue.count == 7 {
//                if scanner.scanHexInt32(&hexInt32) {
//                    let red = CGFloat((hexInt32 & 0xFF0000) >> 16) / 255
//                    let green = CGFloat((hexInt32 & 0x00FF00) >> 8) / 255
//                    let blue = CGFloat(hexInt32 & 0x0000FF) / 255
//                    self.init(red: red, green: green, blue: blue, alpha: alpha)
//                    return
//                }
//            }
//        }
//        return nil
//    }
//}
