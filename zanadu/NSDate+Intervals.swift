//
//  NSDate+Intervals.swift
//  Atlas
//
//  Created by Benjamin Lefebvre on 5/27/15.
//  Copyright (c) 2015 Atlas. All rights reserved.
//

extension Date {
    func yearsFrom(_ date:Date) -> Int {
        return (Calendar.current as NSCalendar).components(NSCalendar.Unit.year, from: date, to: self, options: NSCalendar.Options.matchStrictly).year!
    }
    func monthsFrom(_ date:Date) -> Int {
        return (Calendar.current as NSCalendar).components(NSCalendar.Unit.month, from: date, to: self, options: NSCalendar.Options.matchStrictly).month!
    }
    func weeksFrom(_ date:Date) -> Int {
        return (Calendar.current as NSCalendar).components(NSCalendar.Unit.weekOfYear, from: date, to: self, options: NSCalendar.Options.matchStrictly).weekOfYear!
    }
    func daysFrom(_ date:Date) -> Int {
        return (Calendar.current as NSCalendar).components(NSCalendar.Unit.day, from: date, to: self, options: NSCalendar.Options.matchStrictly).day!
    }
    func hoursFrom(_ date:Date) -> Int {
        return (Calendar.current as NSCalendar).components(NSCalendar.Unit.hour, from: date, to: self, options: NSCalendar.Options.matchStrictly).hour!
    }
    func minutesFrom(_ date:Date) -> Int {
        return (Calendar.current as NSCalendar).components(NSCalendar.Unit.minute, from: date, to: self, options: NSCalendar.Options.matchStrictly).minute!
    }
    func secondsFrom(_ date:Date) -> Int {
        return (Calendar.current as NSCalendar).components(NSCalendar.Unit.second, from: date, to: self, options: NSCalendar.Options.matchStrictly).second!
    }
    func offsetFrom(_ date:Date) -> String {
        if yearsFrom(date)   > 0 { return "\(yearsFrom(date))年前"   }
        if monthsFrom(date)  > 0 { return "\(monthsFrom(date))月前"  }
        if weeksFrom(date)   > 0 { return "\(weeksFrom(date))周前"   }
        if daysFrom(date)    > 0 { return "\(daysFrom(date))天前"    }
        if hoursFrom(date)   > 0 { return "\(hoursFrom(date))小时前"   }
        if minutesFrom(date) > 0 { return "\(minutesFrom(date))分钟前" }
        if secondsFrom(date) > 0 { return "\(secondsFrom(date))秒钟前" }
        return ""
    }
    
    func formatedElapsedTime() -> (String) {
        let differenceInSeconds = Int(Date().timeIntervalSince(self))
        let secondsPerHour = 3600
        let secondsPerDay = secondsPerHour * 24
        
        var time = 0
        var subTitle = String()
        
        if differenceInSeconds < secondsPerHour {
            time = differenceInSeconds / 60
            subTitle = "分钟前"
            if time < 1 {
                subTitle = "刚刚"
            }
        } else if differenceInSeconds >= secondsPerHour && differenceInSeconds < secondsPerDay {
            time = differenceInSeconds / secondsPerHour
            subTitle =  "小时前"
        } else {
            time = differenceInSeconds / secondsPerDay
            subTitle =  "天前"
        }
        
        if time < 1 {
            return subTitle
        }
        
        return String(time) + subTitle
    }
}
