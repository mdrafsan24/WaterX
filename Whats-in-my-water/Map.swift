//
//  Map.swift
//  Whats-in-my-water
//
//  Created by Rafsan Chowdhury on 3/10/17.
//  Copyright © 2017 Mcraf. All rights reserved.
//

import Foundation
import MapKit

class Map: NSObject, MKAnnotation {
    var title: String?
    var subtitle: String?
    var coordinate: CLLocationCoordinate2D
    
    init(title: String, subtitle: String, coordinate: CLLocationCoordinate2D) {
        self.title = title
        self.subtitle = subtitle
        self.coordinate = coordinate
        
    }
}
