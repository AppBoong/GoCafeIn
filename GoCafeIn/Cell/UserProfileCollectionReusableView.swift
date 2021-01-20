//
//  UserProfileCollectionReusableView.swift
//  GoCafeIn
//
//  Created by RedMac on 2020/12/16.
//  Copyright © 2020 AppBoong. All rights reserved.
//

import UIKit

class UserProfileCollectionReusableView: UICollectionReusableView {
    
    @IBOutlet var userHeaderView: UIView!
    @IBOutlet var userProfileImage: UIImageView!
    @IBOutlet var usernameLabel: UILabel!
    @IBOutlet var followerLabel: UILabel!
    @IBOutlet var followerCountLabel: UILabel!
    @IBOutlet var followingLabel: UILabel!
    @IBOutlet var followingCountLabel: UILabel!
    @IBOutlet var followButton: UIButton!
    @IBOutlet var userReviewCountLabel: UILabel!
    @IBOutlet var userLikeCountLabel: UILabel!
    @IBOutlet var goFollowingButton: UIButton!
    @IBOutlet var goFollowerButton: UIButton!
    
    @IBOutlet var blockButton: UIButton!
    override func prepareForReuse() {
        super.prepareForReuse()
    }
}
