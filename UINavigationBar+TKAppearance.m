//
//  UINavigationBar+TKAppearance.m
//
//  Created by Taras Kalapun on 4/11/12.
//

#import "UINavigationBar+TKAppearance.h"

@implementation UINavigationBar (TKAppearance)

+ (NSDictionary *)proxiedAppearanceMethods {
    
    NSDictionary *d1 = @{
    @"encoding" : @"v@:@i",
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
    
    NSDictionary *d2 = @{
    @"encoding" : @"v@:@",
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
    
    //[[UINavigationBar appearance] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
    //[UIFont fontWithName:@"KPNSans-Bold" size:21.0], UITextAttributeFont,
    //nil]];
    
    
    return @{
    @"setBackgroundImage:forBarMetrics:" : d1
    //@"setTitleTextAttributes", d2
    };
}

@end
