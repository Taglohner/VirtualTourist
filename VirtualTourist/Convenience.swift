//
//  Convenience.swift
//  VirtualTourist
//
//  Created by Steven Taglohner on 24/08/2017.
//  Copyright © 2017 Steven Taglohner. All rights reserved.
//

import Foundation

extension RequestFlickrData {
    
    func loadPhotoCollectionFromFlickr(selectePin: Pin, completion: @escaping (Int) -> Void) {
        
        var counter = Int()
        
        RequestFlickrData.sharedInstance().getDataWith(pin: selectePin){ (result) in
            
            switch result {
            case .Success(let data):
                
                for url in data {
                    let photo = Photo(SelectedPin: selectePin, urlString: url, context: AppDelegate.stack.context)
                    
                    RequestFlickrData.sharedInstance().imageDataFrom(url) {(result) in
                        
                        switch result {
                        case .Success(let data):
                            
                            DispatchQueue.main.async {
                                photo.image = data
                                AppDelegate.stack.save()
                                completion(counter)
                            }
                            counter += 1
                            
                        case .Error(let message):
                            print(message)
                        }
                    }
                }
                
            case .Error(let message):
                print(message)
            }
        }
    }
 
}
