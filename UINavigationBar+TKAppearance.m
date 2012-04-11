//
//  UINavigationBar+TKAppearance.m
//  KPN-Hotspots
//
//  Created by Taras Kalapun on 4/11/12.
//  Copyright (c) 2012 Xaton. All rights reserved.
//

#import "UINavigationBar+TKAppearance.h"

@implementation UINavigationBar (TKAppearance)

+ (NSDictionary *)proxiedAppearanceMethods {
    
    NSDictionary *d = @{
    @"encoding" : @"v16@0:4@8i12",
    @"addImp" : [NSNumber numberWithBool:NO],
    //@"imp" : ^(id _self, UIImage *image, int metrics) { },
    @"hookSel" : @"drawRect:",
    @"hookBlockAfter" : ^(id _self, NSInvocation *origInv, va_list args) {
        UIImage *image = nil;
        [origInv getArgument:&image atIndex:2];//start with 2
        
        CGRect rect = va_arg(args, CGRect);
        
        [image drawInRect:rect];
    }
    };
    
    return @{ @"setBackgroundImage:forBarMetrics:" : d };
}

@end
