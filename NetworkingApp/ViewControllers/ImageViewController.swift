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
    private let imageURL = "https://i.imgur.com/3416rvI.jpg"
    
    @IBOutlet var progressView: UIProgressView!
    @IBOutlet var completedLabel: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var imageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        activityIndicator.startAnimating()
        activityIndicator.hidesWhenStopped = true
        completedLabel.isHidden = true
        progressView.isHidden = true
        fetchImage()
    }

    func fetchImage() {
        NetworkManager.downloadImage(url: url) { image in
            self.activityIndicator.stopAnimating()
            self.imageView.image = image
        }

    }
    
    func fetchDataWithAlamofire() {
        AlamofireNetworkManager.downloadImage(url: url) { image in
            self.activityIndicator.stopAnimating()
            self.imageView.image = image
        }
    }
    
    func downloadImageWithProgress() {
        AlamofireNetworkManager.onProgress = { progress in
            self.progressView.isHidden = false
            self.progressView.progress = Float(progress)
            
        }
        
        AlamofireNetworkManager.completed = { completed in
            self.completedLabel.isHidden = false
            self.completedLabel.text = completed
            
        }
        AlamofireNetworkManager.downloadImageWithProgress(url: imageURL) { image in
            self.activityIndicator.stopAnimating()
            self.completedLabel.isHidden = true
            self.progressView.isHidden = true
            self.imageView.image = image
        }
    }
    
    deinit {
        print("I worked")
        imageView.image = nil
    }

}
