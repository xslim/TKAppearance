//
//  TKAppearance.m
//  KPN-Hotspots
//
//  Created by Taras Kalapun on 4/11/12.
//  Copyright (c) 2012 Xaton. All rights reserved.
//

#import "TKAppearance.h"
#import <QuartzCore/QuartzCore.h>
#import "NSObject+TKSwizzle.h"
#import <objc/runtime.h>
#import <objc/message.h>


static NSString * const kAppearanceObjectSel = @"kAppearanceObjectSel";
static NSString * const kAppearanceObjectSelInvocation = @"kAppearanceObjectSelInvocation";
static NSString * const kAppearanceObjectSelNeetsConfigure = @"kAppearanceObjectSelNeetsConfigure";
static NSString * const kAppearanceObjectSelPreInit = @"kAppearanceObjectSelPreInit";
static NSString * const kAppearanceObjectSelCustomImp = @"kAppearanceObjectSelCustomImp";

@class TKAppearance;

@interface TKAppearanceManager : NSObject

@property (strong, nonatomic) NSMutableSet *objects;

+ (TKAppearanceManager *)sharedInstance;

- (BOOL)hasAppearanceForClass:(Class)customizableClass;
- (TKAppearance *)appearanceForClass:(Class)customizableClass;
- (TKAppearance *)createAppearanceForClass:(Class)customizableClass;
- (void)addAppearanceObject:(TKAppearance *)obj;

@end
@interface TKAppearance : NSObject

@property (assign, nonatomic) Class customizableClass;
@property (retain, nonatomic) NSMutableArray *properties;
@property (retain, nonatomic) NSMutableArray *invocations;
@property (assign, nonatomic) BOOL needsUpdate;

@property (retain, nonatomic) NSMutableDictionary *hooks;

- (id)initWithClass:(Class)newClass;
+ (void)applyInvocationsTo:(id)obj;
//+ (void)applyInvocationsTo:(id)obj matchingSelector:(SEL)sel;
- (void)callHooksIn:(NSString *)hookName context:(NSString *)context target:(id)_self args:(va_list)argp;

@end

@implementation TKAppearance
@synthesize customizableClass=customizableClass_, invocations=invocations_, properties=properties_;
@synthesize hooks=hooks_;

IMP UIView_orig_hookMethod;
static void UIView_hookMethod(id self, SEL _cmd, CALayer *layer) {
    [TKAppearance applyInvocationsTo:layer.delegate];
    UIView_orig_hookMethod(self, _cmd, layer);
}

- (id)initWithClass:(Class)newClass {
    
    TKAppearanceManager *am = [TKAppearanceManager sharedInstance];
    TKAppearance *app = [am appearanceForClass:newClass];
    if (app) return [app retain];
    
    self = [super init];
    if (self) {
        self.customizableClass = newClass;
        self.invocations = [NSMutableArray array];
        self.properties = [NSMutableArray array];
        self.hooks = [NSMutableDictionary dictionary];
    }
    
    // Found from _UIAppearance
    [self.customizableClass swizzleMethod:@selector(layoutSublayersOfLayer:) with:(IMP)UIView_hookMethod store:&UIView_orig_hookMethod];
    
    // let it be here
    [am addAppearanceObject:self];
    
    return self;
}

- (void)addInvocation:(NSInvocation *)anInvocation {
    NSMutableDictionary *d = [NSMutableDictionary dictionary];
    [d setObject:NSStringFromSelector(anInvocation.selector) forKey:kAppearanceObjectSel];
    [d setObject:anInvocation forKey:kAppearanceObjectSelInvocation];
    [d setObject:[NSNumber numberWithBool:YES] forKey:kAppearanceObjectSelNeetsConfigure];
    
    [self.properties addObject:d];
}

- (void)callHooksIn:(NSString *)hookName context:(NSString *)context target:(id)_self args:(va_list)argp {
    NSDictionary *hooks = [self.hooks objectForKey:hookName];
    for (NSDictionary *d in [hooks objectForKey:context]) {
        void (^block)(id, NSInvocation *, ...) = [d objectForKey:@"block"];
        NSInvocation *inv = [d objectForKey:@"invocation"];
        block(_self, inv, argp);
    }
}

- (void)updateHook:(NSString *)hookName {
    // Here goes the swizzling
    
    SEL origSel = NSSelectorFromString(hookName);
    IMP origImp = class_getMethodImplementation(self.customizableClass, origSel);
    
    IMP altImp = imp_implementationWithBlock(^(id _self, ...) {
        TKAppearance *app = [[_self class] appearance];
        
        va_list argp;
        va_start(argp, _self);
        [app callHooksIn:hookName context:@"before" target:_self args:argp];
        origImp(_self, origSel, argp);
        [app callHooksIn:hookName context:@"after" target:_self args:argp];
        va_end(argp);
    });
    
    [self.customizableClass swizzleMethod:origSel with:altImp store:NULL];
}


- (void)addHook:(NSString *)hookName before:(void *)beforeBlock after:(void *)afterBlock invocation:(NSInvocation *)inv {
    
    BOOL isNewHook = NO;
    NSMutableDictionary *hooks = [self.hooks objectForKey:hookName];
    if (!hooks) {
        isNewHook = YES;
        hooks = [NSMutableDictionary dictionary];
    }
    
    if (beforeBlock) {
        NSMutableArray *a = [hooks objectForKey:@"before"];
        if (!a) a = [NSMutableArray array];
        
        NSDictionary *d = [NSDictionary dictionaryWithObjectsAndKeys:
                           beforeBlock, @"block",
                           inv, @"invocation",
                           nil];
        [a addObject:d];
        [hooks setObject:a forKey:@"before"];
    }
    
    if (afterBlock) {
        NSMutableArray *a = [hooks objectForKey:@"after"];
        if (!a) a = [NSMutableArray array];
        
        NSDictionary *d = [NSDictionary dictionaryWithObjectsAndKeys:
                           afterBlock, @"block",
                           inv, @"invocation",
                           nil];
        [a addObject:d];
        [hooks setObject:a forKey:@"after"];
    }
    
    if (isNewHook) {
        [self.hooks setObject:hooks forKey:hookName];
        [self updateHook:hookName];
    }
}

