//
//  DiseaseName.swift
//  Whats-in-my-water
//
//  Created by Rafsan Chowdhury on 3/9/17.
//  Copyright © 2017 Mcraf. All rights reserved.
//

import Foundation

class DiseaseName {
    
    private var _diseaseName: String!
    
    var diseaseName: String {
        if _diseaseName != nil {
            return self._diseaseName
        }
        return ""
    }
    
    init(name: String) {
        self._diseaseName = name
    }
    
}
