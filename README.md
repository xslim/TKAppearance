* Dont forget to add `-fno-objc-arc` to all .m files in Target - Build Phases


Now you can do something like this:

``` objc

[[UINavigationBar appearance] setTintColor:[UIColor redColor]];
    
UIImage *bgImg = [Decorator backgroundImageForNavigationBarWithSize:CGSizeMake(320.f, 44.f)];
[[UINavigationBar appearance] setBackgroundImage:bgImg forBarMetrics:UIBarMetricsDefault];

[[UINavigationBar appearance] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                                          [UIFont fontWithName:@"KPNSans-Bold" size:20.0], UITextAttributeFont,
                                                          //[UIColor redColor], UITextAttributeTextColor,
                                                          [UIColor styledShadowColor], UITextAttributeTextShadowColor,
                                                          nil]];

bgImg = [Decorator backgroundImageForTabBarWithSize:CGSizeMake(320.f, 50.f)];
[[UITabBar appearance] setBackgroundImage:bgImg];


```

on iOS 4 !!!
