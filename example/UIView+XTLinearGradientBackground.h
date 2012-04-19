//
//  UIView+XTLinearGradientBackground.h
//  TKAppearance
//
//  Created by Taras Kalapun
//

#import <Foundation/Foundation.h>


@interface UIView (XTLinearGradientBackground)

- (void)setBackgroundVerticalLinearGradientFrom:(UIColor *)from to:(UIColor *)to;
- (void)setHorizontalAlphaGradient:(CGFloat)relativeHeight;

- (void)addBorderWithColor:(UIColor *)color width:(CGFloat)borderWidth inFrame:(CGRect)frame;
- (void)addBottomBorderWithColor:(UIColor *)color;
- (void)addTopBorderWithColor:(UIColor *)color;

@end
