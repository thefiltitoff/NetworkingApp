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
    static var onProgress: ((Double) -> ())?
    static var completed: ((String) -> ())?
    
    static func sendRequest(url: String, completion: @escaping (_ courses: [Course]) -> ()) {
        guard let url = URL(string: url) else { return }
        
        request(url, method: .get).validate().responseJSON { response in
            switch response.result {
            case .success(let value):
                var courses: [Course] = []
                courses = Course.getItems(from: value)!
                completion(courses)
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
    
    static func responseData(url: String) {
        request(url).responseData { responseData in
            switch responseData.result {
                
            case .success(let data):
                guard let json = String(data: data, encoding: .utf8) else { return }
                print(json)
            case .failure(let error):
                print(error)
            }
        }
    }
    
    static func downloadImage(url: String, completion: @escaping (_ image: UIImage) -> ()) {
        request(url).responseData { responseData in
            switch responseData.result {
                
            case .success(let data):
                guard let image = UIImage(data: data) else { return }
                completion(image)
            case .failure(let error):
                print(error)
            }
        }
    }
    
    static func responseString(url: String) {
        request(url).responseString { responseString in
            switch responseString.result {
                
            case .success(let string):
                print(string)
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
    
    static func response(url: String) {
        request(url).response { response in
            guard
                let data = response.data,
                let string = String(data: data, encoding: .utf8) else { return }
            
            print(string)
        }
    }
    
    static func downloadImageWithProgress(url: String, completion: @escaping (_ image: UIImage) -> ()) {
        guard let url = URL(string: url) else { return }
        
        request(url).validate().downloadProgress { progress in
            self.onProgress?(progress.fractionCompleted)
            self.completed?(progress.localizedDescription)
        }.response { response in
            guard
                let data = response.data,
                let image = UIImage(data: data) else { return }
            
            DispatchQueue.main.async {
                completion(image)
            }
            
        }
    }
}
