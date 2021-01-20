//
//  ProfileSettingViewController.swift
//  GoCafeIn
//
//  Created by RedMac on 2020/11/30.
//  Copyright © 2020 AppBoong. All rights reserved.
//

import UIKit

class ProfileSettingViewController: UIViewController, UITextFieldDelegate {
 
    var delegate : ProfileChangeDelegate?
    @IBOutlet var profileImage: UIImageView!
    @IBOutlet var emailField: UITextField!
    @IBOutlet var nameField: UITextField!
    var config = YPImagePickerConfiguration()
    var beforeImage : UIImage?
    var beforeName : String?
    override func viewDidLoad() {
        super.viewDidLoad()
        let loading = NVActivityIndicatorView(frame: CGRect(x: self.view.center.x - 25  , y: self.view.center.y - 30 , width: 60 , height: 60), type: .pacman, color: .systemYellow, padding: .pi)
        DispatchQueue.main.async {
            self.view.addSubview(loading)
            self.getUserInfo(loadingView: loading)
        }
        
        nameField.delegate = self
        config.startOnScreen = .library
        profileImage.contentMode = .scaleToFill
        profileImage.clipsToBounds = true
        profileImage.layer.cornerRadius = view.frame.size.width / 4
        profileImage.layer.borderColor = UIColor.clear.cgColor
       dismissPickerView(field: nameField)

    }
    func dismissPickerView(field : UITextField) {
        let toolBar = UIToolbar()
        toolBar.sizeToFit()
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let button = UIBarButtonItem(title: "확인", style: .plain, target: self, action: #selector(selectPressed))
        toolBar.setItems([flexibleSpace, button], animated: true)
        toolBar.isUserInteractionEnabled = true
        field.inputAccessoryView = toolBar
    }
    @objc func selectPressed() {
        view.endEditing(true)
    }
    func setUserInfo(profilePic : UIImage? = nil, username : String, success : @escaping() -> ()) {
        let loading = NVActivityIndicatorView(frame: CGRect(x: self.view.center.x - 25  , y: self.view.center.y - 30 , width: 60 , height: 60), type: .pacman, color: .systemYellow, padding: .pi)
        self.view.addSubview(loading)
        loading.startAnimating()
        let uid = Auth.auth().currentUser?.uid
        if profilePic == nil {
            DatabaseManager.shared.setUsername(username : username, uid : uid!)
            success()
        }else {
            profilePic?.jpegData(compressionQuality: 0.001)
            StorageManager.shared.uploadImage(image: profilePic!) { url in
                let imageURL = url?.downloadURL.absoluteString
                DatabaseManager.shared.setUser(username: username, profileImage: imageURL!, uid : uid! )
                loading.stopAnimating()
                success()
            }
        }
        
    }
    func getUserInfo(loadingView : NVActivityIndicatorView) {
        loadingView.startAnimating()
        let uid = Auth.auth().currentUser?.uid
        DatabaseManager.shared.getUser(uid : uid!) { username, email, profilePic in

            self.emailField.text = email.getEmailKey()
            self.nameField.text = username
            let profileImg = profilePic
            if profileImg == "" {
                self.profileImage.image = UIImage(systemName: "person.circle.fill")
                self.beforeName = self.nameField.text
            }else {
                self.profileImage.image?.jpegData(compressionQuality: 0.001)
                
                let url = URL(string: "\(profilePic)")
                self.profileImage.kf
                    .setImage(with: url!)
                self.beforeImage = self.profileImage.image
                self.beforeName = self.nameField.text
            }
        }
        loadingView.stopAnimating()
        
    }
    @IBAction func profileImageButton(_ sender: Any) {
        let picker = YPImagePicker(configuration: config)
              
              present(picker, animated: true, completion: nil)
              picker.didFinishPicking { [unowned picker] items, _ in
                  if let photo = items.singlePhoto {
                    self.profileImage.image = photo.originalImage
                  }
              picker.dismiss(animated: true, completion: nil)
             }
    }
    
    
    @IBAction func cancelButton(_ sender: Any) {
        dismiss(animated: true, completion: nil)
        
    }
    @IBAction func saveButton(_ sender: Any) {
        if nameField.text == nil {
            showToast(title: "정보를 입력해주세요", position: .center)
        }else {
            showAlert(mainTitle: "프로필 변경", mainMessage: "프로필 정보를 변경하시겠습니까?", oktitle: "확인") {
                if self.nameField.text!.count >= 8 {
                    self.showToast(title: "닉네임을 8자 이하로 입력해주세요", position: .center)
                }else if self.beforeName == self.nameField.text!{
                    if self.beforeImage == self.profileImage.image {
                        if let delegate = self.delegate {
                                delegate.change() {
                                    self.dismiss(animated: true , completion: nil)
                            }
                        }
                    }else {
                        if let delegate = self.delegate {
                            self.setUserInfo(profilePic: self.profileImage.image!, username: self.nameField.text!) {
                                delegate.change() {
                                    self.dismiss(animated: true , completion: nil)
                                }
                            }
                        }
                    }
                }
                else{
                    DatabaseManager.shared.userMatch(name: self.nameField.text!) { (name) in
                        if name.count == 1 {
                            self.showToast(title: "중복된 아이디 입니다", position: .center)
                        }else {
                            if self.beforeImage == self.profileImage.image {
                                if let delegate = self.delegate {
                                    self.setUserInfo( username: self.nameField.text!) {
                                        delegate.change() {
                                            self.dismiss(animated: true , completion: nil)
                                        }
                                    }
                                }
                            }else {
                                if let delegate = self.delegate {
                                    self.setUserInfo(profilePic: self.profileImage.image!, username: self.nameField.text!) {
                                        delegate.change() {
                                            self.dismiss(animated: true , completion: nil)
                                        }
                                    }
                                }
                            }
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
