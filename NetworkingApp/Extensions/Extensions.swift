//
//  Extensions.swift
//  Networking
//
//  Created by Felix Titov on 6/28/22.
//  Copyright © 2022 Felix Titov. All rights reserved.
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

extension UIColor {
    convenience init? (hexValue: String, alpha: CGFloat) {
        if hexValue.hasPrefix("#") {
            
            let scanner = Scanner(string: hexValue)
            
            scanner.currentIndex = scanner.string.index(after: scanner.currentIndex)
            
            
            var hexInt64: UInt64 = 0
            if hexValue.count == 7 {
                if scanner.scanHexInt64(&hexInt64) {
                    let red = CGFloat((hexInt64 & 0xFF0000) >> 16) / 255
                    let green = CGFloat((hexInt64 & 0x00FF00) >> 8) / 255
                    let blue = CGFloat(hexInt64 & 0x0000FF) / 255
                    self.init(red: red, green: green, blue: blue, alpha: alpha)
                    return
                }
            }
        }
        return nil
    }
}
