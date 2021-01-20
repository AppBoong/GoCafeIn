//
//  FollowTableViewCell.swift
//  GoCafeIn
//
//  Created by RedMac on 2020/12/19.
//  Copyright © 2020 AppBoong. All rights reserved.
//

import UIKit

class FollowTableViewCell: UITableViewCell {

    @IBOutlet var followView: UIView!
 
    @IBOutlet var unfollowButton: UIButton!
    @IBOutlet var profileImage: UIImageView!
    @IBOutlet var followNameLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
