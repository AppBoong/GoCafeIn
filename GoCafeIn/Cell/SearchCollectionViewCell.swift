//
//  SearchCollectionViewCell.swift
//  GoCafeIn
//
//  Created by RedMac on 2020/11/25.
//  Copyright © 2020 AppBoong. All rights reserved.
//

import UIKit

class SearchCollectionViewCell: UICollectionViewCell {
    static let identifier = "SearchCollectionViewCell"
    
    private let imageView : UIImageView = {
        let imageView = UIImageView()
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    private let rateLabel : UILabel = {
        let label = UILabel()
        return label
    }()
    private let cityLabel : UILabel = {
        let label = UILabel()
        return label
    }()
    override init(frame : CGRect) {
        super.init(frame: frame)
        contentView.addSubview(imageView)
        contentView.addSubview(rateLabel)
        contentView.addSubview(cityLabel)
        
    }
    func labelConfigure(with label : UILabel) {
       
    }
    func labelImage( text : String) {
        let imageAttachment = NSTextAttachment()
        imageAttachment.image = UIImage(systemName: "star")?.withRenderingMode(.alwaysTemplate)
        imageAttachment.image?.withTintColor(.white)
        let attributedString = NSMutableAttributedString(string: "")
        attributedString.append(NSAttributedString(attachment: imageAttachment))
        attributedString.append(NSAttributedString(string: text))
        rateLabel.attributedText = attributedString
        rateLabel.textColor = .white
        cityLabel.textColor = .white
        cityLabel.adjustsFontSizeToFitWidth = true
        cityLabel.textAlignment = .right
    }
    func text(text : String) {
        rateLabel.text = text
        
    }
    func city(city : String) {
        cityLabel.text = city
        cityLabel.font = .systemFont(ofSize: 14)
    }
    func imageData() {
        imageView.image?.jpegData(compressionQuality: 0.001)
    }
    func configure(with image : UIImage) {
        imageView.image = image
    }
    func setImage(with url : URL){
        imageView.kf.setImage(with: url)
    }
    required init?(coder: NSCoder) {
        fatalError()
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        imageView.frame = contentView.bounds
        rateLabel.frame = .init(x: contentView.bounds.minX + 5, y: contentView.bounds.maxY - 25, width: 60, height: 15 )
//        cityLabel.frame = .init(x: contentView.bounds.minX + 10, y: contentView.bounds.minY + 10, width: 100, height: 15 )
        let cityLabelFrame = contentView.bounds.width - rateLabel.frame.width
        cityLabel.frame = .init(x: contentView.bounds.maxX - cityLabelFrame  - 5, y: contentView.bounds.maxY - 20, width: cityLabelFrame, height: 15 )
    }
}
