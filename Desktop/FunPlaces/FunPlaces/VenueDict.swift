//
//  VenueDict.swift
//  FunPlaces
//
//  Created by Hongshan Liu on 10/11/14.
//  Copyright (c) 2014 Hongshan Liu. All rights reserved.
//

import Foundation
import UIKit
import CoreLocation

struct VenueDict {
    var name: String?
    var location: CLLocationCoordinate2D?
    var rating: Double?
    var distance: Int?
    var address: String?
    var price: String?
    var phone: String?
    var hours: String?
    var hasMenu: Bool?
    var MenuUrl: NSURL?
    var url: NSURL?
    var checkinsCount: Int?
    
    init(itemDictionary:NSDictionary) {
        price = "$"
        
        
        name = (itemDictionary["name"] as String?)
        
        var locationDict: NSDictionary = itemDictionary["location"] as NSDictionary
        var latitude: CLLocationDegrees = locationDict["lat"] as CLLocationDegrees
        var longitude: CLLocationDegrees = locationDict["lng"] as CLLocationDegrees
        location = CLLocationCoordinate2DMake(latitude, longitude)
        
        rating = (itemDictionary["rating"] as Double?)
        
        distance = (locationDict["distance"] as Int?)
        
        address = (locationDict["address"] as String?)
        
        var priceDict: NSDictionary? = itemDictionary["price"] as NSDictionary?
        
        if (priceDict != nil) {
            
            
            if (priceDict!["tier"] != nil){
                var tempPrice = (priceDict!["tier"] as Int)
                                
                if (tempPrice == 1) {
                    price = "$"
                } else if (tempPrice == 2) {
                    price = "$$"
                } else {
                    price = "$$$"
                }
                
            }
            
        }
        
        
        
        
        
        var contactDict: NSDictionary = itemDictionary["contact"] as NSDictionary
        
        phone = (contactDict["phone"] as String?)
        
        if (itemDictionary["hours"] != nil) {
            var hoursDict: NSDictionary = itemDictionary["hours"] as NSDictionary
            
            hours = hoursDict["status"] as String?
        }
        
        hasMenu = itemDictionary["hasMenu"] as Bool?
        
        if (itemDictionary["menu"] != nil){
            
            var menuDict: NSDictionary = itemDictionary["menu"] as NSDictionary
        
            var tempMenuUrl = menuDict["url"] as String?
        
            MenuUrl = NSURL(string: tempMenuUrl!)
        }
        
        if (itemDictionary["url"] != nil) {
            
            var tempUrl = itemDictionary["url"] as String?
            
            url = NSURL(string: tempUrl!)
            
        }
        
        var statsDict: NSDictionary = itemDictionary["stats"] as NSDictionary
        
        checkinsCount = statsDict["checkinsCount"] as Int?
        
        
        
    }
}
