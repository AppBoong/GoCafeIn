//
//  LoginViewController.swift
//  GoCafeIn
//
//  Created by RedMac on 2020/09/10.
//  Copyright © 2020 AppBoong. All rights reserved.
//

import UIKit


enum UserStatus : Int {
    case signUp = 0 //회원가입 페이지로 연결
    case normal = 1 //메인 페이지로 연결
}
class LoginViewController: UIViewController {


    @IBOutlet var emailField: UITextField!
    @IBOutlet var passwordField: UITextField!
    
 
    @IBOutlet var loginButton: UIButton!
    @IBOutlet var signupButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loginButton.addTarget(self, action: #selector(loginButtonClicked), for: .touchUpInside)
        signupButton.addTarget(self, action: #selector(signupButtonClicked), for: .touchUpInside)
        emailField.delegate = self
        passwordField.delegate = self
        textFieldDesign(field: emailField)
        textFieldDesign(field: passwordField)
        view.backgroundColor = .systemYellow
        
        
    }

    @objc func loginButtonClicked() {
   
        guard let email = emailField.text, !email.isEmpty,
            let password = passwordField.text, !password.isEmpty, password.count >= 8 else {
            
                return
                    showToast(title: "정보를 모두 입력해주세요", position: .center)
        }
        
        AuthManager.shared.loginUser(email: email, password: password) { (success) in
            DispatchQueue.main.async {
                 if success == true{
                    
                    let currentUser = Auth.auth().currentUser

                    currentUser?.getIDTokenForcingRefresh(true) { idToken, error in
                      if let error = error {
                        print(error)
                        return;
                    }
                      UserDefaults.standard.set(idToken!, forKey: "token")
                      UserDefaults.standard.set(UserStatus.normal.rawValue, forKey: "userStatus")
                        print(UserDefaults.standard.string(forKey: "token")!)
    
                        }
                    let appDelegate = UIApplication.shared.delegate as! AppDelegate
                    let tabbar = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "MainTabBarController") as! UITabBarController
                    appDelegate.window?.rootViewController = tabbar
                    self.view.window?.rootViewController = tabbar
                    }
                    else {
                        let alert = UIAlertController(title: "log in error",message: "정보를 정확히 입력해주세요", preferredStyle: .alert)
                            alert.addAction(UIAlertAction(title: "dismiss", style: .cancel, handler: nil))
                            self.present(alert, animated:  true)
                    }
            }
        }
    }
    @objc func signupButtonClicked() {
        let sb = UIStoryboard(name: "Main", bundle: nil)
                    let vc = sb.instantiateViewController(withIdentifier: "SignUpViewController") as! SignUpViewController
                    
                    let nav = UINavigationController(rootViewController: vc)
        
        nav.modalPresentationStyle = .pageSheet
                    
                    present(nav, animated: true, completion: nil)
    }
    
    @IBAction func keyOut(_ sender: Any) {
        view.endEditing(true)
    }
    
}

extension LoginViewController : UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == emailField {
            passwordField.becomeFirstResponder()
        }else if textField == passwordField {
            loginButtonClicked()
        }
        
        return true
    }
}
