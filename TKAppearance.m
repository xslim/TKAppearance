//
//  TKAppearance.m
//  TKAppearance
//
//  Created by Taras Kalapun
//

#import "TKAppearance.h"
#import <QuartzCore/QuartzCore.h>
#import "NSObject+TKSwizzle.h"
#import <objc/runtime.h>
#import <objc/message.h>
#import "NSInvocation+TKAdditions.h"

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
@property (assign, nonatomic) BOOL classSwizzled;

@property (retain, nonatomic) NSMutableDictionary *hooks;

- (id)initWithClass:(Class)newClass;
+ (void)applyInvocationsTo:(id)obj;
//+ (void)applyInvocationsTo:(id)obj matchingSelector:(SEL)sel;
- (void)callHooksIn:(NSString *)hookName context:(NSString *)context target:(id)_self args:(va_list)argp;

@end

@implementation TKAppearance
@synthesize customizableClass=customizableClass_, invocations=invocations_, properties=properties_;
@synthesize needsUpdate, classSwizzled;
@synthesize hooks=hooks_;

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
    if (!self.classSwizzled) {
        SEL origSel = @selector(layoutSublayersOfLayer:);
        IMP origImp = class_getMethodImplementation(self.customizableClass, origSel);
        IMP altImp = imp_implementationWithBlock(^(id _self, CALayer *layer){
            [TKAppearance applyInvocationsTo:layer.delegate];
            origImp(_self, origSel, layer);
        });
        [self.customizableClass swizzleMethod:origSel with:altImp store:NULL];
        self.classSwizzled = YES;
    }
    
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

- (BOOL)hasHooksIn:(NSString *)hookName context:(NSString *)context {
    NSDictionary *hooks = [self.hooks objectForKey:hookName];
    return ([[hooks objectForKey:context] count] > 0 ? YES : NO);
}

- (NSDictionary *)checksForHook:(NSString *)hookName {
    NSDictionary *hooks = [self.hooks objectForKey:hookName];
    return [hooks objectForKey:@"checks"];
}

- (void)callHooksIn:(NSString *)hookName context:(NSString *)context target:(id)_self args:(va_list)argp {
    NSDictionary *hooks = [self.hooks objectForKey:hookName];
    NSArray *args = [hooks objectForKey:@"arguments"];
    for (void (^block)(id, NSArray *, ...) in [hooks objectForKey:context]) {
        block(_self, args, argp);
    }
}

- (void)hook:(NSString *)hookName callOriginalImp:(IMP)origImp target:(id)_self args:(va_list)argp {
    NSDictionary *hooks = [self.hooks objectForKey:hookName];
    void (^block)(id, IMP, va_list) = [hooks objectForKey:@"origBlock"];
    if (block)
        block(_self, origImp, argp);
}

- (void)updateHook:(NSString *)hookName {
    // Here goes the swizzling
    
    SEL origSel = NSSelectorFromString(hookName);
    IMP origImp = class_getMethodImplementation(self.customizableClass, origSel);
    
    IMP altImp = imp_implementationWithBlock(^(id _self, ...) {
        TKAppearance *app = [[_self class] tkAppearance];
        
        BOOL triggerHooks = YES;
        NSDictionary *checks = [app checksForHook:hookName];
        
        NSString *checkSuperviewIs = [checks objectForKey:@"superviewIs"];
        if (checkSuperviewIs) {
            UIView *superview = [_self performSelector:@selector(superview)];
            if (![superview isKindOfClass:NSClassFromString(checkSuperviewIs)])
                triggerHooks = NO;
        }
        
        NSArray *checkClassNotIn = [checks objectForKey:@"classNotIn"];
        if (checkClassNotIn) {
            for (NSString *cs in checkClassNotIn) {
                if ([_self isKindOfClass:NSClassFromString(cs)]) {
                    triggerHooks = NO;
                }
            }
        }
        
        va_list argp;
        va_start(argp, _self);
        if (triggerHooks) [app callHooksIn:hookName context:@"before" target:_self args:argp];
        
        if ([app hasHooksIn:hookName context:@"instead"] && triggerHooks) {
            [app callHooksIn:hookName context:@"instead" target:_self args:argp];
        } else {
            [app hook:hookName callOriginalImp:origImp target:_self args:argp];
            //origImp(_self, origSel, argp);
            //[[_self class] printClassMethods];
        }
                
        if (triggerHooks) [app callHooksIn:hookName context:@"after" target:_self args:argp];
        va_end(argp);
    });
       
    [self.customizableClass swizzleMethod:origSel with:altImp store:NULL];
}

