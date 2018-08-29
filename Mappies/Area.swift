//
//  LatitudeLongitute.swift
//  Mappies
//
//  Created by Hanafi Hisyam on 23/08/2018.
//  Copyright © 2018 Hanafi Hisyam. All rights reserved.
//

import Foundation

struct Area: Codable {
    let pln_area_n: String
    let geojson: String
}

struct GeoJson: Codable {
    let type: String
    let coordinates: String
}
