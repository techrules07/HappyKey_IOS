//
//  WebService.swift
//  Diffus
//
//  Created by IRPL on 21/02/20.
//  Copyright © 2020 IRPL. All rights reserved.
//

import UIKit

class WebService {
    var result: NSDictionary? = nil
    
    func WebService(_ url: String, delegate: TaskListener, tag: String){
        var _: UIActivityIndicatorView? = nil
        var js: NSDictionary?
       print(url)
        guard let endpoint = URL(string: url) else {
            print("Error creating endpoint")
            let obj: NSDictionary = ["status" : "error"]
            delegate.webResponse(obj, tag: tag)
            return
        }
        let request = URLRequest(url: endpoint)
        
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            do {
                guard let data = data else {
                    let obj: NSDictionary = ["status" : "error", "code": 1000]
                    delegate.webResponse(obj, tag: tag)
                    return
                }
                guard (try JSONSerialization.jsonObject(with: data, options: []) as? NSDictionary) != nil else {
                    let obj: NSDictionary = ["status" : "error", "code": 1000]
                    delegate.webResponse(obj, tag: tag)
                    return
                }
                
                js = try JSONSerialization.jsonObject(with: data, options: []) as? NSDictionary
                delegate.webResponse(js!, tag: tag)
                
                
            } catch let error as JSONError {
                print(error.rawValue)
                let obj: NSDictionary = ["status" : "error", "code": 1001]
                delegate.webResponse(obj, tag: tag)
            } catch let error as NSError {
                print(error.debugDescription)
                let obj: NSDictionary = ["status" : "error", "code": 1001]
                delegate.webResponse(obj, tag: tag)
            }
            }.resume()
    }
    
    enum JSONError: String, Error {
        case NoData = "ERROR: no data"
        case ConversionFailed = "ERROR: conversion from JSON failed"
    }
}

public protocol TaskListener : class{
    func webResponse(_ result: NSDictionary, tag: String)
}

