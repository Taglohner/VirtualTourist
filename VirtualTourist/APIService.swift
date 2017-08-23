//
//  Photo+CoreDataClass.swift
//  VirtualTourist
//
//  Created by Steven Taglohner on 13/08/2017.
//  Copyright © 2017 Steven Taglohner. All rights reserved.
//

import Foundation

class RequestFlickrData {
    
    let session = URLSession.shared
    
    func getNumberOfPages(url: URL, completion: @escaping (Result<Int>) -> Void) {
        
        session.dataTask(with: url) { (data, response, error) in
            guard error == nil else {
                return completion(.Error(error!.localizedDescription))
            }
            guard let data = data else {
                return completion(.Error(error?.localizedDescription ?? "There are no new Items to show"))
            }
            do {
                if let json = try JSONSerialization.jsonObject(with: data, options: [.mutableContainers]) as? [String: AnyObject] {
                    guard let photos = json["photos"] as? [String: AnyObject] else {
                        return completion(.Error(error?.localizedDescription ?? "There are no new Items to show."))
                    }
                    guard let photoArray = photos["pages"] as? Int else {
                        return completion(.Error(error?.localizedDescription ?? "Could not get the number of pages."))
                    }
                    DispatchQueue.main.async {
                        completion(.Success(photoArray))
                    }
                }
            } catch let error {
                return completion(.Error(error.localizedDescription))
            }
            }.resume()
    }
    
    
    func getDataWith(_ latitude: String,_ longitude: String, completion: @escaping (Result<[[String: AnyObject]]>) -> Void) {
        
        var numberOfPages = 0
        
        var parameters = [
            FlickrURL.FlickrParameterKeys.Method         : FlickrURL.FlickrParameterValues.Method,
            FlickrURL.FlickrParameterKeys.APIKey         : FlickrURL.FlickrParameterValues.APIKey,
            FlickrURL.FlickrParameterKeys.Latitude       : latitude,
            FlickrURL.FlickrParameterKeys.Longitude      : longitude,
            FlickrURL.FlickrParameterKeys.Extras         : FlickrURL.FlickrParameterValues.Extras,
            FlickrURL.FlickrParameterKeys.ResponseFormat : FlickrURL.FlickrParameterValues.ResponseFormat,
            FlickrURL.FlickrParameterKeys.NoJSONCallback : FlickrURL.FlickrParameterValues.NoJSONCallback,
            FlickrURL.FlickrParameterKeys.PerPage        : FlickrURL.FlickrParameterValues.PerPage,
    
            ] as [String : AnyObject]
        
        let url = self.URLFromParameters(parameters, FlickrURL.Scheme, FlickrURL.Host, FlickrURL.Path)

        
        getNumberOfPages(url: url) {(result) in
            switch result {
                
            case .Success(let pages):
                numberOfPages = pages
                print(numberOfPages)
            case .Error(let message):
                DispatchQueue.main.async {
                    print(message)
                }
            }
        
        let page = arc4random_uniform(UInt32(numberOfPages) + 1)
        parameters[FlickrURL.FlickrParameterKeys.Page] = page as AnyObject
        
        let url2 = self.URLFromParameters(parameters, FlickrURL.Scheme, FlickrURL.Host, FlickrURL.Path)
        print(url2)
        
        self.session.dataTask(with: url2) { (data, response, error) in
            guard error == nil else {
                return completion(.Error(error!.localizedDescription))
            }
            
            guard let data = data else {
                return completion(.Error(error?.localizedDescription ?? "There are no new Items to show"))
            }
            do {
                if let json = try JSONSerialization.jsonObject(with: data, options: [.mutableContainers]) as? [String: AnyObject] {
                    guard let photos = json["photos"] as? [String: AnyObject] else {
                        return completion(.Error(error?.localizedDescription ?? "There are no new Items to show."))
                    }
                    guard let photoArray = photos["photo"] as? [[String: AnyObject]] else {
                        return completion(.Error(error?.localizedDescription ?? "There are no new Items to show."))
                    }
                    DispatchQueue.main.async {
                        completion(.Success(photoArray))
                    }
                }
            } catch let error {
                return completion(.Error(error.localizedDescription))
            }
            }.resume()
        }
    }
    

    
    func imageDataFrom(_ stringURL: String, completion: @escaping (Result<Data>) -> Void) {

        guard let url = NSURL(string: stringURL) else {
            return completion(.Error("Provided URL is invalid"))
        }
        let request = NSURLRequest(url: url as URL)
        session.dataTask(with: request as URLRequest) { (data, response, error) in
            
            guard error == nil else {
                return completion(.Error(error?.localizedDescription ?? "Could not get the image data."))
            }
            
            guard let data = data else {
                return completion(.Error(error?.localizedDescription ?? "Invalid image data."))
            }
            
            DispatchQueue.main.async {
                completion(.Success(data))
            }
        }.resume()
    }

    
    enum Result <T> {
        case Success(T)
        case Error(String)
    }
}


extension RequestFlickrData {
    
    /* create a URL from parameters */
    func URLFromParameters(_ parameters: [String:AnyObject]?,_ scheme: String,_ host: String,_ path: String) -> URL {
        
        var components = URLComponents()
        components.scheme = scheme
        components.host = host
        components.path = path
        components.queryItems = [URLQueryItem]()
        
        if let parameters = parameters {
            for (key, value) in parameters {
                let queryItem = URLQueryItem(name: key, value: "\(value)")
                components.queryItems!.append(queryItem)
            }
        }
        return components.url!
    }
    
    class func sharedInstance() -> RequestFlickrData {
        struct Singleton {
            static var sharedInstance = RequestFlickrData()
        }
        return Singleton.sharedInstance
    }
}
