//
//  File.swift
//  framework
//
//  Created by Алексей Румынин on 26.05.25.
//

import UIKit
import CoreText

public struct FontManager {
    public static func registerFonts() {
        let fontNames = [
            "Gilroy-Light",
            "Gilroy-ExtraBold"
        ]
        
        fontNames.forEach { fontName in
            guard let fontURL = Bundle.module.url(forResource: fontName, withExtension: "otf",subdirectory: "Gilroy"),
                  let fontDataProvider = CGDataProvider(url: fontURL as CFURL),
                  let font = CGFont(fontDataProvider) else {
                print("Failed to load font: \(fontName)")
                return
            }
            
            var error: Unmanaged<CFError>?
            if !CTFontManagerRegisterGraphicsFont(font, &error) {
                print("Error registering font: \(error?.takeRetainedValue().localizedDescription ?? "Unknown error")")
            }
        }
    }
}

extension UIFont {
    public static func gilroyLight(ofSize size: CGFloat) -> UIFont {
        UIFont(name: "Gilroy-Light", size: size) ?? systemFont(ofSize: size)
    }

    public static func gilroyExtraBold(ofSize size: CGFloat) -> UIFont {
        UIFont(name: "Gilroy-ExtraBold", size: size) ?? boldSystemFont(ofSize: size)
    }
}
