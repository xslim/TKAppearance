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
    @"hookClass" : @"UINavigationItemView",
    @"hookSel" : @"drawText:inRect:barStyle:", //iOS 4.3, if 4.0 - drawText:inRect:
    @"hookCheck" : @{
        @"superviewIs" : @"UINavigationBar",
        @"classNotIn" : @[ @"UINavigationItemButtonView" ]
    },
    @"hookBlockInstead" : ^(id _self, NSInvocation *origInv, va_list args) {
        NSDictionary *textAttributes = nil;
        [origInv getArgument:&textAttributes atIndex:2];//start with 2
        
        UIFont *font = [textAttributes objectForKey:UITextAttributeFont];
        if (!font) font = [UIFont boldSystemFontOfSize:20.f];
        
        UIColor *color = [textAttributes objectForKey:UITextAttributeTextColor];
        if (!color) color = [UIColor whiteColor];
        
        UIColor *shadowColor = [textAttributes objectForKey:UITextAttributeTextShadowColor];
        if (!shadowColor) shadowColor = [UIColor whiteColor];
        
        CGFloat sizeOffset = [[textAttributes objectForKey:@"sizeOffset"] floatValue];
        
        NSString *string = va_arg(args, NSString*);
        CGRect rect = va_arg(args, CGRect);
        
        rect.size.width += sizeOffset * 2;
        rect.origin.x -= sizeOffset;
        
        // Draw shadow of string   
        if (shadowColor) {
            [shadowColor set];
            rect.origin.y -= 1;
            [string drawInRect:rect withFont:font lineBreakMode:UILineBreakModeTailTruncation alignment:UITextAlignmentCenter];
            rect.origin.y += 1;
        }
        
        // Draw string
        [color set];
        [string drawInRect:rect withFont:font lineBreakMode:UILineBreakModeTailTruncation alignment:UITextAlignmentCenter];
        
    }
    };
    
    //[[UINavigationBar appearance] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
    //[UIFont fontWithName:@"KPNSans-Bold" size:21.0], UITextAttributeFont,
    //nil]];
    
    
    return @{
    @"setBackgroundImage:forBarMetrics:" : d1,
    @"setTitleTextAttributes:" : d2
    };
}

@end
