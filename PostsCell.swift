//
//  PostsCell.swift
//  Instagram Final
//
//  Created by Darwing Medina on 14/4/16.
//  Copyright © 2016 Parse. All rights reserved.
//

import UIKit

class PostsCell: UITableViewCell {
    
    
    @IBOutlet weak var postImage: UIImageView!
    
    @IBOutlet weak var titleLabel: UILabel!

    @IBOutlet weak var userName: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
