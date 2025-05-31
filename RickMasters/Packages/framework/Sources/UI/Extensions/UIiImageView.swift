//
//  UIiImageView.swift
//  framework
//
//  Created by Алексей Румынин on 31.05.25.
//

import UIKit

extension UIImageView {
    func downloaded(from url: URL, contentMode mode: ContentMode = .scaleAspectFit) {
        contentMode = mode
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("🔴 Failed to download image: \(error.localizedDescription)")
                return
            }

            guard let httpURLResponse = response as? HTTPURLResponse else {
                print("🔴 Invalid response type")
                return
            }

            guard httpURLResponse.statusCode == 200 else {
                print("🔴 HTTP status code: \(httpURLResponse.statusCode)")
                return
            }

            guard let mimeType = response?.mimeType, mimeType.hasPrefix("image") else {
                print("🔴 Incorrect MIME type: \(String(describing: response?.mimeType))")
                return
            }

            guard let data = data else {
                print("🔴 No data received")
                return
            }

            guard let image = UIImage(data: data) else {
                print("🔴 Failed to create image from data")
                return
            }

            DispatchQueue.main.async { [weak self] in
                self?.image = image
            }
        }.resume()
    }

    func downloaded(from link: String, contentMode mode: ContentMode = .scaleToFill) {
//        print("🔵 Trying to create URL from link: \(link)")
        guard let url = URL(string: link) else {
            print("🔴 Invalid URL string: \(link)")
            return
        }
        downloaded(from: url, contentMode: mode)
    }
}
