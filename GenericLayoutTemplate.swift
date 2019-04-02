//
//  GenericLayoutConfig.swift
//  Atlas
//
//  Created by Benjamin Lefebvre on 7/22/15.
//  Copyright (c) 2015 Atlas. All rights reserved.
//



/**
    A template can have as many lines as you want, if there is more items to display than the number of lines, the GenericLayoutView will loop on the template definition.
*/
let LayoutTemplates: [GenericLayoutName: GenericLayoutTemplate] = [
    .default: [
        (.fullWidth, .oneRow),
    ],
    .halfWidthOneRow: [
        (.halfWidth, .oneRow),
    ],
    .halfWidthTwoRows: [
        (.halfWidth, .twoRows),
    ],
    .fullWidthOneRow: [
        (.fullWidth, .oneRow),
    ],
    .fullWidthTwoRows: [
        (.fullWidth, .twoRows),
    ],
//    .Section: [
//        (.HalfWidth, .OneRow),
//    ],
//    .Sections: [
//        (.FullWidth, .OneRow),
//    ]
]
