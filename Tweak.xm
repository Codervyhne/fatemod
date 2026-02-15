//
//  Tweak.xm
//  Fate Mod - Main Tweak File
//
//  This file hooks into the game and adds the menu button
//

#import "FateModMenu.h"

static UIButton *menuButton = nil;
static FateModMenu *menuController = nil;

%hook UIApplication

- (void)applicationDidBecomeActive:(UIApplication *)application {
    %orig;
    
    // Create menu button after a short delay
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 3 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        if (!menuButton) {
            [self performSelector:@selector(createFateMenuButton)];
        }
    });
}

%new
- (void)createFateMenuButton {
    UIWindow *keyWindow = [[UIApplication sharedApplication] keyWindow];
    if (!keyWindow) {
        NSLog(@"[Fate] No key window found");
        return;
    }
    
    // Create menu button
    menuButton = [UIButton buttonWithType:UIButtonTypeSystem];
    menuButton.frame = CGRectMake(20, 80, 70, 40);
    [menuButton setTitle:@"⚡ FATE" forState:UIControlStateNormal];
    [menuButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    menuButton.titleLabel.font = [UIFont systemFontOfSize:14 weight:UIFontWeightBold];
    
    // Modern gradient background
    CAGradientLayer *gradient = [CAGradientLayer layer];
    gradient.frame = menuButton.bounds;
    gradient.colors = @[
        (id)[UIColor colorWithRed:0.3 green:0.5 blue:1.0 alpha:0.95].CGColor,
        (id)[UIColor colorWithRed:0.2 green:0.4 blue:0.9 alpha:0.95].CGColor
    ];
    gradient.cornerRadius = 20;
    [menuButton.layer insertSublayer:gradient atIndex:0];
    
    // Styling
    menuButton.layer.cornerRadius = 20;
    menuButton.layer.borderWidth = 2;
    menuButton.layer.borderColor = [UIColor colorWithRed:0.4 green:0.6 blue:1.0 alpha:1.0].CGColor;
    menuButton.layer.shadowColor = [UIColor colorWithRed:0.4 green:0.6 blue:1.0 alpha:1.0].CGColor;
    menuButton.layer.shadowRadius = 10;
    menuButton.layer.shadowOpacity = 0.6;
    menuButton.layer.shadowOffset = CGSizeMake(0, 0);
    
    // Make it draggable
    UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
    [menuButton addGestureRecognizer:panGesture];
    
    [menuButton addTarget:self action:@selector(openFateMenu) forControlEvents:UIControlEventTouchUpInside];
    [keyWindow addSubview:menuButton];
    
    NSLog(@"[Fate] Menu button created successfully");
}

%new
- (void)handlePan:(UIPanGestureRecognizer *)gesture {
    UIView *view = gesture.view;
    CGPoint translation = [gesture translationInView:view.superview];
    
    view.center = CGPointMake(view.center.x + translation.x, view.center.y + translation.y);
    [gesture setTranslation:CGPointZero inView:view.superview];
    
    if (gesture.state == UIGestureRecognizerStateEnded) {
        // Snap to edges
        CGRect screenBounds = [UIScreen mainScreen].bounds;
        CGFloat centerX = view.center.x;
        CGFloat centerY = view.center.y;
        
        // Constrain to screen bounds
        if (centerX < view.bounds.size.width / 2) centerX = view.bounds.size.width / 2 + 10;
        if (centerX > screenBounds.size.width - view.bounds.size.width / 2) {
            centerX = screenBounds.size.width - view.bounds.size.width / 2 - 10;
        }
        if (centerY < view.bounds.size.height / 2) centerY = view.bounds.size.height / 2 + 50;
        if (centerY > screenBounds.size.height - view.bounds.size.height / 2) {
            centerY = screenBounds.size.height - view.bounds.size.height / 2 - 10;
        }
        
        [UIView animateWithDuration:0.3 animations:^{
            view.center = CGPointMake(centerX, centerY);
        }];
    }
}

%new
- (void)openFateMenu {
    if (!menuController) {
        menuController = [[FateModMenu alloc] init];
    }
    
    UIViewController *rootVC = [[UIApplication sharedApplication] keyWindow].rootViewController;
    if (rootVC) {
        [rootVC presentViewController:menuController animated:YES completion:nil];
        NSLog(@"[Fate] Menu opened");
    } else {
        NSLog(@"[Fate] No root view controller found");
    }
}

%end

%ctor {
    NSLog(@"[Fate] Mod loaded successfully!");
    NSLog(@"[Fate] Version 1.0 - Animal Company Mod Menu");
}