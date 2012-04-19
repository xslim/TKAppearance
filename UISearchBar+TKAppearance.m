//
//  UISearchBar+TKAppearance.m
//  TKAppearance
//
//  Created by Taras Kalapun
//

#import "UISearchBar+TKAppearance.h"

@implementation UISearchBar (TKAppearance)

+ (NSDictionary *)proxiedAppearanceMethods {
    
    NSDictionary *d1 = [NSDictionary dictionaryWithObjectsAndKeys:
                        @"v@:@", @"encoding",
                        [NSNumber numberWithBool:NO], @"addImp",
                        @"drawRect:", @"hookSel",
                        ^(id _self, NSArray *origArgs, va_list args) {
                            UIImage *image = [origArgs objectAtIndex:0];
                            CGRect rect = va_arg(args, CGRect);
                            [image drawInRect:rect];
                        }, @"hookBlockAfter",
                        ^(id _self, IMP origImp, va_list args) {
                            SEL sel = NSSelectorFromString(@"drawRect:");
                            CGRect rect = va_arg(args, CGRect);
                            origImp(_self, sel, rect);
                        }, @"origBlock",
                        nil];
    
    return [NSDictionary dictionaryWithObjectsAndKeys:
            d1, @"setBackgroundImage:",
            nil];
}


@end
