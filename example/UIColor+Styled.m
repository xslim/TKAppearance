//
//  UIColor+Styled.m
//  TKAppearance
//
//  Created by Taras Kalapun
//

#import "UIColor+Styled.h"

#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

@implementation UIColor (Styled)

+ (UIColor *)styledBorderColor {
    return UIColorFromRGB(0x29562a);
}

+ (UIColor *)styledShadowColor {
    return UIColorFromRGB(0x276c3a);
}

+ (UIColor *)styledButtonTintColor {
    return UIColorFromRGB(0x70b434);
}

+ (UIColor *)styledTintStartColor {
    return UIColorFromRGB(0xBAD137);
}

+ (UIColor *)styledTintEndColor {
    return  UIColorFromRGB(0x3AAC49);
}

+ (UIColor *)styledSelectedTintStartColor {
    return UIColorFromRGB(0x276C3A);
}

+ (UIColor *)styledSelectedTintEndColor {
    return  [UIColor styledTintEndColor];
}

@end
