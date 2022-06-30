//
//  UserProfileViewController.swift
//  NetworkingApp
//
//  Created by Felix Titov on 6/30/22.
//  Copyright © 2022 by Felix Titov. All rights reserved.
//  


import UIKit
import FBSDKLoginKit

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

    override func viewDidLoad() {
        super.viewDidLoad()

        view.addVerticalGradientLayer(topColor: primaryColor, bottomColor: secondaryColor)
        setupViews()

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
        if !AccessToken.isCurrentAccessTokenActive {
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
