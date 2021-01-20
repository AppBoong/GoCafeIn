//
//  ProfileCollectionReusableView.swift
//  GoCafeIn
//
//  Created by RedMac on 2020/09/13.
//  Copyright © 2020 AppBoong. All rights reserved.
//

import UIKit

class ProfileCollectionReusableView: UICollectionReusableView {
    static let identifier = "ProfileCollectionReusableView"
    @IBOutlet var profileHeaderView: UIView!
    @IBOutlet var profileImage: UIImageView!
    @IBOutlet var usernameLabel: UILabel!
    @IBOutlet var reviewCountLabel: UILabel!
    @IBOutlet var likeCountLabel: UILabel!
 
    @IBOutlet var reviewLabel: UILabel!
    @IBOutlet var likeLabel: UILabel!
    @IBOutlet var followerCountLabel: UILabel!
    @IBOutlet var followingCountLabel: UILabel!
    @IBOutlet var goFollowingButton: UIButton!
    
    @IBOutlet var goFollowerButton: UIButton!
    
    
    @IBOutlet var profileChangeButton: UIButton!
    
    override func prepareForReuse() {
        super.prepareForReuse()
    }
    
}
