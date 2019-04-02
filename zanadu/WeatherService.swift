//
//  WeatherService.swift
//  Atlas
//
//  Created by Benjamin Lefebvre on 8/1/15.
//  Copyright (c) 2015 Atlas. All rights reserved.
//

import Alamofire
import SwiftyJSON

/**
WeatherService

Provide Weather + PM2.5 informations
*/
class WeatherService {
    
    //MARK: - Properties
    static let mcode = Config.App.BundleId
    static let serviceBaseUrl = "http://api.map.baidu.com/telematics/v3/weather"
    
    //MARK: - Outlets
    
    //MARK: - Initializers
    
    //MARK: - Actions
    
    //MARK: - Methods
    static func weatherDataForCorrentLocation(_ completion: @escaping (WeatherData?, Error?) -> ()) {
        //            var urlA = "http://api.map.baidu.com/telematics/v3/weather?location=\(locationService.locationInfo.longitude),\(locationService.locationInfo.latitude)&output=json&ak=\(ak)&mcode=\(mcode)"
        
        let params = [
            "location": "\(Location.shared.coordinate.longitude),\(Location.shared.coordinate.latitude)",
            "output": "json",
            "ak": Config.Baidu.Key,
            "mcode": mcode
        ]

        Alamofire.request( serviceBaseUrl, parameters: params).responseJSON { (response) -> Void in
            switch response.result {
            case .failure(let error):
                log.error("\(error)")
                completion(nil, error)
            case .success(let value):
                let json = JSON(value)
                var currentTemp = json["results"][0]["weather_data"][0]["date"].stringValue
                
                var splitted = currentTemp.components(separatedBy: "：")
                currentTemp = splitted[splitted.count - 1]
                if currentTemp.contains("℃") {
                    currentTemp = currentTemp.substring(to: currentTemp.index(currentTemp.endIndex, offsetBy: -2))
                }
                let weatherData = WeatherData(
                    city: json["results"][0]["currentCity"].stringValue,
                    date: json["date"].stringValue,
                    currentTemperature: "\(currentTemp)°",
                    temperatureRange: json["results"][0]["weather_data"][0]["temperature"].stringValue,
                    weatherType: WeatherData.weatherTypeFromWeatherState(json["results"][0]["weather_data"][0]["weather"].stringValue),
                    pm25Value: json["results"][0]["pm25"].stringValue)
                completion(weatherData, nil)
            }
        }
    }
}
