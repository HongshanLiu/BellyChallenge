//
//  CustomCell.swift
//  BellyChallenge
//
//  Created by Hongshan Liu on 1/23/15.
//  Copyright (c) 2015 Hongshan Liu. All rights reserved.
//

import UIKit

class CustomCell: UITableViewCell {
    
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var distance: UILabel!
    @IBOutlet weak var type: UILabel!
    @IBOutlet weak var availability: UILabel!
    @IBOutlet weak var storeImage: UIImageView!
    
    
    
    
    
    
    func setCell(name:NSString, distance:NSString, type:NSString, availability:Bool, storeImage:NSData) {
        self.name.text = name;
        self.distance.text = distance;
        self.type.text = type;
        
        
        self.storeImage.image = UIImage(data: storeImage)
        
        
        if availability == true {
            self.availability.text = "open"
        } else {
            self.availability.text = "closed"
        }
    }
    
    
    

}
