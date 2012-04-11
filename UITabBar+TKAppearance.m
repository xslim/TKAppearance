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
    //@"imp" : ^(id _self, UIImage *image, int metrics) { },
    @"hookSel" : @"drawRect:",
    @"hookBlockAfter" : ^(id _self, NSInvocation *origInv, va_list args) {
        UIImage *image = nil;
        [origInv getArgument:&image atIndex:2];//start with 2
        
        CGRect rect = va_arg(args, CGRect);
        
        /*
         // Tiled
         CGSize imageViewSize = imageView.bounds.size;
         UIGraphicsBeginImageContext(imageViewSize);
         CGContextRef imageContext = UIGraphicsGetCurrentContext();
         CGContextDrawTiledImage(imageContext, (CGRect){ CGPointZero, imageViewSize }, tileImage);
         UIImage *finishedImage = UIGraphicsGetImageFromCurrentImageContext();
         UIGraphicsEndImageContext();
         */
        
        
        [image drawInRect:rect];
    }
    };
    
    return @{
    @"setBackgroundImage:" : d1
    };
}

@end
