//
//  SignUpViewController.swift
//  GoCafeIn
//
//  Created by RedMac on 2020/09/10.
//  Copyright © 2020 AppBoong. All rights reserved.
//

import UIKit

class SignUpViewController: UIViewController {

    @IBOutlet var usernameField: UITextField!
    @IBOutlet var emailField: UITextField!
    @IBOutlet var passwordField: UITextField!
    @IBOutlet var signupButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Sign Up"
        signupButton.addTarget(self, action: #selector(signupButtonClicked), for: .touchUpInside)

        textFieldDesign(field: usernameField)
        textFieldDesign(field: emailField)
        textFieldDesign(field: passwordField)
        usernameField.delegate = self
        emailField.delegate = self
        passwordField.delegate = self
    }
    @objc func signupButtonClicked() {
        let loading = NVActivityIndicatorView(frame: CGRect(x: self.view.center.x - 25  , y: self.view.center.y - 30 , width: 60 , height: 60), type: .pacman, color: .systemYellow, padding: .pi)
        self.view.addSubview(loading)
        
        loading.startAnimating()
        emailField.resignFirstResponder()
        usernameField.resignFirstResponder()
        passwordField.resignFirstResponder()
        
        guard let email = emailField.text, !email.isEmpty,
            let password = passwordField.text, !password.isEmpty, password.count >= 8,
            let username = usernameField.text, !username.isEmpty,
            username.count <= 8 else {
            loading.stopAnimating()
                return showToast(title: "정보를 모두 입력해주세요 (닉네임 8자 이하, 패스워드 8자 이상)", position: .center)
            
        }
        DatabaseManager.shared.userMatch(name: usernameField.text!) { (name) in
            if name.count == 1 {
                loading.stopAnimating()
                self.showToast(title: "중복된 아이디입니다", position: .center)
            }else {
                AuthManager.shared.registerNewUser(username: username, email: email, password: password) { registered in
                    DispatchQueue.main.async {
                          if registered {
                            loading.stopAnimating()
                            self.dismiss(animated: true, completion: nil)
                        }
                        else {
                            loading.stopAnimating()
                            let alert = UIAlertController(title: "이미 가입된 이메일 입니다.",message: "", preferredStyle: .alert)
                            alert.addAction(UIAlertAction(title: "확인", style: .cancel, handler: nil))
                            self.present(alert, animated:  true)
                        }
                    }

                }
            }

        }
        
    }

    @IBAction func keyOut(_ sender: Any) {
        view.endEditing(true)
    }
    
}
extension SignUpViewController : UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == usernameField {
            emailField.becomeFirstResponder()
        }
        else if textField == emailField {
            passwordField.becomeFirstResponder()
        }
        else if textField == passwordField {
            signupButtonClicked()
        }
        
        return true
    }
}
