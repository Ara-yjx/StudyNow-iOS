//
//  Extensions.swift
//  StudyNow1
//
//  Created by YUAN YAO on 1/30/18.
//  Copyright © 2018 GoStudyNow. All rights reserved.
//

import UIKit

let imageCache = NSCache<NSString, UIImage>()

extension UIImageView {
    // cache image so it doesnt download from firebase everytime
    func loadImageUsingCacheWithUrlString(urlString: String) {
        // clears the images
        image = nil

        // check cache for image first
        if let cachedImage = imageCache.object(forKey: urlString as NSString) {
            image = cachedImage
            return
        }

        // otherwise download the image
        let url = URL(string: urlString)
        URLSession.shared.dataTask(with: url!, completionHandler: { data, _, error in
            if error != nil {
                print(error!)
                return
            }
            // let it run in the main thread
            DispatchQueue.main.async {
                if let downloadedImage = UIImage(data: data!) {
                    imageCache.setObject(downloadedImage, forKey: urlString as NSString)
                    self.image = downloadedImage
                }
            }
        }).resume()
    }
}

extension UIButton {
    // cache image so it doesnt download from firebase everytime
    func loadImageUsingCacheWithUrlString(urlString: String) {
        // clears the images
        setBackgroundImage(nil, for: .normal)
        
        // check cache for image first
        if let cachedImage = imageCache.object(forKey: urlString as NSString) {
            setBackgroundImage(cachedImage, for: .normal)
            return
        }
        
        // otherwise download the image
        let url = URL(string: urlString)
        URLSession.shared.dataTask(with: url!, completionHandler: { data, _, error in
            if error != nil {
                print(error!)
                return
            }
            // let it run in the main thread
            DispatchQueue.main.async {
                if let downloadedImage = UIImage(data: data!) {
                    imageCache.setObject(downloadedImage, forKey: urlString as NSString)
                    self.setBackgroundImage(downloadedImage, for: .normal)
                }
            }
        }).resume()
    }
}
