* Dont forget to add `-fno-objc-arc` to all .m files in Target - Build Phases


Now you can do something like this

``` objc
#ifdef UI_APPEARANCE_SELECTOR

    [[UINavigationBar appearance] setTintColor:[UIColor redColor]];
    
    UIImage *bgImg = [NavigationBarDecorator backgroundImageForNavigationBarWithSize:CGSizeMake(320.f, 44.f)];
    [[UINavigationBar appearance] setBackgroundImage:bgImg forBarMetrics:UIBarMetricsDefault];

#endif
```

on iOS 4 !!!
