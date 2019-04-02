//
//  YQL.swift
//  Atlas
//
//  Created by Benjamin Lefebvre on 7/30/15.
//  Copyright (c) 2015 Atlas. All rights reserved.
//

struct YQL {
    fileprivate static let prefix:NSString = "http://query.yahooapis.com/v1/public/yql?&format=json&env=store%3A%2F%2Fdatatables.org%2Falltableswithkeys&callback=&q="
    
    static func query(_ statement:String) -> NSDictionary? {
        let escapedStatement = statement.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)
        let query = "\(prefix)\(escapedStatement!)"
        
        var results:NSDictionary? = nil
        var jsonError:NSError? = nil
        
        let jsonData: Data?
        do {
            jsonData = try Data(contentsOf: URL(string: query)!, options: NSData.ReadingOptions.mappedIfSafe)
        } catch let error as NSError {
            jsonError = error
            jsonData = nil
        }
        
        if let jsonData = jsonData {
            do {
                results = try JSONSerialization.jsonObject(with: jsonData, options: JSONSerialization.ReadingOptions.allowFragments) as? NSDictionary
            } catch let error as NSError {
                log.error(error.localizedDescription)
            }
        }
        if let jsonError = jsonError {
            log.error("ERROR while fetching/deserializing YQL data. Message \(jsonError)")
        }
        return results
    }
}
