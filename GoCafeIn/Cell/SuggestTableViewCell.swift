//
//  SuggestTableViewCell.swift
//  GoCafeIn
//
//  Created by RedMac on 2020/09/23.
//  Copyright © 2020 AppBoong. All rights reserved.
//

import UIKit

class SuggestTableViewCell: UITableViewCell {

 
    @IBOutlet var likeButton: UIButton!
    @IBOutlet var suggestView: UIView!
    @IBOutlet var usernameLabel: UILabel!
    @IBOutlet var captionLabel: UILabel!
    @IBOutlet var suggetImage: UIImageView!
    @IBOutlet var ratingLabel: UILabel!
    @IBOutlet var profileImage: UIImageView!
    @IBOutlet var typeLabel: UILabel!
    @IBOutlet var cafenameLabel: UILabel!
    @IBOutlet var adressLabel: UILabel!
    @IBOutlet var distanceLabel: UILabel!
    @IBOutlet var lineView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
