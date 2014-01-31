//
//  Color.m
//  twitter
//
//  Created by Adam Tait on 1/29/14.
//  Copyright (c) 2014 Adam Tait. All rights reserved.
//

#import "Color.h"

@implementation Color

+ (UIColor *)twitterBlue
{
    return [UIColor colorWithRed:64.0/255.0 green:153.0/255.0 blue:255.0/255.0 alpha:1];
}

+ (UIColor *)fontWhite
{
    return [UIColor whiteColor];
}

+ (UIColor *)fontBlack
{
    return [UIColor blackColor];
}

+ (UIColor *)fontGray
{
    return [UIColor colorWithRed:179.0/255.0 green:179.0/255.0 blue:177.0/255.0 alpha:1];
}

@end