- (void)addHook:(NSString *)hookName block:(void *)block context:(NSString *)context {

    if (!block) return;
    
    NSMutableDictionary *hooks= [self.hooks objectForKey:hookName];
    
    NSMutableArray *a = [hooks objectForKey:context];
    if (!a) {
        a = [NSMutableArray array];
        [hooks setObject:a forKey:context];
    }
    
    [a addObject:block];
}

- (BOOL)createHook:(NSString *)hookName arguments:(NSArray *)arguments checks:(NSDictionary *)checks {
    BOOL isNewHook = NO;
    
    NSMutableDictionary *hooks = [self.hooks objectForKey:hookName];
    
    if (!hooks) {
        isNewHook = YES;
        hooks = [NSMutableDictionary dictionary];
        
        [self.hooks setObject:hooks forKey:hookName];
    }
    
    if (arguments) [hooks setObject:arguments forKey:@"arguments"];
    if (checks) {
        [hooks setObject:checks forKey:@"checks"];
    }
    
    return isNewHook;
}

- (void)hook:(NSString *)hookName addOriginalImpBlock:(void *)block {
    NSMutableDictionary *hooks = [self.hooks objectForKey:hookName];
    [hooks setObject:block forKey:@"origBlock"];
}

- (void)addSwizzleInvocation:(NSInvocation *)anInvocation withProperties:(NSDictionary *)properties {
    
    NSString *hookName = [properties objectForKey:@"hookSel"];
    if (!hookName) return;
    
    
    TKAppearance *app = self;
    
    NSString *hookClassStr = [properties objectForKey:@"hookClass"];
    if (hookClassStr && NSClassFromString(hookClassStr) != self.customizableClass) {
        app = [[[TKAppearance alloc] initWithClass:NSClassFromString(hookClassStr)] autorelease];
    }
    
    NSDictionary *checks = [properties objectForKey:@"hookChecks"];
    NSArray *args = [anInvocation arrayArguments];
    
    BOOL isNewHook = [app createHook:hookName arguments:args checks:checks];
    
    void *block = [properties objectForKey:@"origBlock"];
    if (block) [app hook:hookName addOriginalImpBlock:block];
    
    [app addHook:hookName block:[properties objectForKey:@"hookBlockBefore"] context:@"before"];
    [app addHook:hookName block:[properties objectForKey:@"hookBlockAfter"] context:@"after"];
    [app addHook:hookName block:[properties objectForKey:@"hookBlockInstead"] context:@"instead"];
    
    if (isNewHook) {
        [app updateHook:hookName];
    }
}

