//
//  UserProfileViewController.swift
//  NetworkingApp
//
//  Created by Felix Titov on 6/30/22.
//  Copyright © 2022 by Felix Titov. All rights reserved.
//  


import UIKit
import FBSDKLoginKit
import FirebaseAuth
import FirebaseDatabase

class UserProfileViewController: UIViewController {
    lazy var facebookLoginButton: UIButton = {
        let loginButton = FBLoginButton()
        loginButton.frame = CGRect(x: 32,
                                   y: view.frame.height - 200,
                                   width: view.frame.width - 64,
                                   height: 50
        )
        loginButton.delegate = self
        return loginButton
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
        view.addSubview(facebookLoginButton)
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
                    let currentUser = CurrentUser(uid: uid, data: userData)
                    self.activityIndicator.stopAnimating()
                    self.userNameLabel.isHidden = false
                    self.userNameLabel.text = "\(currentUser?.name ?? "Noname") Logged in with Facebook"
                    
                } withCancel: { error in
                    print(error.localizedDescription)
                }

        }
    }
}

extension UserProfileViewController: LoginButtonDelegate {
    func loginButton(_ loginButton: FBLoginButton, didCompleteWith result: LoginManagerLoginResult?, error: Error?) {
        if error != nil {
            print(error?.localizedDescription ?? "Error")
            return
        }
        print("Successfully logged int with facebook!")
    }
    
    func loginButtonDidLogOut(_ loginButton: FBLoginButton) {
        openLoginVC()
        print("User logged out")
    }
}
