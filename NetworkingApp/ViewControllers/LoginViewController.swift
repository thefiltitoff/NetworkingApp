//
//  LoginViewController.swift
//  NetworkingApp
//
//  Created by Felix Titov on 6/30/22.
//  Copyright © 2022 by Felix Titov. All rights reserved.
//  


import UIKit
import FBSDKLoginKit

class LoginViewController: UIViewController {
    lazy var facebookLoginButton: UIButton = {
        let loginButton = FBLoginButton()
        loginButton.frame = CGRect(x: 32, y: 320, width: view.frame.width - 64, height: 50)
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
    
    private func setupViews()  {
        view.addSubview(facebookLoginButton)
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
}
