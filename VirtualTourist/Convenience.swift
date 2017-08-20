//
//  Convenience.swift
//  VirtualTourist
//
//  Created by Steven Taglohner on 19/08/2017.
//  Copyright © 2017 Steven Taglohner. All rights reserved.
//

import Foundation
import CoreData

extension RequestFlickrData {
    
    func getPhotosJSONFromFlickr(pin: Pin) {
        
        let latitude = String(pin.latitude)
        let longitude = String(pin.longitude)
        
        RequestFlickrData.sharedInstance().getDataWith(latitude, longitude) { (result) in
            switch result {
                
            case .Success(let data):
                self.createPhotoEntityFrom(data, pin)
            case .Error(let message):
                DispatchQueue.main.async {
                    print(message)
                }
            }
        }
    }
    
    func createPhotoEntityFrom(_ data: [[String : AnyObject]],_ pin: Pin) {
        _ = data.map() {(dictionary: [String: AnyObject]) -> Photo in
            let photo = Photo(dictionary: dictionary, context: AppDelegate.stack.context)
            photo.pin = pin
            if let url = photo.url {
                imageDataFrom(url) {(result) in
                    switch result {
                        
                    case .Success(let data):
                        photo.image = data
                        AppDelegate.stack.save()
                    case .Error(let message):
                        DispatchQueue.main.async {
                            print(message)
                        }
                    }
                }
            }
            return photo
        }
    }
}
