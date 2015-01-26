//
//  Restaurant.swift
//  BellyChallenge
//
//  Created by Hongshan Liu on 1/23/15.
//  Copyright (c) 2015 Hongshan Liu. All rights reserved.
//

import Foundation

class Restaurant {
    var name:NSString
    var distance:NSString
    var type:NSString
    var storeImage:NSData
    var availabity:Bool
    
    init(name:NSString,distance:NSString,type:NSString,storeImage:NSData,availabity:Bool) {
        
        self.name = name
        self.distance = distance
        self.type = type
        self.storeImage = storeImage
        self.availabity = availabity
        
    }
}
