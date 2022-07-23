//
//  LoginViewController.swift
//  NetworkingApp
//
//  Created by Felix Titov on 6/30/22.
//  Copyright © 2022 by Felix Titov. All rights reserved.
//  


import UIKit
import FBSDKLoginKit
import Firebase
import FirebaseAuth
import FirebaseDatabase
import GoogleSignIn

class LoginViewController: UIViewController {
    
    var userProfile: UserProfile!
    
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
    
    lazy var googleLoginButton: GIDSignInButton = {
        let loginButton = GIDSignInButton()
        loginButton.frame = CGRect(x: 32, y: 360 + 160, width: view.frame.width - 64, height: 50)
        loginButton.addTarget(self, action: #selector(signInWithGoogle), for: .touchUpInside)
        return loginButton
    }()
    
    lazy var customGoogleLoginButton: UIButton = {
        let loginButton = UIButton()
        loginButton.frame = CGRect(x: 32, y: 360 + 240, width: view.frame.width - 64, height: 50)
        loginButton.backgroundColor = .white
        loginButton.setTitle("Log in with Google", for: .normal)
        loginButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        loginButton.setTitleColor(.gray, for: .normal)
        loginButton.layer.cornerRadius = 5
        loginButton.addTarget(self, action: #selector(signInWithGoogle), for: .touchUpInside)
        return loginButton
    }()
    
    lazy var signInWithEmail: UIButton = {
        
        let loginButton = UIButton()
        loginButton.frame = CGRect(x: 32, y: 360 + 80 + 80 + 80 + 80, width: view.frame.width - 64, height: 50)
        loginButton.setTitle("Sign In with Email", for: .normal)
        loginButton.addTarget(self, action: #selector(openSignInVC), for: .touchUpInside)
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
        view.addSubview(googleLoginButton)
        view.addSubview(customGoogleLoginButton)
        view.addSubview(signInWithEmail)
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
        signIntoFireBase()
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
            }
            
        }
    }
    
    private func signIntoFireBase() {
        let accessToken = AccessToken.current
        guard let accessTokenString = accessToken?.tokenString else { return }
        let credentials = FacebookAuthProvider.credential(withAccessToken: accessTokenString)
        
        Auth.auth().signIn(with: credentials) { [unowned self] user, error in
            if let error = error {
                print(error.localizedDescription)
                return
            }
            
            print("Logged in")
            self.fetchFacebookFields()
        }
    }
    
    private func fetchFacebookFields() {
        GraphRequest(graphPath: "me", parameters: ["fields": "id, name, email"]).start {[unowned self] _, result, error in
            if let error = error {
                print(error.localizedDescription)
                return
            }
            
            if let result = result as? [String: Any] {
                self.userProfile = UserProfile(data: result)
                self.saveIntoFireBase()
            }
            
        }
    }
    
    private func saveIntoFireBase() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let userData = ["name": userProfile.name, "email": userProfile.email]
        
        let values = [uid : userData]
        Database.database().reference().child("users").updateChildValues(values) { [unowned self] error, _ in
            if let error = error {
                print(error.localizedDescription)
                return
            }
            
            self.openMainVC()
        }
    }
    
    @objc private func openSignInVC() {
        performSegue(withIdentifier: "SignIn", sender: self)
    }
}

// MARK: Google SDK
extension LoginViewController: AuthUIDelegate {
    @objc func signInWithGoogle() {
        guard let clientID = FirebaseApp.app()?.options.clientID else { return }
        
        // Create Google Sign In configuration object.
        let config = GIDConfiguration(clientID: clientID)
        
        // Start the sign in flow!
        GIDSignIn.sharedInstance.signIn(with: config, presenting: self) { [unowned self] user, error in
            
            if let error = error {
                print(error.localizedDescription)
                return
            }
            
            if let username = user?.profile?.name, let email = user?.profile?.email {
                let userData = ["name": username, "email": email]
                userProfile = UserProfile(data: userData)
            }
            
            guard
                let authentication = user?.authentication,
                let idToken = authentication.idToken
            else {
                return
            }
            
            let credential = GoogleAuthProvider.credential(withIDToken: idToken,
                                                           accessToken: authentication.accessToken)
            
            Auth.auth().signIn(with: credential) { user, error in
                if let error = error {
                    print(error.localizedDescription)
                    return
                }
                
                print("Successfull log in with Google")
                self.saveIntoFireBase()
            }
        }
    }
    
    
}
