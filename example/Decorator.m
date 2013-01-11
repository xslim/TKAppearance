//
//  Decorator.m
//  TKAppearance
//
//  Created by Taras Kalapun
//

#include <objc/runtime.h>  
#include <objc/message.h>
#import <QuartzCore/QuartzCore.h>

#import "Decorator.h"
#import "UIView+XTUtils.h"
#import "UIView+XTLinearGradientBackground.h"

#import "UIColor+Styled.h"
#import "TKAppearance.h"

@implementation Decorator

+ (void)load {
#ifdef UI_APPEARANCE_SELECTOR
    
    [[UINavigationBar appearance] setTintColor:[UIColor styledButtonTintColor]];
    
    UIImage *bgImg = nil;
    bgImg = [Decorator backgroundImageForNavigationBarWithSize:CGSizeMake(320.f, 44.f)];
    [[UINavigationBar appearance] setBackgroundImage:bgImg forBarMetrics:UIBarMetricsDefault];
    
    [[UINavigationBar appearance] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                                          [UIFont italicSystemFontOfSize], TKTextAttributeFont,
                                                          [NSNumber numberWithFloat:70.f], @"sizeOffset",
                                                          [UIColor styledShadowColor], TKTextAttributeTextShadowColor,
                                                          nil]];
    
    bgImg = [Decorator backgroundImageForTabBarWithSize:CGSizeMake(320.f, 50.f)];
    [[UITabBar appearance] setBackgroundImage:bgImg];
    
    CGFloat w = 320.f / self.tabBarController.viewControllers.count -4;
    bgImg = [Decorator backgroundImageForSelectedTabBarItemWithSize:CGSizeMake(w, 48.f)];
    [[UITabBar appearance] setSelectionIndicatorImage:bgImg];
    
    bgImg = [Decorator imageWithSize:CGSizeMake(320.f, 44.f) gradientStart:[UIColor styledTintEndColor] end:[UIColor styledSelectedTintStartColor]];
    [[UISearchBar appearance] setBackgroundImage:bgImg];
    
    [[UISwitch appearance] setOnTintColor:[UIColor styledButtonTintColor]];
    
#endif
}

#pragma mark - Decorating

+ (UIImage *)imageWithSize:(CGSize)size gradientStart:(UIColor *)color1 end:(UIColor *)color2 {
    CGRect frame = CGRectZero;
    frame.size = size;
    UIView *v = [[[UIView alloc] initWithFrame:frame] autorelease];
    [v setBackgroundVerticalLinearGradientFrom:color1 to:color2];
    return [v convertToImage];
}

+ (UIImage *)backgroundImageForNavigationBarWithSize:(CGSize)size {
    CGRect frame = CGRectZero;
    frame.size = size;
    UIView *v = [[[UIView alloc] initWithFrame:frame] autorelease];
    [v setBackgroundVerticalLinearGradientFrom:[UIColor styledTintStartColor] to:[UIColor styledTintEndColor]];
    [v addBottomBorderWithColor:[UIColor styledBorderColor]];
    return [v convertToImage];
}

+ (UIImage *)backgroundImageForTabBarWithSize:(CGSize)size {
    CGRect frame = CGRectZero;
    frame.size = size;
    UIView *v = [[[UIView alloc] initWithFrame:frame] autorelease];
    [v setBackgroundVerticalLinearGradientFrom:[UIColor styledTintStartColor] to:[UIColor styledTintEndColor]];
    [v addTopBorderWithColor:[UIColor styledBorderColor]];
    return [v convertToImage];
}

+ (UIImage *)backgroundImageForButtonOfSize:(CGSize)size {
    CGRect frame = CGRectZero;
    frame.size = size;
    UIView *v = [[[UIView alloc] initWithFrame:frame] autorelease];
    v.layer.cornerRadius = 5.f;
    v.clipsToBounds = YES;
    v.opaque = NO;
    [v setBackgroundVerticalLinearGradientFrom:[UIColor styledTintStartColor] to:[UIColor styledSelectedTintEndColor]];
    v.layer.borderColor = [UIColor styledBorderColor].CGColor;
    v.layer.borderWidth = 1.0f;
    v.layer.cornerRadius = 5.0f;
    
    return [v convertToImage];
}

+ (UIImage *)backgroundImageForSelectedTabBarItemWithSize:(CGSize)size {
    CGRect frame = CGRectZero;
    frame.size = size;
    UIView *v = [[[UIView alloc] initWithFrame:frame] autorelease];
    v.layer.cornerRadius = 5.f;
    v.clipsToBounds = YES;
    v.opaque = NO;
    [v setBackgroundVerticalLinearGradientFrom:[UIColor styledSelectedTintStartColor] to:[UIColor styledSelectedTintEndColor]];
    return [v convertToImage];
}

@end
