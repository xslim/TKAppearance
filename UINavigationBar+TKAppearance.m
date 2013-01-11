//
//  UINavigationBar+TKAppearance.m
//  TKAppearance
//
//  Created by Taras Kalapun
//

#import "UINavigationBar+TKAppearance.h"
#import "TKAppearance.h"
@implementation UINavigationBar (TKAppearance)

+ (NSDictionary *)proxiedAppearanceMethodsContainedIn:(NSArray*) containedIn{
    
    BOOL (^popoverBlock)(id _self) = [[^(UIView* _self){
        return [_self.superview.superview.superview isKindOfClass:NSClassFromString(@"UIPopoverView")];
    } copy] autorelease];
    
    BOOL (^drawRectCheckBlock)(id _self) = nil;
    if([containedIn containsObject:[UIPopoverController class]])
        drawRectCheckBlock = popoverBlock;
    
    NSDictionary *d1 = [NSDictionary dictionaryWithObjectsAndKeys:
                        @"v@:@i", @"encoding",
                        [NSNumber numberWithBool:NO], @"addImp",
                        //^(id _self, UIImage *image, int metrics) { }, @"imp",
                        @"drawRect:", @"hookSel",
                        ^(id _self, NSArray *origArgs, va_list args) {
                            UIImage *image = [origArgs objectAtIndex:0];
                            if(image != [NSNull null]){
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
                        }, @"hookBlockAfter",
                        ^(id _self, IMP origImp, va_list args) {
                            SEL sel = NSSelectorFromString(@"drawRect:");
                            CGRect rect = va_arg(args, CGRect);
                            origImp(_self, sel, rect);
                        }, @"origBlock",
                        [NSDictionary dictionaryWithObjectsAndKeys:
                         drawRectCheckBlock, @"checkBlock",
                         nil], @"hookChecks",

                        nil];
    
    NSDictionary *d2 = [NSDictionary dictionaryWithObjectsAndKeys:
                        @"v@:@", @"encoding",
                        [NSNumber numberWithBool:NO], @"addImp",
                        @"drawText:inRect:barStyle:", @"hookSel",
                        @"UINavigationItemView", @"hookClass",
                        ^(id _self, NSArray *origArgs, va_list args) {
                            NSDictionary *textAttributes = [origArgs objectAtIndex:0];
                            
                            UIFont *font = [textAttributes objectForKey:TKTextAttributeFont];
                            if (!font) font = [UIFont boldSystemFontOfSize:20.f];
                            
                            UIColor *color = [textAttributes objectForKey:TKTextAttributeTextColor];
                            if (!color) color = [UIColor whiteColor];
                            
                            UIColor *shadowColor = [textAttributes objectForKey:TKTextAttributeTextShadowColor];
                            if (!shadowColor) shadowColor = [UIColor whiteColor];
                            
                            CGFloat sizeOffset = [[textAttributes objectForKey:@"sizeOffset"] floatValue];
                            
                            CGPoint shadowOffset = [[textAttributes objectForKey:TKTextAttributeTextShadowOffset] CGPointValue];
                            
                            NSString *string = va_arg(args, NSString*);
                            CGRect rect = va_arg(args, CGRect);
                            
                            rect.origin.y += 1;
                            
                            rect.size.width += sizeOffset * 2;
                            rect.origin.x -= sizeOffset;
                            
                            // Draw shadow of string   
                            if (shadowColor) {
                                [shadowColor set];
                                rect.origin.y += shadowOffset.y;
                                rect.origin.x += shadowOffset.x;
                                [string drawInRect:rect withFont:font lineBreakMode:UILineBreakModeTailTruncation alignment:UITextAlignmentCenter];
                                rect.origin.y -= shadowOffset.y;
                                rect.origin.x -= shadowOffset.x;
                            }
                            
                            // Draw string
                            [color set];
                            [string drawInRect:rect withFont:font lineBreakMode:UILineBreakModeTailTruncation alignment:UITextAlignmentCenter];
                            
                        }, @"hookBlockInstead",
                        ^(id _self, IMP origImp, va_list args) {
                            SEL sel = NSSelectorFromString(@"drawText:inRect:barStyle:");
                            NSString *string = va_arg(args, NSString*);
                            CGRect rect = va_arg(args, CGRect);
                            int style = va_arg(args, int);
                            origImp(_self, sel, string, rect, style);
                        }, @"origBlock",
                        [NSDictionary dictionaryWithObjectsAndKeys:
                         @"UINavigationBar", @"superviewIs",
                         [NSArray arrayWithObject:@"UINavigationItemButtonView"], @"classNotIn",
                         nil], @"hookChecks",
                        nil];
    
    return [NSDictionary dictionaryWithObjectsAndKeys:
            d1, @"setBackgroundImage:forBarMetrics:",
            d2, @"setTitleTextAttributes:",
            nil];
}

@end