- (void)addSwizzleInvocation:(NSInvocation *)anInvocation withProperties:(NSDictionary *)properties {
    
    NSString *hookName = [properties objectForKey:@"hookSel"];
    [self addHook:hookName before:[properties objectForKey:@"hookBlockBefore"] after:[properties objectForKey:@"hookBlockAfter"] invocation:anInvocation];
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)sel {
    NSMethodSignature *sig = nil;
    
    if ([self.customizableClass instancesRespondToSelector:sel]) {
        sig = [self.customizableClass instanceMethodSignatureForSelector:sel];
    } else {
        NSDictionary *proxiedMethods = [self.customizableClass performSelector:@selector(proxiedAppearanceMethods)];
        NSDictionary *d = [proxiedMethods objectForKey:NSStringFromSelector(sel)];
        if (d) {
            const char *type = [(NSString *)[d objectForKey:@"encoding"] cStringUsingEncoding:NSASCIIStringEncoding];
            sig = [NSMethodSignature signatureWithObjCTypes:type];
            
            if ([[d objectForKey:@"addImp"] boolValue]) {
                void *block = [d objectForKey:@"imp"];
                IMP imp = imp_implementationWithBlock(block);
                [self.customizableClass addMethod:sel with:imp types:type];
            }
        }
    }
    return sig;
}

- (void)forwardInvocation:(NSInvocation *)anInvocation {    
    SEL origSel = anInvocation.selector;
    
    [anInvocation retainArguments];
    
    if ([self.customizableClass instancesRespondToSelector:origSel]) {
        // TODO: Search if we already have this SEL in array
        [self addInvocation:anInvocation];
        self.needsUpdate = YES;
    } else {
        NSDictionary *proxiedMethods = [self.customizableClass performSelector:@selector(proxiedAppearanceMethods)];
        NSDictionary *d = [proxiedMethods objectForKey:NSStringFromSelector(origSel)];
        if (d) {
            [self addSwizzleInvocation:anInvocation withProperties:d];
        }
    }
    return;
}


+ (void)applyInvocationsTo:(id)obj {
    TKAppearance *app = [[obj class] performSelector:@selector(appearance)];
    if (!app.needsUpdate) return;
    
    
    for (NSMutableDictionary *d in app.properties) {
        if ([[d objectForKey:kAppearanceObjectSelNeetsConfigure] boolValue]) {
            
            if (![[d objectForKey:kAppearanceObjectSelPreInit] boolValue]) {
                NSInvocation *inv = [d objectForKey:kAppearanceObjectSelInvocation];
                [inv setTarget:obj];
                [inv invoke];
            }
            
            [d setObject:[NSNumber numberWithBool:NO] forKey:kAppearanceObjectSelNeetsConfigure];
        }
    }
    app.needsUpdate = NO;
}

@end

#pragma mark - TKAppearanceContainer

@implementation TKAppearanceManager

@synthesize objects = objects_;

#pragma mark - Singleton implementation

+ (TKAppearanceManager *)sharedInstance {
    static TKAppearanceManager *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

- (id)init
{
    self = [super init];
    if (self) {
        self.objects = [NSMutableSet set];
    }
    return self;
}

#pragma mark - Actions

- (void)addAppearanceObject:(TKAppearance *)obj {
    if ([self.objects containsObject:obj]) return;
    [self.objects addObject:obj];
}

#pragma mark - Object Creator

- (BOOL)hasAppearanceForClass:(Class)customizableClass {
    return ([self appearanceForClass:customizableClass] ? YES : NO);
}

- (TKAppearance *)appearanceForClass:(Class)customizableClass {
    // Check in dictionary
    for (TKAppearance *obj in self.objects) {
        if (obj.customizableClass == customizableClass) {
            return obj;
        }
    }
    return nil;
}

- (TKAppearance *)createAppearanceForClass:(Class)customizableClass {
    TKAppearance *app = [self appearanceForClass:customizableClass];
    if (!app) app = [[[TKAppearance alloc] initWithClass:customizableClass] autorelease];
    
    return app;
}

@end


NSString *const UITextAttributeFont = @"kUITextAttributeFont";
// Key to the text color in the text attributes dictionary. A UIColor instance is expected.
NSString *const UITextAttributeTextColor = @"kUITextAttributeTextColor";
// Key to the text shadow color in the text attributes dictionary.  A UIColor instance is expected.
NSString *const UITextAttributeTextShadowColor = @"kUITextAttributeTextShadowColor";
// Key to the offset used for the text shadow in the text attributes dictionary. An NSValue instance wrapping a UIOffset struct is expected.
NSString *const UITextAttributeTextShadowOffset = @"kUITextAttributeTextShadowOffset";


@implementation UIView (TKAppearance)

static id UIView_appearance(id self, SEL _cmd) {
    return [[TKAppearanceManager sharedInstance] createAppearanceForClass:[self class]];
}

+ (void)load {
    if ([UIView respondsToSelector:@selector(appearance)]) return;
    
    [UIView addClassMethod:@selector(appearance) with:(IMP)UIView_appearance types:"@@:"];
}

@end
