//
//  SizeClass.swift
//  Atlas
//
//  Created by Benjamin Lefebvre on 7/16/15.
//  Copyright (c) 2015 Atlas. All rights reserved.
//

/**
Size Class provider

Initialize it once and then quickly get the size class from everywhere (Useful when size class constraints doesn't work on Interface Builder and you have to code it)

FYI:

    typedef NS_ENUM (NSInteger, UIUserInterfaceSizeClass {
        UIUserInterfaceSizeClassUnspecified = 0,
        UIUserInterfaceSizeClassCompact     = 1,
        UIUserInterfaceSizeClassRegular     = 2,
    };

*/
class SizeClass {
    
    //MARK: - Properties
    
    static let horizontalClass = UIApplication.shared.keyWindow!.traitCollection.horizontalSizeClass
    static let verticalClass = UIApplication.shared.keyWindow!.traitCollection.verticalSizeClass
    
}

