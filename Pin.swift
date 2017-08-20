//
//  Pin+CoreDataClass.swift
//  VirtualTourist
//
//  Created by Steven Taglohner on 13/08/2017.
//  Copyright © 2017 Steven Taglohner. All rights reserved.
//

import Foundation
import CoreData
import MapKit

@objc(Pin)
public class Pin: NSManagedObject, MKAnnotation {
    override init(entity: NSEntityDescription, insertInto context: NSManagedObjectContext?) {
        super.init(entity: entity, insertInto: context)
    }
    
    init(pinLatitude: Double, pinLongitude: Double, context: NSManagedObjectContext){
        let entity = NSEntityDescription.entity(forEntityName: "Pin", in: context)
        super.init(entity: entity!, insertInto: context)
        latitude = pinLatitude as Double
        longitude = pinLongitude as Double
    }
    
    public var coordinate: CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: latitude as Double, longitude: longitude as Double)
    }
}
