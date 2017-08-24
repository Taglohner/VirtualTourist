//
//  Photo+CoreDataClass.swift
//  VirtualTourist
//
//  Created by Steven Taglohner on 13/08/2017.
//  Copyright © 2017 Steven Taglohner. All rights reserved.
//

import Foundation

struct FlickrURL {
    
    static let Scheme = "https"
    static let Host = "api.flickr.com"
    static let Path = "/services/rest"
    
    struct FlickrParameterKeys {
        static let Method = "method"
        static let APIKey = "api_key"
        static let Latitude = "lat"
        static let Longitude = "lon"
        static let Extras = "extras"
        static let ResponseFormat = "format"
        static let NoJSONCallback = "nojsoncallback"
        static let PerPage = "per_page"
        static let Page = "page"
    }
    
    struct FlickrParameterValues {
        static let Method = "flickr.photos.search"
        static let APIKey = "092703722ed2f78a0c7393b5c833110e"
        static let Latitude = ""
        static let Longitude = ""
        static let Extras = "url_m"
        static let ResponseFormat = "json"
        static let NoJSONCallback = "1"
        static let PerPage = "500"
        static let Page = "1"
    }
}
