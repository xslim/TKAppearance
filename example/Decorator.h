//
//  Decorator.h
//  TKAppearance
//
//  Created by Taras Kalapun
//

#import <Foundation/Foundation.h>
#import "UINavigationBar+XTCustom.h"

@interface Decorator : NSObject <UINavigationBarXTDecoratorProtocol>

+ (UIImage *)backgroundImageForButtonOfSize:(CGSize)size;
+ (UIImage *)imageWithSize:(CGSize)size gradientStart:(UIColor *)color1 end:(UIColor *)color2;
+ (UIImage *)backgroundImageForNavigationBarWithSize:(CGSize)size;
+ (UIImage *)backgroundImageForTabBarWithSize:(CGSize)size;
+ (UIImage *)backgroundImageForSelectedTabBarItemWithSize:(CGSize)size;

@end
