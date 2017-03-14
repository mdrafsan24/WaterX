//
//  Warnings.swift
//  Whats-in-my-water
//
//  Created by Rafsan Chowdhury on 3/12/17.
//  Copyright © 2017 Mcraf. All rights reserved.
//

import Foundation

class Warnings {
    private var _warning: String!
    
    var warning: String {
        if _warning != nil {
            return self._warning
        }
        return ""
    }
    
    init (warning: String) {
        self._warning = warning
    }
}



