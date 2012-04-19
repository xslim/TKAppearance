//
//  NSInvocation+TKAdditions.h
//  KPN-Hotspots
//
//  Created by Taras Kalapun on 4/12/12.
//  Copyright (c) 2012 Xaton. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSInvocation (TKAdditions)

- (void)setVAArguments:(va_list)arguments;
- (NSArray *)arrayArguments;

@end
