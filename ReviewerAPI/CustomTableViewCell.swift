//
//  CustomTableViewCell.swift
//  ReviewerAPI
//
//  Created by Christine Oakes on 9/27/17.
//  Copyright © 2017 Maedchen Oakes Prod. All rights reserved.
//

import UIKit

class CustomTableViewCell: UITableViewCell {

    @IBOutlet weak var lbCustom: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
