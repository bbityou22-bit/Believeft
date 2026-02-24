// BelieveFTMods.xm
// iOS Dylib Tweak — BelieveFT Mods
// Build with Theos: https://theos.dev
//
// Makefile example:
//   PACKAGE_NAME = believeftmods
//   THEOS_PACKAGE_SCHEME = rootless
//
//   include $(THEOS)/makefiles/common.mk
//   TWEAK_NAME = BelieveFTMods
//   BelieveFTMods_FILES = BelieveFTMods.xm
//   BelieveFTMods_FRAMEWORKS = UIKit
//   include $(THEOS_MAKE_PATH)/tweak.mk

#import <UIKit/UIKit.h>
#import <substrate.h>   // CydiaSubstrate / libhooker

// ---------------------------------------------------------------------------
// Menu View Controller
// ---------------------------------------------------------------------------

@interface BFTMenuViewController : UIViewController
@end

@implementation BFTMenuViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    // Blurred background
    UIBlurEffect *blur = [UIBlurEffect effectWithStyle:UIBlurEffectStyleSystemMaterial];
    UIVisualEffectView *blurView = [[UIVisualEffectView alloc] initWithEffect:blur];
    blurView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:blurView];
    [NSLayoutConstraint activateConstraints:@[
        [blurView.topAnchor constraintEqualToAnchor:self.view.topAnchor],
        [blurView.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor],
        [blurView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
        [blurView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
    ]];

    // Title label
    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.text = @"BelieveFT Mods";
    titleLabel.font = [UIFont boldSystemFontOfSize:24.0];
    titleLabel.textColor = [UIColor labelColor];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:titleLabel];

    // Divider
    UIView *divider = [[UIView alloc] init];
    divider.backgroundColor = [UIColor separatorColor];
    divider.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:divider];

    // Placeholder mod toggle (example)
    UISwitch *exampleToggle = [[UISwitch alloc] init];
    exampleToggle.translatesAutoresizingMaskIntoConstraints = NO;

    UILabel *toggleLabel = [[UILabel alloc] init];
    toggleLabel.text = @"Example Mod";
    toggleLabel.font = [UIFont systemFontOfSize:16.0];
    toggleLabel.textColor = [UIColor labelColor];
    toggleLabel.translatesAutoresizingMaskIntoConstraints = NO;

    UIStackView *toggleRow = [[UIStackView alloc] initWithArrangedSubviews:@[toggleLabel, exampleToggle]];
    toggleRow.axis = UILayoutConstraintAxisHorizontal;
    toggleRow.distribution = UIStackViewDistributionEqualSpacing;
    toggleRow.alignment = UIStackViewAlignmentCenter;
    toggleRow.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:toggleRow];

    // Close button
    UIButton *closeButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [closeButton setTitle:@"Close" forState:UIControlStateNormal];
    closeButton.titleLabel.font = [UIFont systemFontOfSize:17.0 weight:UIFontWeightMedium];
    closeButton.translatesAutoresizingMaskIntoConstraints = NO;
    [closeButton addTarget:self action:@selector(dismiss) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:closeButton];

    // Layout
    [NSLayoutConstraint activateConstraints:@[
        [titleLabel.topAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.topAnchor constant:24.0],
        [titleLabel.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor],

        [divider.topAnchor constraintEqualToAnchor:titleLabel.bottomAnchor constant:16.0],
        [divider.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:16.0],
        [divider.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor constant:-16.0],
        [divider.heightAnchor constraintEqualToConstant:1.0 / UIScreen.mainScreen.scale],

        [toggleRow.topAnchor constraintEqualToAnchor:divider.bottomAnchor constant:20.0],
        [toggleRow.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:24.0],
        [toggleRow.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor constant:-24.0],

        [closeButton.bottomAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.bottomAnchor constant:-24.0],
        [closeButton.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor],
    ]];
}

