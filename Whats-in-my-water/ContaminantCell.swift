//
//  ContaminantCell.swift
//  Whats-in-my-water
//
//  Created by Rafsan Chowdhury on 2/11/17.
//  Copyright © 2017 Mcraf. All rights reserved.
//

import UIKit
import QuartzCore
import Firebase

class ContaminantCell: UITableViewCell {

    @IBOutlet weak var descriptionLbl: UITextView!
    @IBOutlet weak var levelImg: UIImageView!
    @IBOutlet weak var contaminantName: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
        
    func configureCell (contamName: String, contamLevel: String, contamDesc: String) {
        
        self.descriptionLbl.text = contamDesc
        
        self.contaminantName.text = contamName
        
        self.levelImg.image = UIImage(named: contamLevel)
    }

}
