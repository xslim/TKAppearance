//
//  TKAppearance.h
//
//  Created by Taras Kalapun on 4/11/12.
//

#import <Foundation/Foundation.h>

#ifndef UI_APPEARANCE_SELECTOR
// Key to the font in the text attributes dictionary. A UIFont instance is expected. Use a font with size 0.0 to get the default font size for the situation.
extern NSString *const UITextAttributeFont;
// Key to the text color in the text attributes dictionary. A UIColor instance is expected.
extern NSString *const UITextAttributeTextColor;
// Key to the text shadow color in the text attributes dictionary.  A UIColor instance is expected.
extern NSString *const UITextAttributeTextShadowColor; 
// Key to the offset used for the text shadow in the text attributes dictionary. An NSValue instance wrapping a UIOffset struct is expected.
extern NSString *const UITextAttributeTextShadowOffset;


#define UI_APPEARANCE_SELECTOR

@protocol UIAppearanceContainer <NSObject> @end

@protocol UIAppearance <NSObject>
+ (id)appearance;
+ (id)appearanceWhenContainedIn:(Class <UIAppearanceContainer>)ContainerClass, ... NS_REQUIRES_NIL_TERMINATION;
@end


@interface UIView (TKAppearance) <UIAppearance, UIAppearanceContainer>

@end

#endif


