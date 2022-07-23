//
//  MainCollectionViewController.swift
//  NetworkingApp
//
//  Created by Felix Titov on 6/28/22.
//  Copyright © 2022 by Felix Titov. All rights reserved.
//  


import UIKit
import UserNotifications
import FBSDKLoginKit
import FirebaseAuth

enum Actions: String, CaseIterable {
    case downloadImage = "Download Image"
    case get = "GET"
    case post = "POST"
    case ourCourses = "Our Courses"
    case uploadImage = "Upload Image"
    case downloadFile = "Download File"
    case ourCoursesAlamofire = "Our Courses (Alamofire)"
    case responseData
    case responseString
    case response
    case downloadLargeImage
    case postAlamofire
    case putRequest
    case uploadImageAlamofire
}

private let reuseIdentifier = "Cell"
private let url = "https://jsonplaceholder.typicode.com/posts"
private let uploadImage = "https://api.imgur.com/3/image"
private let swiftBookApi = "https://swiftbook.ru//wp-content/uploads/api/api_courses"

class MainCollectionViewController: UICollectionViewController {
    
    private var alert: UIAlertController!
    private let dataProvider = DataProvider()
    private var filePath: String?
    
    let actions = Actions.allCases
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        registerForNotifications()
        dataProvider.fileLocation = { location in
            print(location.absoluteString)
            self.filePath = location.absoluteString
            self.alert.dismiss(animated: false)
            self.postForNotifications()
        }
        
        checkLogIn()
    }
    
    // MARK: UICollectionViewDataSource
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return actions.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as? CollectionViewCell else { return UICollectionViewCell() }
        
        cell.label.text = actions[indexPath.row].rawValue
        
        return cell
    }
    
    // MARK: UICollectionViewDelegate
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let action = actions[indexPath.row]
        
        switch action {
            
        case .downloadImage:
            performSegue(withIdentifier: "ShowImage", sender: self)
        case .get:
            NetworkManager.getRequest(url: url)
        case .post:
            NetworkManager.postRequest(url: url)
        case .ourCourses:
            performSegue(withIdentifier: "OurCourses", sender: self)
        case .uploadImage:
            NetworkManager.uploadImage(url: uploadImage)
        case .downloadFile:
            showAlert()
            dataProvider.startDownload()
        case .ourCoursesAlamofire:
            performSegue(withIdentifier: "OurCoursesWithAlamofire", sender: self)
        case .responseData:
            performSegue(withIdentifier: "ResponseData", sender: self)
            AlamofireNetworkManager.responseData(url: swiftBookApi)
        case .responseString:
            AlamofireNetworkManager.responseString(url: swiftBookApi)
        case .response:
            AlamofireNetworkManager.response(url: swiftBookApi)
        case .downloadLargeImage:
            performSegue(withIdentifier: "LargeImage", sender: self)
        case .postAlamofire:
            performSegue(withIdentifier: "PostRequest", sender: self)
        case .putRequest:
            performSegue(withIdentifier: "PutRequest", sender: self)
        case .uploadImageAlamofire:
            AlamofireNetworkManager.uploadImage(url: uploadImage)
        }
        
    }
    
    private func showAlert() {
        alert = UIAlertController(title: "Downloading...", message: "0%", preferredStyle: .alert)
        let height = NSLayoutConstraint(
            item: alert.view!,
            attribute: .height,
            relatedBy: .equal,
            toItem: nil,
            attribute: .notAnAttribute,
            multiplier: 0,
            constant: 170
        )
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .destructive) { action in
            self.dataProvider.stopDownload()
        }
        
        alert.view.addConstraint(height)
        alert.addAction(cancelAction)
        
        present(alert, animated: true) { [unowned self] in
            let size = CGSize(width: 40, height: 40)
            let point = CGPoint(
                x: self.alert.view.frame.size.width / 2 - size.width / 2,
                y: self.alert.view.frame.size.height / 2 - size.height / 2
            )
            let activityIndicator = UIActivityIndicatorView(frame: CGRect(origin: point, size: size))
            activityIndicator.color = .gray
            activityIndicator.style = .large
            activityIndicator.startAnimating()
            
            let progressView = UIProgressView(
                frame:
                    CGRect(
                        x: 0,
                        y: self.alert.view.frame.height - 44,
                        width: self.alert.view.frame.width,
                        height: 2
                    )
            )
            
            progressView.tintColor = .blue
            
            self.dataProvider.onProgress = { (progress) in
                progressView.progress = Float(progress)
                self.alert.message = String(Int(progress * 100)) + "%"
            }
            
            self.alert.view.addSubview(activityIndicator)
            self.alert.view.addSubview(progressView)
        }
    }
    
    // MARK: Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let coursesVC = segue.destination as? CoursesTableViewController
        let imageVC = segue.destination as? ImageViewController
        
        switch segue.identifier {
        case "OurCourses":
            coursesVC?.fetchData()
        case "OurCoursesWithAlamofire":
            coursesVC?.fetchDataWithAlamofire()
        case "ShowImage":
            imageVC?.fetchImage()
        case "ResponseData":
            imageVC?.fetchDataWithAlamofire()
        case "LargeImage":
            imageVC?.downloadImageWithProgress()
        case "PostRequest":
            coursesVC?.postRequest()
        case "PutRequest":
            coursesVC?.putRequest()
        default:
            break
        }
        
    }
}

extension MainCollectionViewController {
    private func registerForNotifications() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { _, _ in
            
        }
    }
    
    private func postForNotifications() {
        let content = UNMutableNotificationContent()
        content.title = "Download complete!"
        content.body = "Your backgroundtransfer has completed. File path: \(filePath!)"
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 3, repeats: false)
        
        let request = UNNotificationRequest(identifier: "TransferComplete", content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
        
    }
}

// MARK: FBSDK
extension MainCollectionViewController {
    private func checkLogIn() {
        if Auth.auth().currentUser == nil {
            DispatchQueue.main.async {
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let loginViewController = storyboard.instantiateViewController(withIdentifier: "LoginViewController") as! LoginViewController
                loginViewController.modalPresentationStyle = .fullScreen
                
                self.present(loginViewController, animated: true)
                return
            }
        }
    }
}
