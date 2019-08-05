//
//  MainCell.swift
//  EASIPRO-Home
//
//  Created by Raheel Sayeed on 8/5/19.
//  Copyright © 2019 Boston Children's Hospital. All rights reserved.
//

import UIKit

class MainCell: UITableViewCell {


    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblCaption: UILabel!
    @IBOutlet weak var lblResult: UILabel!
    @IBOutlet weak var lblMeta: UILabel!
    @IBOutlet weak var lblCode: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
