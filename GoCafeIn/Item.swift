//
//  Item.swift
//  GoCafeIn
//
//  Created by RedMac on 2020/12/08.
//  Copyright © 2020 AppBoong. All rights reserved.
//

import Foundation

extension UIViewController {
    func rightItem(text : String) {
        let longTitleLabel = UILabel()
        
            longTitleLabel.text = text
            longTitleLabel.font = .none
            longTitleLabel.font = .boldSystemFont(ofSize: 20)
            longTitleLabel.sizeToFit()
            
            let rightItem = UIBarButtonItem(customView: longTitleLabel)
        
        self.navigationItem.rightBarButtonItem = rightItem
    }
    func leftItem(area : String, city : String,action : Selector) {
        let imageAttachment = NSTextAttachment()
        imageAttachment.image = UIImage(systemName: "location")?.withRenderingMode(.alwaysTemplate)
        imageAttachment.image?.withTintColor(.brown)
        
        let longTitleLabel = UILabel()
        
            longTitleLabel.font = .none
            longTitleLabel.font = .systemFont(ofSize: 13)
        longTitleLabel.textColor = .brown
        let attributedString = NSMutableAttributedString(string: "")
        attributedString.append(NSAttributedString(attachment: imageAttachment))
        attributedString.append(NSAttributedString(string: " \(area) \(city)"))
        longTitleLabel.attributedText = attributedString

        longTitleLabel.sizeToFit()
        let attButton = UIButton()
        attButton.addTarget(self, action: action, for: .touchUpInside)
        attButton.setTitleColor(.brown, for: .normal)
       
        attButton.frame.size = CGSize(width: 100, height: 30)
        attButton.titleLabel?.font = .systemFont(ofSize: 13)
        attButton.setAttributedTitle(attributedString, for: .normal)
        let leftItem = UIBarButtonItem(customView: attButton)
        
        self.navigationItem.leftBarButtonItem = leftItem
        
    }
    func labelImage(label : UILabel, text : String) {
        let imageAttachment = NSTextAttachment()
        imageAttachment.image = UIImage(systemName: "star")?.withRenderingMode(.alwaysTemplate)
        imageAttachment.image?.withTintColor(.white)
        let attributedString = NSMutableAttributedString(string: "")
        attributedString.append(NSAttributedString(attachment: imageAttachment))
        attributedString.append(NSAttributedString(string: text))
        label.attributedText = attributedString
    }
    func buttonImage(button : UIButton,text: String,image : UIImage){
        let imageAttachment = NSTextAttachment()
        imageAttachment.image = image.withRenderingMode(.alwaysTemplate)
        imageAttachment.image?.withTintColor(.brown)
        let attributedString = NSMutableAttributedString(string: "")
        attributedString.append(NSAttributedString(attachment: imageAttachment))
        attributedString.append(NSAttributedString(string: text))
        button.setAttributedTitle(attributedString, for: .normal)
    }
}
