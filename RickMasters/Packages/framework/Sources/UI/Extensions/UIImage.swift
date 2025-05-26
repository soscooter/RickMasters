//
//  File.swift
//  framework
//
//  Created by Алексей Румынин on 26.05.25.
//

import UIKit

extension UIImage{
    static var upImage: UIImage {
        if let image = UIImage(named: "up",in: .module,compatibleWith: nil) {
            return image
        } else {
            print("не работает")
            return UIImage()
        }
    }
    
    static var downImage: UIImage {
        if let image = UIImage(named: "down",in: .module,compatibleWith: nil) {
            return image
        } else {
            print("не работает")
            return UIImage()
        }
    }
    
    static var upArrow: UIImage {
        if let image = UIImage(named: "arrowUp",in: .module,compatibleWith: nil) {
            return image
        } else {
            print("не работает")
            return UIImage()
        }
    }
    
    static var downArrow: UIImage {
        if let image = UIImage(named: "arrowDown",in: .module,compatibleWith: nil) {
            return image
        } else {
            print("не работает")
            return UIImage()
        }
    }
}
