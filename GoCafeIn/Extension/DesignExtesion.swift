//
//  DesignExtesion.swift
//  GoCafeIn
//
//  Created by RedMac on 2020/09/13.
//  Copyright © 2020 AppBoong. All rights reserved.
//

import Foundation
import UIKit

extension UIViewController {
    
    func textFieldDesign(field : UITextField) {
           field.layer.cornerRadius = 15
           field.clipsToBounds = false
           field.backgroundColor = .white
        
       }
    func buttonDesign(field : UIButton) {
        field.layer.cornerRadius = 15
        field.clipsToBounds = false
        field.backgroundColor = .white
    }
    func setGradientBackground(view : UIView,colorTop: UIColor, colorBottom: UIColor) {
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [colorBottom.cgColor, colorTop.cgColor]
        gradientLayer.startPoint = CGPoint(x: 0.6, y: 0.0)
        gradientLayer.endPoint = CGPoint(x: 0.5, y: 0.0)
        gradientLayer.locations = [0, 1]
        gradientLayer.frame = view.bounds

        view.layer.insertSublayer(gradientLayer, at: 0)
    }
    func GradientBackground(view : UIView,colorTop: UIColor, colorBottom: UIColor) {
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [colorBottom.cgColor, colorTop.cgColor]
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 0.3)
        gradientLayer.endPoint = CGPoint(x: 0.5, y: -0.2)
        gradientLayer.locations = [0, 1]
        gradientLayer.frame = view.bounds

        view.layer.insertSublayer(gradientLayer, at: 0)
        
    }

}
