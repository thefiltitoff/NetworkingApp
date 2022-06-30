//
//  UserProfileViewController.swift
//  NetworkingApp
//
//  Created by Felix Titov on 6/30/22.
//  Copyright © 2022 by Felix Titov. All rights reserved.
//  


import UIKit
import FBSDKLoginKit
import GoogleSignIn
import FirebaseAuth
import FirebaseDatabase

class UserProfileViewController: UIViewController {
    
    private var provider: String?
    private var currentUser: CurrentUser?
    
    lazy var logoutButton: UIButton = {
        let button = UIButton()
        button.frame = CGRect(x: 32,
                                   y: view.frame.height - 200,
                                   width: view.frame.width - 64,
                                   height: 50
        )
        button.backgroundColor = UIColor(hexValue: "#3B5999", alpha: 1)
        button.setTitle("Log Out", for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        button.setTitleColor(.white, for: .normal)
        button.layer.contents = 5
        button.addTarget(self, action: #selector(signOut), for: .touchUpInside)
        return button
    }()
    
    @IBOutlet var userNameLabel: UILabel!
    @IBOutlet var activityIndicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.addVerticalGradientLayer(topColor: primaryColor, bottomColor: secondaryColor)
        userNameLabel.isHidden = true
        setupViews()

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchingUserData()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        get {
            return .lightContent
        }
    }
    
    private func setupViews() {
        view.addSubview(logoutButton)
    }
    
    private func openLoginVC() {
        do {
            try Auth.auth().signOut()
            
            DispatchQueue.main.async {
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let loginViewController = storyboard.instantiateViewController(withIdentifier: "LoginViewController") as! LoginViewController
                loginViewController.modalPresentationStyle = .fullScreen
                
                self.present(loginViewController, animated: true)
                return
            }
        } catch let error {
            print(error.localizedDescription)
        }
    }
    
    private func fetchingUserData() {
        if Auth.auth().currentUser != nil {
            guard let uid = Auth.auth().currentUser?.uid else { return }
            Database.database().reference()
                .child("users")
                .child(uid)
                .observeSingleEvent(of: .value) { snapshot in
                    guard let userData = snapshot.value as? [String: Any] else { return }
                    self.currentUser = CurrentUser(uid: uid, data: userData)
                    self.activityIndicator.stopAnimating()
                    self.userNameLabel.isHidden = false
                    self.userNameLabel.text = self.getProviderData()
                    
                } withCancel: { error in
                    print(error.localizedDescription)
                }

        }
    }
    
    private func getProviderData() -> String {
        var greetings = ""
        
        if let providerData = Auth.auth().currentUser?.providerData {
            for userInfo in providerData {
                switch userInfo.providerID {
                case "facebook.com":
                    provider = "Facebook"
                case "google.com":
                    provider = "Google"
                default:
                    break
                }
            }
            
            greetings = "\(self.currentUser?.name ?? "Noname") Logged in with \(provider!)"
        }
        return greetings
    }
    
    @objc private func signOut() {
        if let providerData = Auth.auth().currentUser?.providerData {
            for userInfo in providerData {
                switch userInfo.providerID {
                case "facebook.com":
                    LoginManager().logOut()
                    print("Logout from facebook")
                    openLoginVC()
                case "google.com":
                    GIDSignIn.sharedInstance.signOut()
                    print("Logout from google")
                    openLoginVC()
                default:
                    print(userInfo.providerID)
                    break
                }
            }
        }
    }
}