- (NSString *)description {
    return [NSString stringWithFormat:@"%@ [%@]", [self class], self.customizableClass];
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)sel {
    NSMethodSignature *sig = nil;
    
    // test for private )
    SEL altSel = NSSelectorFromString([@"_" stringByAppendingString:NSStringFromSelector(sel)]);
    
    if ([self.customizableClass instancesRespondToSelector:sel]) {
        sig = [self.customizableClass instanceMethodSignatureForSelector:sel];
    } else if ([self.customizableClass instancesRespondToSelector:altSel]) {
        sig = [self.customizableClass instanceMethodSignatureForSelector:altSel];
    } else {
        if (![self.customizableClass respondsToSelector:@selector(proxiedAppearanceMethods)]) {
            return [NSMethodSignature signatureWithObjCTypes:"v@:@"];
        }
        
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
    SEL altSel = NSSelectorFromString([@"_" stringByAppendingString:NSStringFromSelector(origSel)]);
    
    [anInvocation retainArguments];
    
    if ([self.customizableClass instancesRespondToSelector:origSel]) {
        // TODO: Search if we already have this SEL in array
        [self addInvocation:anInvocation];
        self.needsUpdate = YES;
    } else if ([self.customizableClass instancesRespondToSelector:altSel]) {
        // TODO: Search if we already have this SEL in array
        anInvocation.selector = altSel;
        [self addInvocation:anInvocation];
        self.needsUpdate = YES;
    } else {
        if (![self.customizableClass respondsToSelector:@selector(proxiedAppearanceMethods)]) {
            [anInvocation setTarget:self];
            [anInvocation setSelector:@selector(appearanceNotSupported:)];
            [anInvocation invoke];
            return;
        }
        NSDictionary *proxiedMethods = [self.customizableClass performSelector:@selector(proxiedAppearanceMethods)];
        NSDictionary *d = [proxiedMethods objectForKey:NSStringFromSelector(origSel)];
        if (d) {
            [self addSwizzleInvocation:anInvocation withProperties:d];
        }
    }
    return;
}

- (void)appearanceNotSupported:(id)something,... {
    NSLog(@"appearanceNotSupported... yet :)");
}

+ (void)applyInvocationsTo:(id)obj {
    TKAppearance *app = [[obj class] performSelector:@selector(tkAppearance)];
    if ([obj tkAppearanceApplied]) return;
    
    
    for (NSMutableDictionary *d in app.properties) {
        //if ([[d objectForKey:kAppearanceObjectSelNeetsConfigure] boolValue]) {
            
            if (![[d objectForKey:kAppearanceObjectSelPreInit] boolValue]) {
                NSInvocation *inv = [d objectForKey:kAppearanceObjectSelInvocation];
                [inv setTarget:obj];
                [inv invoke];
            }
            
            [d setObject:[NSNumber numberWithBool:NO] forKey:kAppearanceObjectSelNeetsConfigure];
        //}
    }
    [obj setTkAppearanceApplied:YES];
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


__attribute__((constructor)) static void defineConstants(void) {
    if(&UITextAttributeFont)
    {
        TKTextAttributeFont = UITextAttributeFont;
        TKTextAttributeTextColor = UITextAttributeTextColor;
        TKTextAttributeTextShadowColor = UITextAttributeTextShadowColor;
        TKTextAttributeTextShadowOffset = UITextAttributeTextShadowOffset;
    }
    else
    {
        TKTextAttributeFont = @"UITextAttributeFont";
        TKTextAttributeTextColor = @"UITextAttributeTextColor";
        TKTextAttributeTextShadowColor = @"UITextAttributeTextShadowColor";
        TKTextAttributeTextShadowOffset = @"UITextAttributeTextShadowOffset";
    }
}


@implementation UIView (TKAppearance)

static id UIView_appearance(id self, SEL _cmd) {
    return [[TKAppearanceManager sharedInstance] createAppearanceForClass:[self class]];
}

+ (void)load {
    if (![UIView respondsToSelector:@selector(appearance)]) {
        [UIView addClassMethod:@selector(appearance) with:(IMP)UIView_appearance types:"@@:"];
    }
}

static char kAppearanceApplied; 

- (BOOL)tkAppearanceApplied {
    NSNumber *nBool = objc_getAssociatedObject(self, &kAppearanceApplied);
    return [nBool boolValue];
}

+ (TKAppearance *)tkAppearance {
    TKAppearance *app = nil;
    app = [[TKAppearanceManager sharedInstance] appearanceForClass:[self class]];
    if (!app) {
        app = [[TKAppearanceManager sharedInstance] appearanceForClass:[self superclass]];
        if (!app) {
            app = [[TKAppearanceManager sharedInstance] appearanceForClass:[[self superclass] superclass]];
        }
    }
    return app;
}

- (void)setTkAppearanceApplied:(BOOL)appAplied {
    objc_setAssociatedObject(self, &kAppearanceApplied, [NSNumber numberWithBool:appAplied], OBJC_ASSOCIATION_RETAIN);
}

@end
