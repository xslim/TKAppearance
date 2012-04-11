* Dont forget to add `-fno-objc-arc` to all .m files in Target - Build Phases


Now you can do something like this

``` objc
[[UINavigationBar appearance] setTintColor:[UIColor redColor]];
    
UIImage *bgImg = [KPNNavigationBarDecorator backgroundImageForNavigationBarWithSize:CGSizeMake(320.f, 44.f)];
[[UINavigationBar appearance] setBackgroundImage:bgImg forBarMetrics:UIBarMetricsDefault];
```

on iOS 4 !!!