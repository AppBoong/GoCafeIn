//
//  AlertExtension.swift
//  GoCafeIn
//
//  Created by RedMac on 2020/09/11.
//  Copyright © 2020 AppBoong. All rights reserved.
//

import Foundation
import UIKit
import Toast_Swift

extension UIViewController {
    
        func showAlert(mainTitle : String , mainMessage : String , oktitle: String ,success : @escaping () -> Void) {

            let alert = UIAlertController(title: mainTitle, message: mainMessage, preferredStyle: .alert)

            let ok = UIAlertAction(title: oktitle, style: .default ) { completion in
                success()
            }
            let cancel =  UIAlertAction(title: "취소", style: .cancel, handler: nil )
    
            alert.addAction(ok)
            alert.addAction(cancel)
            
            present(alert, animated: true , completion: nil)
        }

    func showToast(title : String, position : ToastPosition) {
        self.view.makeToast(title, duration: 1.0, position: position)
    }
    func showLoadingBar() {
        NVActivityIndicatorView(frame: .zero, type: .pacman, color: .systemYellow, padding: .none)
        
    }
    func showAction(title : String, message: String, first : String, second : String, firstAction : @escaping() -> (), secondAction : @escaping() -> ()) {

        let optionMenu = UIAlertController(title: title, message: message, preferredStyle: .actionSheet)
        let firstAction = UIAlertAction(title: first, style: .default, handler: {
            (alert: UIAlertAction!) -> Void in
            firstAction()
        })
        let secondAction = UIAlertAction(title: second, style: .default, handler: {
            (alert: UIAlertAction!) -> Void in
            secondAction()
        })
        let cancelAction = UIAlertAction(title: "취소", style: .cancel, handler: {
            (alert: UIAlertAction!) -> Void in
        })
        optionMenu.addAction(firstAction)
        optionMenu.addAction(secondAction)
        optionMenu.addAction(cancelAction)
        self.present(optionMenu, animated: true, completion: nil)
    }
}
