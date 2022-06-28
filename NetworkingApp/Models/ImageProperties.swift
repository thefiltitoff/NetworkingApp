//
//  ImageProperties.swift
//  NetworkingApp
//
//  Created by Felix Titov on 6/28/22.
//  Copyright © 2022 by Felix Titov. All rights reserved.
//  


import UIKit

struct ImageProperties {
    let key: String
    let data: Data
    
    
    init?(withImage image: UIImage, forKey key: String) {
        self.key = key
        guard let data = image.pngData() else { return nil }
        self.data = data
    }
    
}
