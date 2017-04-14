//
//  WarningCell.swift
//  Whats-in-my-water
//
//  Created by Rafsan Chowdhury on 3/12/17.
//  Copyright © 2017 Mcraf. All rights reserved.
//

import UIKit

class WarningCell: UITableViewCell {
    @IBOutlet weak var warningLbl: UILabel!
    @IBOutlet weak var warning: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func configureCell (warning: Warnings) {
        self.warningLbl.text = warning.warning
        self.warning.isHidden = false
    }

}
