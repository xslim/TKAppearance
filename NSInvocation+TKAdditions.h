//
//  NSInvocation+TKAdditions.h
//  TKAppearance
//
//  Created by Taras Kalapun
//

#import <Foundation/Foundation.h>

@interface NSInvocation (TKAdditions)

- (void)setVAArguments:(va_list)arguments;
- (NSArray *)arrayArguments;

@end
