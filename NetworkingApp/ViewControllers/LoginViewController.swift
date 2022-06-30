//
//  LoginViewController.swift
//  NetworkingApp
//
//  Created by Felix Titov on 6/30/22.
//  Copyright © 2022 by Felix Titov. All rights reserved.
//  


import UIKit
import FBSDKLoginKit
import FirebaseAuth

class LoginViewController: UIViewController {
    lazy var facebookLoginButton: UIButton = {
        let loginButton = FBLoginButton()
        loginButton.frame = CGRect(x: 32, y: 360, width: view.frame.width - 64, height: 50)
        loginButton.delegate = self
        return loginButton
    }()
    
    lazy var customFacebookLoginButton: UIButton = {
        let loginButton = UIButton()
        loginButton.backgroundColor = UIColor(hexValue: "#3B5999", alpha: 1)
        loginButton.setTitle("Login with Facebook", for: .normal)
        loginButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        loginButton.setTitleColor(.white, for: .normal)
        loginButton.frame = CGRect(x: 32, y: 360 + 60, width: view.frame.width - 64, height: 50)
        loginButton.layer.cornerRadius = 5

        loginButton.addTarget(self, action: #selector(facebookLogIn), for: .touchUpInside)
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
    
    private func setupViews()  {
        view.addSubview(facebookLoginButton)
        view.addSubview(customFacebookLoginButton)
    }
    
    private func openMainVC() {
        dismiss(animated: true)
    }

}

// MARK: FBSDK
extension LoginViewController: LoginButtonDelegate {
    func loginButton(_ loginButton: FBLoginButton, didCompleteWith result: LoginManagerLoginResult?, error: Error?) {
        if error != nil {
            print(error?.localizedDescription ?? "Error")
            return
        }
        
        guard AccessToken.isCurrentAccessTokenActive else  {
            return
        }
        
        print("Successfully logged int with facebook!")
        openMainVC()
        
    }
    
    func loginButtonDidLogOut(_ loginButton: FBLoginButton) {
        print("User logged out")
    }
    
    @objc private func facebookLogIn() {
        LoginManager().logIn(permissions: ["email", "public_profile"], from: self) { result, error in
            if let error = error {
                print(error.localizedDescription)
                return
            }
            
            guard let result = result else { return }
            
            if result.isCancelled { return}
            else {
                self.signIntoFireBase()
                self.openMainVC()
            }
            
        }
    }
    
    private func signIntoFireBase() {
        let accessToken = AccessToken.current
        guard let accessTokenString = accessToken?.tokenString else { return }
        let credentials = FacebookAuthProvider.credential(withAccessToken: accessTokenString)
        
        Auth.auth().signIn(with: credentials) { user, error in
            if let error = error {
                print(error.localizedDescription)
                return
            }
            
            print("Logged in", user!)
        }
    }
}
