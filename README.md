Introduction
=========================

This thing let's you mimic Apples UIAppearance thing back on iOS 4

Installation
=========================
* You need [cocoapods](http://cocoapods.org) lib manager
* Edit your `Podfile` and add

```ruby
dependency 'TKAppearance', :podspec => 'https://raw.github.com/xslim/TKAppearance/master/TKAppearance.podspec'
```

* `#import "TKAppearance.h"`
* Dont forget to add `-fno-objc-arc` to all .m files in Target - Build Phases


Now you can do something like this on iOS 4:

```objc
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

CGFloat w = 320.f / self.tabBarController.viewControllers.count -4;
bgImg = [Decorator backgroundImageForSelectedTabBarItemWithSize:CGSizeMake(w, 48.f)];
[[UITabBar appearance] setSelectionIndicatorImage:bgImg];

bgImg = [Decorator imageWithSize:CGSizeMake(320.f, 44.f) gradientStart:[UIColor styledTintEndColor] end:[UIColor styledSelectedTintStartColor]];
[[UISearchBar appearance] setBackgroundImage:bgImg];

[[UISwitch appearance] setOnTintColor:[UIColor styledButtonTintColor]];

```

**Note:** Tested on iOS 4.3

Plugin creation
=========================
* Look in source files



