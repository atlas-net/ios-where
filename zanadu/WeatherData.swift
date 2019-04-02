//
//  WeatherData.swift
//  Atlas
//
//  Created by Benjamin Lefebvre on 8/1/15.
//  Copyright (c) 2015 Atlas. All rights reserved.
//

enum WeatherType: String {
    case Unknown = ""
    case Sunny = "Sunny"
    case Cloudy = "Cloudy"
    case Rainy = "ModerateRain"
    case Snowy = "Snow"
    case Foggy = "Haze"
}

let AirQualityIndexTitles = [
    "优",
    "良",
    "轻度污染",
    "中度污染",
    "重度污染",
    "严重污染"
]


/**
WeatherData

Holds weather data
*/
struct WeatherData {
    
    let defaultValue = "- -"
    
    //MARK: - Properties
    var city: String
    var date: String
    var currentTemperature: String
    var temperatureRange: String
    var weatherType: WeatherType
    var weatherIcon: UIImage
    var pm25Value: String
    var pm25Index: String
    
    
    //MARK: - Initializers
    init(city: String, date: String, currentTemperature: String, temperatureRange: String, weatherType: WeatherType,  pm25Value: String) {
        self.city = city
        self.date = date
        self.currentTemperature = currentTemperature != "" ? currentTemperature : defaultValue
        self.temperatureRange = temperatureRange != "" ? currentTemperature : defaultValue
        self.weatherType = weatherType
        self.pm25Value = pm25Value
        if let pm25Value = Int(pm25Value) {
            self.pm25Index = WeatherData.indexFromPM25Value(pm25Value)
        } else {
            self.pm25Index = defaultValue
            self.pm25Value = defaultValue
        }
        
        
        if weatherType != .Unknown {
            self.weatherIcon = UIImage(named: "Weather_\(weatherType.rawValue)")!
        }
        else {
            self.weatherIcon = UIImage()
        }
    }
    
    //MARK: - Methods
    
    static func indexFromPM25Value(_ value: Int) -> String {
        var i = value/50
        if i >= AirQualityIndexTitles.count {
            i = AirQualityIndexTitles.count - 1
        }
        return AirQualityIndexTitles[i]
    }
    
    static func weatherTypeFromWeatherState(_ state: String) -> WeatherType {
        switch state {
        case "晴":
            return WeatherType.Sunny
        case "多云","多云转晴":
            return WeatherType.Cloudy
        case "小雨", "中雨", "大雨","暴雨","大暴雨","特大暴雨","冻雨","阵雨","雷阵雨","雨夹雪","雷阵雨伴冰雹","小到中雨","阵雨转小雨","小雨转阴":
            return WeatherType.Rainy
        case "小雪","中雪","大雪","暴雪'","阵雪","雾":
            return WeatherType.Snowy
        case "霾","沙尘暴","扬沙","浮尘":
            return WeatherType.Foggy
        default:
            return WeatherType.Unknown
        }
    }

}
