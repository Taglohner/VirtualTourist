//
//  Photo+CoreDataClass.swift
//  VirtualTourist
//
//  Created by Steven Taglohner on 13/08/2017.
//  Copyright © 2017 Steven Taglohner. All rights reserved.
//

import Foundation
import CoreData

@objc(Photo)
public class Photo: NSManagedObject {

    override init(entity: NSEntityDescription, insertInto context: NSManagedObjectContext?) {
        super.init(entity: entity, insertInto: context)
    }
    
    init(SelectedPin: Pin, urlString: String, context: NSManagedObjectContext) {
        let entity = NSEntityDescription.entity(forEntityName: "Photo", in: context)
        super.init(entity: entity!, insertInto: context)
        url = urlString
        pin = SelectedPin
    }
    
    init(photo: Data, context: NSManagedObjectContext) {
        let entity = NSEntityDescription.entity(forEntityName: "Photo", in: context)
        super.init(entity: entity!, insertInto: context)
        image = photo
    }
}
