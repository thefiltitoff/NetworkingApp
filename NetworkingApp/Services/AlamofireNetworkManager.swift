//
//  AlamofireNetworkManager.swift
//  NetworkingApp
//
//  Created by Felix Titov on 6/29/22.
//  Copyright © 2022 by Felix Titov. All rights reserved.
//  


import Foundation
import Alamofire

class AlamofireNetworkManager {
    static func sendRequest(url: String) {
        guard let url = URL(string: url) else { return }
        
        request(url, method: .get).validate().responseJSON { response in
            switch response.result {
            case .success(let value):
                
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
}
