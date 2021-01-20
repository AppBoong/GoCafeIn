//
//  ProfileCollectionViewCell.swift
//  GoCafeIn
//
//  Created by RedMac on 2020/09/13.
//  Copyright © 2020 AppBoong. All rights reserved.
//

import UIKit

class ProfileCollectionViewCell: UICollectionViewCell {
    static let identifier = "ProfileCollectionViewCell"
    private let profileImage : UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    override init(frame : CGRect){
        super.init(frame: frame)
        contentView.addSubview(profileImage)
        contentView.clipsToBounds = true
    }
    required init?(coder: NSCoder) {
        fatalError()
    }
 
    func imageData() {
        profileImage.image?.jpegData(compressionQuality: 0.001)
    }
    func configure(with image : UIImage?) {
        profileImage.image = image
    }
    func setImage(with url : URL){
        profileImage.kf.setImage(with: url)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        profileImage.frame = contentView.bounds
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        profileImage.image = nil
    }
        
    
}
