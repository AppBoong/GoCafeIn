//
//  EULAViewController.swift
//  GoCafeIn
//
//  Created by RedMac on 2021/01/04.
//  Copyright © 2021 AppBoong. All rights reserved.
//

import UIKit

class EULAViewController: UIViewController {
    @IBOutlet var eulaView: UIView!
    @IBOutlet var eulaTextView: UITextView!
    @IBOutlet var agreeButton: UIButton!
    @IBOutlet var disagreeButton: UIButton!
    var delegate : RefreshDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        eulaView.layer.cornerRadius = 10
    }
    
    @IBAction func agreeButtonClicked(_ sender: Any) {
        if let delegate = self.delegate{
            let uid = Auth.auth().currentUser?.uid
            DatabaseManager.shared.setEula(uid: uid!)
            delegate.agree()
        }
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func disagreeButtonClicked(_ sender: Any) {
        AuthManager.shared.logOut { success in
            DispatchQueue.main.async {
            if success == true {
                Auth.auth().currentUser?.delete(completion: { (error) in
                    print(error)
                })
                let lvc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "LoginViewController") as! LoginViewController
                let appDelegate = UIApplication.shared.delegate as! AppDelegate
                
                appDelegate.window?.rootViewController = lvc
                self.view.window?.rootViewController = lvc
            }
            else {
                             
            }
        }
    }
    }
}
