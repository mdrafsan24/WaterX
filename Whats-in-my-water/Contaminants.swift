//
//  Contaminants.swift
//  Whats-in-my-water
//
//  Created by Rafsan Chowdhury on 2/11/17.
//  Copyright © 2017 Mcraf. All rights reserved.
//

import Foundation

class Contaminants {
    
    private var _level = [String]()
    private var _description = [String]()
    private var _nameOfSubstance = [String]()
    
    var level: [String] {
        if _level.isEmpty != true {
            return _level
        }
        return [String]()
    }
    var description: [String] {
        if _description.isEmpty != true {
            return _description
        }
        return [String]()
    }
    var nameOfSubstance: [String] {
        if _nameOfSubstance.isEmpty != true {
            return _nameOfSubstance
        }
        return [String]()
    }
    
    init (level: [String]) {
        self._level = level
    }
    init (description: [String]) {
        self._description = description
    }
    init( nameOfSubstance: [String]) {
        self._nameOfSubstance = nameOfSubstance
    }
    
    
    


}
