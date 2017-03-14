//
//  DiseaseCell.swift
//  Whats-in-my-water
//
//  Created by Rafsan Chowdhury on 3/9/17.
//  Copyright © 2017 Mcraf. All rights reserved.
//

import UIKit
import UIKit
import QuartzCore
import Firebase

class DiseaseCell: UITableViewCell {

    @IBOutlet weak var diseaseName: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
    func configureCell (name: DiseaseName) {
        self.diseaseName.text = name.diseaseName
    }
    

}
