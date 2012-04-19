//
//  UIView+XTUtils.h
//  TKAppearance
//
//  Created by Taras Kalapun
//

#import <UIKit/UIKit.h>

@interface UIView (XTUtils)

//Class methods

+ (void)inspectView:(UIView *)aView level:(NSString *)level;
- (void)inspectSubviews;

//Instance methods

- (UIImage *)convertToImage;


@end
