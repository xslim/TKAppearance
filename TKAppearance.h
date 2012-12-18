//
//  TKAppearance.h
//  TKAppearance
//
//  Created by Taras Kalapun
//

#import <Foundation/Foundation.h>


extern NSString* TKTextAttributeFont;
extern NSString* TKTextAttributeTextColor;
extern NSString* TKTextAttributeTextShadowColor;
extern NSString* TKTextAttributeTextShadowOffset;

#ifndef UI_APPEARANCE_SELECTOR
@protocol UIAppearanceContainer <NSObject> @end

@protocol UIAppearance <NSObject>
+ (id)appearance;
+ (id)appearanceWhenContainedIn:(Class <UIAppearanceContainer>)ContainerClass, ... NS_REQUIRES_NIL_TERMINATION;
@end
#endif

@class TKAppearance;

#ifndef UI_APPEARANCE_SELECTOR
#define UI_APPEARANCE_SELECTOR
@interface UIView (TKAppearance) <UIAppearance, UIAppearanceContainer>
#else
@interface UIView (TKAppearance)
#endif
@property (nonatomic, assign) BOOL tkAppearanceApplied;
+ (TKAppearance *)tkAppearance;
@end



