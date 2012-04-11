//
//  UITabBar+TKAppearance.m
//  KPN-Hotspots
//
//  Created by Taras Kalapun on 4/11/12.
//  Copyright (c) 2012 Xaton. All rights reserved.
//

#import "UITabBar+TKAppearance.h"

@implementation UITabBar (TKAppearance)

+ (NSDictionary *)proxiedAppearanceMethods {
    
    NSDictionary *d1 = @{
    @"encoding" : @"v@:@",
    @"addImp" : [NSNumber numberWithBool:NO],
    @"hookSel" : @"drawRect:",
    @"hookBlockAfter" : ^(id _self, NSInvocation *origInv, va_list args) {
        UIImage *image = nil;
        [origInv getArgument:&image atIndex:2];//start with 2
        CGRect rect = va_arg(args, CGRect);
        [image drawInRect:rect];
    }
    };
    
    NSDictionary *d2 = @{
    @"encoding" : @"v@:@",
    @"addImp" : [NSNumber numberWithBool:NO],
    @"hookClass" : @"UITabBarSelectionIndicatorView",
    @"hookSel" : @"drawRect:",
    @"hookBlockInstead" : ^(id _self, NSInvocation *origInv, va_list args) {
        UIImage *image = nil;
        [origInv getArgument:&image atIndex:2];//start with 2
        CGRect rect = va_arg(args, CGRect);
        [image drawInRect:rect];
    }
    };
    
    return @{
    @"setBackgroundImage:" : d1,
    @"setSelectionIndicatorImage:" : d2
    };
}

@end
