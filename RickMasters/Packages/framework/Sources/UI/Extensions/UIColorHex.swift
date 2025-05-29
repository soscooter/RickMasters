//
//  UIColorHex.swift
//  framework
//
//  Created by Алексей Румынин on 26.05.25.
//

import UIKit

extension UIColor {
    public convenience init?(hex: String) {
        let r, g, b, a: CGFloat
        
        // Удаляем символ # если есть
        var cleanedHex = hex.replacingOccurrences(of: "#", with: "")
        
        // Проверяем длину строки и дополняем при необходимости
        if cleanedHex.count == 6 {
            cleanedHex += "FF" // Добавляем альфа-канал по умолчанию
        } else if cleanedHex.count == 3 { // Поддержка сокращенного формата #RGB
            let chars = Array(cleanedHex)
            cleanedHex = "\(chars[0])\(chars[0])\(chars[1])\(chars[1])\(chars[2])\(chars[2])FF"
        }
        
        // Проверяем что получили 8 символов (RRGGBBAA)
        guard cleanedHex.count == 8 else {
            return nil
        }
        
        let scanner = Scanner(string: cleanedHex)
        var hexNumber: UInt64 = 0
        
        guard scanner.scanHexInt64(&hexNumber) else {
            return nil
        }
        
        r = CGFloat((hexNumber & 0xFF000000) >> 24) / 255
        g = CGFloat((hexNumber & 0x00FF0000) >> 16) / 255
        b = CGFloat((hexNumber & 0x0000FF00) >> 8) / 255
        a = CGFloat(hexNumber & 0x000000FF) / 255
        
        self.init(red: r, green: g, blue: b, alpha: a)
    }
}
