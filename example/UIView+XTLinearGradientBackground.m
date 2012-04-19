//
//  UIView+XTLinearGradientBackground.m
//  TKAppearance
//
//  Created by Taras Kalapun
//

#import "UIView+XTLinearGradientBackground.h"
#import <QuartzCore/QuartzCore.h>

@implementation UIView (XTLinearGradientBackground)

- (void)setBackgroundVerticalLinearGradientFrom:(UIColor *)from to:(UIColor *)to {
    CAGradientLayer *gradient = [CAGradientLayer layer];
    gradient.frame = self.bounds;
    gradient.colors = [NSArray arrayWithObjects:(id)[from CGColor], (id)[to CGColor], nil];
    gradient.shouldRasterize = YES;
    [self.layer insertSublayer:gradient atIndex:0];
}


- (void)setHorizontalAlphaGradient:(CGFloat)relativeHeight{
    
    NSAssert((relativeHeight>0 && relativeHeight<1), @"Relative height of alpha gradient must be greater than 0 and lower than 1");
    
    NSArray *gradientColors = [NSArray arrayWithObjects:(id)[[UIColor colorWithWhite:0 alpha:0] CGColor], 
                                                        (id)[[UIColor colorWithWhite:0 alpha:1] CGColor], 
                                                        (id)[[UIColor colorWithWhite:0 alpha:1] CGColor], 
                                                        (id)[[UIColor colorWithWhite:0 alpha:0] CGColor], nil];
    
    NSArray *gradientLocations = [NSArray arrayWithObjects: [NSNumber numberWithFloat:0.0],
                                                            [NSNumber numberWithFloat:relativeHeight],
                                                            [NSNumber numberWithFloat:1-relativeHeight],
                                                            [NSNumber numberWithFloat:1.0], nil];
    
	//Create the main mask
	CAGradientLayer *maskLayer = [[CAGradientLayer alloc] init];
	[maskLayer setFrame:self.bounds];
    [maskLayer setStartPoint:CGPointMake(0, 0)];
    [maskLayer setEndPoint:CGPointMake(0, 1)];
    [maskLayer setColors:gradientColors];
    [maskLayer setLocations:gradientLocations];
                                      
	//Add the mask to the view
	[[self layer] setMask:maskLayer];
    [[self layer] setMasksToBounds:YES];
    
    //Release
	[maskLayer release];
}

- (void)addBorderWithColor:(UIColor *)color width:(CGFloat)borderWidth inFrame:(CGRect)frame {
    frame.size.height = borderWidth;
    
    CALayer *border = [CALayer layer];
    border.borderColor = color.CGColor;
    border.borderWidth = borderWidth;
    border.frame = frame;
    
    [self.layer addSublayer:border];
}

- (void)addBottomBorderWithColor:(UIColor *)color {
    CGFloat borderWidth = 1.f;
    CGRect frame = self.bounds;
    frame.origin.y = self.bounds.size.height - borderWidth;
    [self addBorderWithColor:color width:borderWidth inFrame:frame];
}

- (void)addTopBorderWithColor:(UIColor *)color {
    CGFloat borderWidth = 1.f;
    CGRect frame = self.bounds;
    [self addBorderWithColor:color width:borderWidth inFrame:frame];
}

@end
