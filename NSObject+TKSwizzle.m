//
//  NSObject+TKSwizzle.m
//  KPN-Hotspots
//
//  Created by Taras Kalapun on 4/10/12.
//  Copyright (c) 2012 Xaton. All rights reserved.
//

#import "NSObject+TKSwizzle.h"

#if TARGET_OS_IPHONE
#import <objc/runtime.h>
#import <objc/message.h>
#else
#import <objc/objc-class.h>
#endif

/*
 Idea stolen from:
 * http://stackoverflow.com/questions/5339276/what-are-the-dangers-of-method-swizzling-in-objective-c
 * JRSwizzle
 */

BOOL class_swizzleMethodAndStore(Class class, SEL origSel, IMP altImp, IMP *storeImp) {
    IMP imp = NULL;
    Method method = class_getInstanceMethod(class, origSel);
    if (method) {
        const char *type = method_getTypeEncoding(method);
        imp = class_replaceMethod(class, origSel, altImp, type);
        if (!imp) {
            imp = method_getImplementation(method);
        }
    }
    //else {
    //    class_addMethod(class, origSel, altImp, "@@:");
    //}
    
    if (imp && storeImp) { *storeImp = imp; }
    return (imp != NULL);
}

@implementation NSObject (TKSwizzle)

+ (BOOL)swizzleMethod:(SEL)origSel with:(SEL)altSel {
    Method origMethod = class_getInstanceMethod(self, origSel);
    Method altMethod = class_getInstanceMethod(self, altSel);
    
    if (!altMethod || !origMethod) return NO;
    
    class_addMethod(self, origSel, class_getMethodImplementation(self, origSel), method_getTypeEncoding(origMethod));
	class_addMethod(self, altSel, class_getMethodImplementation(self, altSel), method_getTypeEncoding(altMethod));
    
	method_exchangeImplementations(class_getInstanceMethod(self, origSel), class_getInstanceMethod(self, altSel));
	return YES;
}


+ (BOOL)swizzleMethod:(SEL)origSel with:(IMP)altImp store:(IMP *)storeImp {
    return class_swizzleMethodAndStore(self, origSel, altImp, storeImp);
}

+ (BOOL)swizzleClassMethod:(SEL)origSel with:(IMP)altImp store:(IMP *)storeImp {
    return [object_getClass(self) swizzleMethod:origSel with:altImp store:storeImp];
}

+ (BOOL)addMethod:(SEL)origSel with:(IMP)altImp types:(const char *)types {
    return class_addMethod(self, origSel, altImp, types);
}

+ (BOOL)addClassMethod:(SEL)origSel with:(IMP)altImp types:(const char *)types {
    return [object_getClass(self) addMethod:origSel with:altImp types:types];
}

+ (NSString *)encodingForMethod:(SEL)sel {
    Method method = class_getInstanceMethod(self, sel);
    const char* const enc = method_getTypeEncoding(method);
    NSString *s = [NSString stringWithCString:enc encoding:NSASCIIStringEncoding];
    return s;
}

+ (void)printClassMethods {
    
    @autoreleasepool {
        NSMutableString *ms = nil;
        unsigned int out_count;

        ms = [NSMutableString string];
        out_count = 0;
        Method *class_methods = class_copyMethodList(self, &out_count);
        for (int i = 0; i < out_count; i++) {
            Method m = class_methods[i];
            const char* const type = method_copyReturnType(m);
            
            [ms appendFormat:@"\n\t- (%s)%@ %s",
                  type,
                  NSStringFromSelector(method_getDescription(m)->name),
                method_getTypeEncoding(m)
             ];
            
            free((void*)type);
        }
        NSLog(@"Methods in %@\n%@\n", NSStringFromClass(self), ms);
    }
    
    @autoreleasepool {
        NSMutableString *ms = nil;
        unsigned int out_count;
        ms = [NSMutableString string];
        out_count = 0;
        Ivar *class_ivars = class_copyIvarList(self, &out_count);
        for (int i = 0; i < out_count; i++) {
            Ivar v = class_ivars[i];
            const char* const name = ivar_getName(v);
            const char* const type = ivar_getTypeEncoding(v);
            [ms appendFormat:@"\n\t- (%s)%s", type, name];
            
            free((void*)type);
            free((void*)name);
        }
        NSLog(@"IVars in %@\n%@\n", NSStringFromClass(self), ms);
    }
    
    @autoreleasepool {
        NSMutableString *ms = nil;
        unsigned int out_count;
        ms = [NSMutableString string];
        out_count = 0;
        objc_property_t *class_props = class_copyPropertyList(self, &out_count);
        for (int i = 0; i < out_count; i++) {
            objc_property_t p = class_props[i];
            const char* const name = property_getName(p);
            const char* const type = property_getAttributes(p);
            [ms appendFormat:@"\n\t- (%s)%s", type, name];
            
            free((void*)type);
            free((void*)name);
        }
        NSLog(@"Properties in %@\n%@\n", NSStringFromClass(self), ms);
    }    
}

@end
