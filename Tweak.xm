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
    
    // Create menu button immediately, don't wait
    if (!menuButton) {
        [self performSelector:@selector(createFateMenuButton) withObject:nil afterDelay:0.5];
    }
}

%new
- (void)createFateMenuButton {
    @try {
        UIWindow *keyWindow = [[UIApplication sharedApplication] keyWindow];
        if (!keyWindow) {
            NSLog(@"[Fate] No key window found, trying to find window from connected scenes");
            // Fallback: try to find any available window
            if (@available(iOS 13.0, *)) {
                for (UIWindowScene *scene in [UIApplication sharedApplication].connectedScenes) {
                    if ([scene isKindOfClass:[UIWindowScene class]]) {
                        keyWindow = scene.windows.firstObject;
                        if (keyWindow) break;
                    }
                }
            }
            if (!keyWindow) {
                NSLog(@"[Fate] Still no window found!");
                return;
            }
        }
        
        // Create menu button
        menuButton = [UIButton buttonWithType:UIButtonTypeCustom];
        menuButton.frame = CGRectMake(20, 100, 70, 50);
        [menuButton setTitle:@"⚡\nFATE" forState:UIControlStateNormal];
        [menuButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        menuButton.titleLabel.font = [UIFont systemFontOfSize:12 weight:UIFontWeightBold];
        menuButton.titleLabel.numberOfLines = 2;
        menuButton.titleLabel.textAlignment = NSTextAlignmentCenter;
        
        // Modern gradient background
        CAGradientLayer *gradient = [CAGradientLayer layer];
        gradient.frame = menuButton.bounds;
        gradient.colors = @[
            (id)[UIColor colorWithRed:0.3 green:0.5 blue:1.0 alpha:0.95].CGColor,
            (id)[UIColor colorWithRed:0.2 green:0.4 blue:0.9 alpha:0.95].CGColor
        ];
        gradient.cornerRadius = 12;
        [menuButton.layer insertSublayer:gradient atIndex:0];
        
        // Styling
        menuButton.layer.cornerRadius = 12;
        menuButton.layer.borderWidth = 2;
        menuButton.layer.borderColor = [UIColor colorWithRed:0.4 green:0.6 blue:1.0 alpha:1.0].CGColor;
        menuButton.layer.shadowColor = [UIColor colorWithRed:0.4 green:0.6 blue:1.0 alpha:1.0].CGColor;
        menuButton.layer.shadowRadius = 10;
        menuButton.layer.shadowOpacity = 0.8;
        menuButton.layer.shadowOffset = CGSizeMake(0, 0);
        menuButton.layer.masksToBounds = NO;
        
        // Make it draggable
        UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
        [menuButton addGestureRecognizer:panGesture];
        
        [menuButton addTarget:self action:@selector(openFateMenu) forControlEvents:UIControlEventTouchUpInside];
        [keyWindow addSubview:menuButton];
        [keyWindow bringSubviewToFront:menuButton];
        
        NSLog(@"[Fate] ✅ Menu button created successfully and visible");
    } @catch (NSException *exception) {
        NSLog(@"[Fate] ❌ Exception creating menu button: %@", exception);
    }
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
    @try {
        if (!menuController) {
            menuController = [[FateModMenu alloc] init];
        }
        
        UIViewController *rootVC = [[UIApplication sharedApplication] keyWindow].rootViewController;
        if (!rootVC) {
            NSLog(@"[Fate] No root VC found, try iOS 13+ approach");
            if (@available(iOS 13.0, *)) {
                for (UIWindowScene *scene in [UIApplication sharedApplication].connectedScenes) {
                    if ([scene isKindOfClass:[UIWindowScene class]]) {
                        UIWindowScene *windowScene = (UIWindowScene *)scene;
                        rootVC = windowScene.windows.firstObject.rootViewController;
                        if (rootVC) break;
                    }
                }
            }
        }
        
        if (rootVC) {
            [rootVC presentViewController:menuController animated:YES completion:nil];
            NSLog(@"[Fate] ✅ Menu opened successfully");
        } else {
            NSLog(@"[Fate] ❌ Could not find root view controller");
        }
    } @catch (NSException *exception) {
        NSLog(@"[Fate] ❌ Exception opening menu: %@", exception);
    }
}

%end

%ctor {
    NSLog(@"[Fate] Mod loaded successfully!");
    NSLog(@"[Fate] Version 1.0 - Animal Company Mod Menu");
}