- (void)dismiss {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end

// ---------------------------------------------------------------------------
// Floating Button Window — always sits on top
// ---------------------------------------------------------------------------

@interface BFTFloatingButton : UIWindow
@end

@implementation BFTFloatingButton

- (instancetype)init {
    if (@available(iOS 13.0, *)) {
        // Find an active scene to attach the window to
        UIWindowScene *scene = nil;
        for (UIScene *s in UIApplication.sharedApplication.connectedScenes) {
            if (s.activationState == UISceneActivationStateForegroundActive &&
                [s isKindOfClass:[UIWindowScene class]]) {
                scene = (UIWindowScene *)s;
                break;
            }
        }
        if (scene) {
            self = [super initWithWindowScene:scene];
        } else {
            self = [super initWithFrame:UIScreen.mainScreen.bounds];
        }
    } else {
        self = [super initWithFrame:UIScreen.mainScreen.bounds];
    }

    if (!self) return nil;

    self.windowLevel = UIWindowLevelStatusBar + 1;
    self.backgroundColor = UIColor.clearColor;
    self.userInteractionEnabled = YES;

    // Root VC required to show window
    UIViewController *rootVC = [[UIViewController alloc] init];
    rootVC.view.backgroundColor = UIColor.clearColor;
    self.rootViewController = rootVC;

    // Draggable floating button — 44×44, top-left
    CGFloat size = 44.0;
    CGFloat margin = 12.0;
    CGFloat topMargin = 56.0; // below status bar
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = CGRectMake(margin, topMargin, size, size);
    btn.backgroundColor = [UIColor systemBlueColor];
    btn.layer.cornerRadius = size / 2.0;
    btn.layer.shadowColor = UIColor.blackColor.CGColor;
    btn.layer.shadowOpacity = 0.35;
    btn.layer.shadowOffset = CGSizeMake(0, 3);
    btn.layer.shadowRadius = 4.0;

    // "B" label inside button
    UILabel *lbl = [[UILabel alloc] initWithFrame:btn.bounds];
    lbl.text = @"B";
    lbl.font = [UIFont boldSystemFontOfSize:20.0];
    lbl.textColor = UIColor.whiteColor;
    lbl.textAlignment = NSTextAlignmentCenter;
    [btn addSubview:lbl];

    [btn addTarget:self action:@selector(openMenu) forControlEvents:UIControlEventTouchUpInside];

    // Pan gesture for dragging
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
    [btn addGestureRecognizer:pan];

    [rootVC.view addSubview:btn];
    [self makeKeyAndVisible];

    return self;
}

- (void)openMenu {
    BFTMenuViewController *menu = [[BFTMenuViewController alloc] init];
    menu.modalPresentationStyle = UIModalPresentationFormSheet;
    menu.modalTransitionStyle = UIModalTransitionStyleCoverVertical;

    UIViewController *presenter = self.rootViewController;
    while (presenter.presentedViewController) {
        presenter = presenter.presentedViewController;
    }
    [presenter presentViewController:menu animated:YES completion:nil];
}

- (void)handlePan:(UIPanGestureRecognizer *)pan {
    UIView *btn = pan.view;
    CGPoint translation = [pan translationInView:self];
    btn.center = CGPointMake(btn.center.x + translation.x, btn.center.y + translation.y);
    [pan setTranslation:CGPointZero inView:self];
}

// Pass touches through to underlying windows when not hitting the button
- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    UIView *hit = [super hitTest:point withEvent:event];
    return (hit == self.rootViewController.view) ? nil : hit;
}

@end

// ---------------------------------------------------------------------------
// Injection — hook UIApplication to spin up our overlay after launch
// ---------------------------------------------------------------------------

static BFTFloatingButton *gFloatingWindow = nil;

%hook UIApplication

- (void)applicationDidBecomeActive:(UIApplication *)application {
    %orig;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        dispatch_async(dispatch_get_main_queue(), ^{
            gFloatingWindow = [[BFTFloatingButton alloc] init];
        });
    });
}

%end
