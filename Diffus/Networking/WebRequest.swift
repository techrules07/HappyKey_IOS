//
//  WebRequest.swift
//  Diffus
//
//  Created by IRPL on 09/02/20.
//  Copyright © 2020 IRPL. All rights reserved.
//

import Foundation

class WebRequest {
    var BASE_URL = "https://preigoprojects.website/diffus1/public/api/"
    
    func WebRequest(endPoint: String, params: [String: Any], delegate: JSONListener, tag: String, bodyContent: Bool) {
        BASE_URL += endPoint
        
        
        print(params)
        guard var todosURL = URLComponents(string: BASE_URL) else {
            print("Error: cannot create URL")
            return
        }
        
        if (bodyContent) {
            var items = [URLQueryItem]()

                   for (key, value) in params {
                       items.append(URLQueryItem(name: key, value: value as! String))
                   }
                   todosURL.queryItems = items
        }
       
        
        var todosUrlRequest = URLRequest(url: (todosURL.url)!)
        todosUrlRequest.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")  // the request is JSON
        todosUrlRequest.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Accept")
        todosUrlRequest.httpMethod = "POST"
        
        let jsonData: Data
        
        do {
            jsonData = try JSONSerialization.data(withJSONObject: params, options: [])
            todosUrlRequest.httpBody = jsonData
            print(params)
            todosUrlRequest.allHTTPHeaderFields = params as! [String : String]
        }
            
        catch {
            let obj: NSDictionary = ["status" : "error", "code": 1001]
            delegate.APIResponse(obj, tag: tag)
            return
        }
        
        let session = URLSession.shared
        let task = session.dataTask(with: todosUrlRequest) {
            (data, response, error) in
            
            do {
                guard let data = data else {
                    let obj: NSDictionary = ["status" : "error", "code": 1000]
                    delegate.APIResponse(obj, tag: tag)
                    return
                }
                
                guard (try JSONSerialization.jsonObject(with: data, options: []) as? NSDictionary) != nil else {
                    let obj: NSDictionary = ["status" : "error", "code": 1003]
                    delegate.APIResponse(obj, tag: tag)
                    return
                }
                
                var js = try JSONSerialization.jsonObject(with: data, options: []) as? NSDictionary
                delegate.APIResponse(js!, tag: tag)
                
                
            } catch let error as JSONError {
                print(error.rawValue)
                let obj: NSDictionary = ["status" : "error", "code": 1001]
                delegate.APIResponse(obj, tag: tag)
            } catch let error as NSError {
                let obj: NSDictionary = ["status" : "error", "code": 1002]
                delegate.APIResponse(obj, tag: tag)
            }
        }
        
        task.resume()
    }
    
    enum JSONError: String, Error {
        case NoData = "ERROR: no data"
        case ConversionFailed = "ERROR: conversion from JSON failed"
    }
}


public protocol JSONListener {
    func APIResponse(_ result: NSDictionary, tag: String)
}
