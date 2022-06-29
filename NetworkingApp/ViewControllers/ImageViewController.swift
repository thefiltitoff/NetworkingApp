//
//  ImageViewController.swift
//  NetworkingApp
//
//  Created by Felix Titov on 6/27/22.
//  Copyright © 2022 by Felix Titov. All rights reserved.
//  


import UIKit
import Alamofire

class ImageViewController: UIViewController {
    
    private let url = "https://applelives.com/wp-content/uploads/2016/03/iPhone-SE-11.jpeg"
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var imageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        activityIndicator.isHidden = true
        activityIndicator.hidesWhenStopped = true
        fetchImage()
    }

    func fetchImage() {

        activityIndicator.isHidden = false
        activityIndicator.startAnimating()

        NetworkManager.downloadImage(url: url) { image in
            self.activityIndicator.stopAnimating()
            self.imageView.image = image
        }

    }
    
    func fetchDataWithAlamofire() {
        request(url).responseData { responseData in
            switch responseData.result {
                
            case .success(let data):
                guard let image = UIImage(data: data) else { return }
                self.activityIndicator.stopAnimating()
                self.imageView.image = image
            case .failure(let error):
                print(error)
            }
        }
    }

}
