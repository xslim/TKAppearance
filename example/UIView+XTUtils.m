//
//  UIView+XTUtils.m
//  TKAppearance
//
//  Created by Taras Kalapun
//

#import "UIView+XTUtils.h"
#import <QuartzCore/QuartzCore.h>

@implementation UIView (XTUtils)


+ (void)inspectView:(UIView *)aView level:(NSString *)level 
{
	NSLog(@"Level:%@", level);
	NSLog(@"View:%@", aView);    
    
	NSArray *arr = [aView subviews];
	for (int i=0;i<[arr count];i++) {
		[[self class] inspectView:[arr objectAtIndex:i]
                            level:[NSString stringWithFormat:@"%@/%d", level, i]];
	}
}

- (void)inspectSubviews {
    [[self class] inspectView:self level:@""];
}

- (UIImage *)convertToImage {
    UIGraphicsBeginImageContextWithOptions(self.bounds.size, self.opaque, 0.0);
    [self.layer renderInContext:UIGraphicsGetCurrentContext()];    
    UIImage * img = UIGraphicsGetImageFromCurrentImageContext();    
    UIGraphicsEndImageContext();    
    return img;
}


@end
