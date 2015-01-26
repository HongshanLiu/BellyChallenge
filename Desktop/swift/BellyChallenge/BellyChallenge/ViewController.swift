//
//  ViewController.swift
//  BellyChallenge
//
//  Created by Hongshan Liu on 1/23/15.
//  Copyright (c) 2015 Hongshan Liu. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit
import CoreData


class ViewController: UIViewController,UITableViewDataSource, UITableViewDelegate, CLLocationManagerDelegate, MKMapViewDelegate, UISearchBarDelegate  {

    @IBOutlet weak var myTableView: UITableView!
    
    //public variables
    var manager:CLLocationManager!
    
    var latitude: CLLocationDegrees!
    var longitude: CLLocationDegrees!
    
    var restaurantArray:[VenueDict] = [VenueDict]()
    
    
    var arrayOfRestaurant:[Restaurant] = [Restaurant]()
    
    var cachedArrayOfRestaurant:[Restaurant] = [Restaurant]()
    
    
    var appDel: AppDelegate!
    var context: NSManagedObjectContext!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        self.myTableView.delegate = self;
        self.myTableView.dataSource = self;
        
        UIApplication.sharedApplication().setStatusBarStyle(UIStatusBarStyle.LightContent, animated: true)

        manager = CLLocationManager()
        manager.requestAlwaysAuthorization()
        
        if (CLLocationManager.locationServicesEnabled()) {
            manager.delegate = self
            manager.desiredAccuracy = kCLLocationAccuracyBest
            manager.startUpdatingLocation()
        }
        
        
        //set up app delegate and context for the core data access
        appDel = UIApplication.sharedApplication().delegate as AppDelegate
        context = appDel.managedObjectContext!
        
        
        
        
        
        
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    

    
    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
        
        var userLocation: CLLocation = locations[0] as CLLocation
        latitude = userLocation.coordinate.latitude
        longitude = userLocation.coordinate.longitude
        
        
        
        if (userLocation.horizontalAccuracy < 300) {
            
            //stop updating
            manager.stopUpdatingLocation()
            
            //fourSquare api inforamtion
            var fourSquareUrlString: String = ("https://api.foursquare.com/v2/venues/explore?client_id=FARFF35L0FYS22Q0ZONSYTHEAES4E2JNGWEP2OFC4ODMW5G0&client_secret=REUF1KJ2F0IKQHXF1WYJCU0YSTZ4N2I4MP21OZ5A1YSDGMPZ&v=20130815&ll=\(latitude),\(longitude)&limit=15&venuePhotos=1&openNow=1&query=food").stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!
            
            let fourSquareURL = NSURL(string: fourSquareUrlString)
            
            let sharedSession = NSURLSession.sharedSession()
            
            
            //start the URL call and fetch the data with the completion-handler
            
            let downloadTask: NSURLSessionDownloadTask = sharedSession.downloadTaskWithURL(fourSquareURL!, completionHandler: { (location: NSURL!, response: NSURLResponse!, error: NSError!) -> Void in
                
                // check for HTTP response
                if (error == nil) {
                    println("works")
                    
                    
                    
                    let dataObject = NSData(contentsOfURL: location)
                    let weatherDictionary: NSDictionary = NSJSONSerialization.JSONObjectWithData(dataObject!, options: nil, error: nil) as NSDictionary
                    
                    
                    let newDict: NSDictionary = (weatherDictionary["response"] as NSDictionary)
                    let newArray: NSArray = newDict["groups"] as NSArray
                    let itemArray: NSArray = newArray[0]["items"] as NSArray
                    
                    
                    for item in itemArray {
                        
                        var tempDict: NSDictionary = item as NSDictionary
                        var itemDict: NSDictionary = tempDict["venue"] as NSDictionary
                        
                        
                        
                        let venueDict = VenueDict(itemDictionary: itemDict)
                        self.restaurantArray.append(venueDict)
                        
                        var lat: CLLocationDegrees? = (venueDict.location?.latitude) as CLLocationDegrees?
                        var lng: CLLocationDegrees? = (venueDict.location?.longitude) as CLLocationDegrees?
                        
                        
                        
                        
                    }
                    
                    
                    
                    self.restaurantArray.sort({ $0.distance < $1.distance })
                    
                    
                    self.loadRestaurant();
                    self.cacheRestaurant();
                    
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        self.myTableView.reloadData()
                    })
                    
                    
                    
                    
                    
                    
                } else {
                    println("yo,  api failed")
                    self.retrieveCache();
                    self.arrayOfRestaurant = self.cachedArrayOfRestaurant;
                    
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        self.myTableView.reloadData()
                    })
                }
                
                
            })
            
            downloadTask.resume()
            
            
            
        }
            
        
        
        
        
    }
    
    func loadRestaurant() {
        
        for item in self.restaurantArray {
            
            var storeImage = item.imageUrl
            var tempUrl = NSURL(string: storeImage!)
            var data = NSData(contentsOfURL: tempUrl!)

            var restaurant = Restaurant(name: item.name!,distance: String(item.distance!) + " meters away",type: "Food&Drink",storeImage: data!,availabity: item.isOpen!)
            arrayOfRestaurant.append(restaurant)
        }
        
        
        
        
    }
    
    func cacheRestaurant() {
        
        
        var request = NSFetchRequest(entityName: "Restaurant")
        request.returnsObjectsAsFaults = false
        var result = context.executeFetchRequest(request, error: nil)
        
        for item: AnyObject in result! {
                context.deleteObject(item as NSManagedObject)
        }
        
        
        
        for item in self.restaurantArray {
            var newRestaurant = NSEntityDescription.insertNewObjectForEntityForName("Restaurant", inManagedObjectContext: context) as NSManagedObject;
            newRestaurant.setValue(item.name!, forKey: "name")
            newRestaurant.setValue(String(item.distance!) + " meters away", forKey: "distance")
            newRestaurant.setValue("Food&Drink", forKey: "type")
            newRestaurant.setValue(item.isOpen!, forKey: "isOpen")
            
            var storeImage = item.imageUrl;
            var tempUrl = NSURL(string: storeImage!)
            var data = NSData(contentsOfURL: tempUrl!)
            
            newRestaurant.setValue(data, forKey: "imageData")
            
            context.save(nil)
            
            
        }
    }
    
    func retrieveCache() {
        var request = NSFetchRequest(entityName: "Restaurant")
        request.returnsObjectsAsFaults = false
        var result = context.executeFetchRequest(request, error: nil)
        
        
        cachedArrayOfRestaurant = []
        
        for item: AnyObject in result! {
            var name:String = item.valueForKey("name")! as String
            var distance:String = item.valueForKey("distance") as String
            var type:String = item.valueForKey("type") as String
            var isOpen:Bool = item.valueForKey("isOpen") as Bool
            var imageData:NSData = item.valueForKey("imageData") as NSData
            
            
            var restaurant = Restaurant(name: name,distance: distance,type: type,storeImage: imageData,availabity: isOpen)
            cachedArrayOfRestaurant.append(restaurant)
            
            println(item.valueForKey("name"))
            
            
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrayOfRestaurant.count
    }
    
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell:CustomCell = tableView.dequeueReusableCellWithIdentifier("MyCell") as CustomCell;
        cell.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
        
        let resaurant = arrayOfRestaurant[indexPath.row]
        
        cell.setCell(resaurant.name, distance: resaurant.distance, type: resaurant.type, availability: resaurant.availabity, storeImage: resaurant.storeImage)
        
        
        
        
        return cell
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
    
    
    
    


}

