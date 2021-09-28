//
// NXNavigationExtensionPrivate.m
//
// Copyright (c) 2020 Leo Lee NXNavigationExtension (https://github.com/l1Dan/NXNavigationExtension)
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import "NXNavigationExtensionPrivate.h"
#import "NXNavigationExtensionRuntime.h"
#import "UIViewController+NXNavigationExtension.h"


@implementation NXEdgeGestureRecognizerDelegate

- (instancetype)initWithNavigationController:(UINavigationController *)navigationController {
    if (self = [super init]) {
        _navigationController = navigationController;
    }
    return self;
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    if (!self.navigationController) {
        return YES;
    }
    
    UIViewController *topViewController = self.navigationController.viewControllers.lastObject;
    if (topViewController && topViewController.nx_disableInteractivePopGesture) {
        return NO;
    }
    
    NSArray<UIViewController *> *viewControllers = self.navigationController.viewControllers;
    UIViewController *destinationViewController = (viewControllers && viewControllers.count > 1) ? viewControllers[viewControllers.count - 2] : topViewController;
    if (self.navigationController.nx_useNavigationBar && topViewController && [topViewController respondsToSelector:@selector(nx_navigationController:willPopViewController:interactiveType:)]) {
        return [(id<NXNavigationInteractable>)topViewController nx_navigationController:self.navigationController
                                                                  willPopViewController:destinationViewController
                                                                        interactiveType:NXNavigationInteractiveTypePopGestureRecognizer];
    }
    
    return YES;
}

@end


@implementation NXFullscreenPopGestureRecognizerDelegate

- (instancetype)initWithNavigationController:(UINavigationController *)navigationController {
    if (self = [super init]) {
        _navigationController = navigationController;
    }
    return self;
}

- (BOOL)gestureRecognizerShouldBegin:(UIPanGestureRecognizer *)gestureRecognizer {
    // Ignore when no view controller is pushed into the navigation stack.
    if (self.navigationController.viewControllers.count <= 1) {
        return NO;
    }
    
    // Ignore when the active view controller doesn't allow interactive pop.
    UIViewController *topViewController = self.navigationController.viewControllers.lastObject;
    if (!topViewController.nx_enableFullscreenInteractivePopGesture) {
        return NO;
    }
    
    // Ignore when the beginning location is beyond max allowed initial distance to left edge.
    CGPoint beginningLocation = [gestureRecognizer locationInView:gestureRecognizer.view];
    CGFloat maxAllowedInitialDistance = topViewController.nx_interactivePopMaxAllowedDistanceToLeftEdge;
    if (maxAllowedInitialDistance > 0 && beginningLocation.x > maxAllowedInitialDistance) {
        return NO;
    }
    
    // Ignore pan gesture when the navigation controller is currently in transition.
    if ([[self.navigationController valueForKey:@"_isTransitioning"] boolValue]) {
        return NO;
    }
    
    // Prevent calling the handler when the gesture begins in an opposite direction.
    CGPoint translation = [gestureRecognizer translationInView:gestureRecognizer.view];
    BOOL isLeftToRight = [UIApplication sharedApplication].userInterfaceLayoutDirection == UIUserInterfaceLayoutDirectionLeftToRight;
    CGFloat multiplier = isLeftToRight ? 1 : -1;
    if ((translation.x * multiplier) <= 0) {
        return NO;
    }
    
    NSArray<UIViewController *> *viewControllers = self.navigationController.viewControllers;
    UIViewController *destinationViewController = (viewControllers && viewControllers.count > 1) ? viewControllers[viewControllers.count - 2] : topViewController;
    if (self.navigationController.nx_useNavigationBar && topViewController && [topViewController respondsToSelector:@selector(nx_navigationController:willPopViewController:interactiveType:)]) {
        return [(id<NXNavigationInteractable>)topViewController nx_navigationController:self.navigationController
                                                                  willPopViewController:destinationViewController
                                                                        interactiveType:NXNavigationInteractiveTypePopGestureRecognizer];
    }
    
    return YES;
}

@end


@implementation UIScrollView (NXNavigationExtensionPrivate)

- (NXNavigationBar *)nx_navigationBar {
    return objc_getAssociatedObject(self, _cmd);
}

- (void)setNx_navigationBar:(NXNavigationBar *)nx_navigationBar {
    objc_setAssociatedObject(self, @selector(nx_navigationBar), nx_navigationBar, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NXNavigationExtensionExtendImplementationOfVoidMethodWithoutArguments([UIScrollView class], @selector(removeFromSuperview), ^(__kindof UIScrollView * _Nonnull selfObject) {
            if (selfObject.nx_navigationBar) {
                [selfObject.nx_navigationBar removeFromSuperview];
            }
        });
        
        NXNavigationExtensionExtendImplementationOfVoidMethodWithoutArguments([UIScrollView class], @selector(didMoveToSuperview), ^(__kindof UIScrollView * _Nonnull selfObject) {
            if (selfObject.nx_navigationBar && selfObject.superview != selfObject.nx_navigationBar) {
                [selfObject.superview addSubview:selfObject.nx_navigationBar];
                [selfObject.superview bringSubviewToFront:selfObject.nx_navigationBar];
                [selfObject.superview bringSubviewToFront:selfObject.nx_navigationBar.contentView];
            }
        });
    });
}

@end


@implementation UINavigationBar (NXNavigationExtensionPrivate)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NXNavigationExtensionExtendImplementationOfVoidMethodWithoutArguments([UINavigationBar class], @selector(layoutSubviews), ^(__kindof UINavigationBar * _Nonnull selfObject) {
            UINavigationBarDidUpdatePropertiesHandler didUpdatePropertiesHandler = selfObject.nx_didUpdatePropertiesHandler;
            if (didUpdatePropertiesHandler) {
                didUpdatePropertiesHandler(selfObject);
            }
        });
        
        NXNavigationExtensionOverrideImplementation([UINavigationBar class], @selector(setUserInteractionEnabled:), ^id _Nonnull(__unsafe_unretained Class  _Nonnull originClass, SEL  _Nonnull originCMD, IMP  _Nonnull (^ _Nonnull originalIMPProvider)(void)) {
            return ^(UINavigationBar *selfObject, BOOL userInteractionEnabled) {
                void (*originSelectorIMP)(id, SEL, BOOL);
                originSelectorIMP = (void (*)(id, SEL, BOOL))originalIMPProvider();
                
                if (!selfObject.nx_userInteractionEnabled) {
                    originSelectorIMP(selfObject, originCMD, NO);
                    return;
                }
                originSelectorIMP(selfObject, originCMD, userInteractionEnabled);
            };
        });
        
        NXNavigationExtensionOverrideImplementation([UINavigationBar class], @selector(setHidden:), ^id _Nonnull(__unsafe_unretained Class  _Nonnull originClass, SEL  _Nonnull originCMD, IMP  _Nonnull (^ _Nonnull originalIMPProvider)(void)) {
            return ^(UINavigationBar *selfObject, BOOL hidden) {
                void (*originSelectorIMP)(id, SEL, BOOL);
                originSelectorIMP = (void (*)(id, SEL, BOOL))originalIMPProvider();
                originSelectorIMP(selfObject, originCMD, hidden);

                UINavigationBarDidUpdatePropertiesHandler didUpdatePropertiesHandler = selfObject.nx_didUpdatePropertiesHandler;
                if (didUpdatePropertiesHandler) {
                    didUpdatePropertiesHandler(selfObject);
                }
            };
        });
        
    });
}

#pragma mark - Getter & Setter

- (UINavigationBarDidUpdatePropertiesHandler)nx_didUpdatePropertiesHandler {
    return objc_getAssociatedObject(self, _cmd);
}

- (void)setNx_didUpdatePropertiesHandler:(UINavigationBarDidUpdatePropertiesHandler)nx_didUpdatePropertiesHandler {
    objc_setAssociatedObject(self, @selector(nx_didUpdatePropertiesHandler), nx_didUpdatePropertiesHandler, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (BOOL)nx_userInteractionEnabled {
    NSNumber *userInteractionEnabled = objc_getAssociatedObject(self, _cmd);
    if (userInteractionEnabled && [userInteractionEnabled isKindOfClass:[NSNumber class]]) {
        return [userInteractionEnabled boolValue];
    }
    userInteractionEnabled = [NSNumber numberWithBool:YES];
    objc_setAssociatedObject(self, _cmd, userInteractionEnabled, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    return [userInteractionEnabled boolValue];
}

- (void)setNx_userInteractionEnabled:(BOOL)nx_userInteractionEnabled {
    objc_setAssociatedObject(self, @selector(nx_userInteractionEnabled), [NSNumber numberWithBool:nx_userInteractionEnabled], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end


@implementation UIViewController (NXNavigationExtensionPrivate)

- (void)nx_configureNavigationBarWithNavigationController:(__kindof UINavigationController *)navigationController backButtonMenuSupported:(BOOL)supported {
    if (@available(iOS 14.0, *)) {
        if (self.nx_backButtonMenuEnabled) {
            NSAssert(supported, @"需要设置 NXNavigationBarAppearance backButtonMenuSupported 属性为 YES 才能生效");
            if (supported && !self.navigationItem.leftItemsSupplementBackButton) {
                self.navigationItem.leftBarButtonItem = nil;
                self.navigationItem.leftBarButtonItems = nil;
                return;
            }
        }
    }
    
    UIBarButtonItem *backButtonItem = self.navigationItem.leftBarButtonItem;
    UIView *customView = self.nx_backButtonCustomView;
    if (customView) {
        backButtonItem = [[UIBarButtonItem alloc] initWithCustomView:customView];
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(nx_triggerSystemPopViewController)];
        customView.userInteractionEnabled = YES;
        [customView addGestureRecognizer:tap];
    } else {
        // 如果 leftBarButtonItem(s) 为空则添加 backButtonItem
        if (!backButtonItem) {
            NXNavigationBarAppearance *barAppearance = navigationController ? navigationController.nx_appearance : [NXNavigationBarAppearance standardAppearance];
            UIImage *backImage = self.nx_backImage ?: barAppearance.backImage;
            UIImage *landscapeBackImage = self.nx_backImage ?: barAppearance.landscapeBackImage;
            
            backButtonItem = [[UIBarButtonItem alloc] initWithImage:backImage landscapeImagePhone:landscapeBackImage style:UIBarButtonItemStylePlain target:self action:@selector(nx_triggerSystemPopViewController)];
            backButtonItem.imageInsets = self.nx_backImageInsets;
            backButtonItem.landscapeImagePhoneInsets = self.nx_landscapeBackImageInsets;
        }
    }
    self.navigationItem.leftBarButtonItem = backButtonItem;
}

/// 保证 self.navigationController 不为 nil，不要直接调研 navigationController 方法
- (void)nx_triggerSystemPopViewController {
    if (self.navigationController) {
        NSArray<UIViewController *> *viewControllers = self.navigationController.viewControllers;
        UIViewController *destinationViewController = (viewControllers && viewControllers.count > 1) ? viewControllers[viewControllers.count - 2] : nil;
        [self.navigationController nx_triggerSystemPopViewController:destinationViewController
                                                     interactiveType:NXNavigationInteractiveTypeBackButtonAction
                                                             handler:^id _Nonnull(UINavigationController * _Nonnull navigationController) {
            return [navigationController popViewControllerAnimated:YES];
        }];
    }
}

@end


@implementation UINavigationController (NXNavigationExtensionPrivate)

- (NXEdgeGestureRecognizerDelegate *)nx_gestureDelegate {
    return objc_getAssociatedObject(self, _cmd);
}

- (void)setNx_gestureDelegate:(NXEdgeGestureRecognizerDelegate *)nx_gestureDelegate {
    objc_setAssociatedObject(self, @selector(nx_gestureDelegate), nx_gestureDelegate, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NXFullscreenPopGestureRecognizerDelegate *)nx_fullscreenPopGestureDelegate {
    NXFullscreenPopGestureRecognizerDelegate *delegate = objc_getAssociatedObject(self, _cmd);
    if (delegate && [delegate isKindOfClass:[NXFullscreenPopGestureRecognizerDelegate class]]) {
        return delegate;
    }
    delegate = [[NXFullscreenPopGestureRecognizerDelegate alloc] initWithNavigationController:self];
    objc_setAssociatedObject(self, _cmd, delegate, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    return delegate;
}

- (NXNavigationBarAppearance *)nx_appearance {
    return [NXNavigationBar appearanceInNavigationController:self];
}

- (BOOL)nx_useNavigationBar {
    return self.nx_appearance != nil;
}

- (void)nx_configureNavigationBar {
    [self.navigationBar setBackgroundImage:[[UIImage alloc] init] forBarMetrics:UIBarMetricsDefault];
    [self.navigationBar setShadowImage:[[UIImage alloc] init]];
    [self.navigationBar setTranslucent:YES];
    
    self.nx_gestureDelegate = [[NXEdgeGestureRecognizerDelegate alloc] initWithNavigationController:self];
    self.interactivePopGestureRecognizer.delegate = self.nx_gestureDelegate;
}

- (id)nx_triggerSystemPopViewController:(__kindof UIViewController *)viewController
                        interactiveType:(NXNavigationInteractiveType)interactiveType
                                handler:(id (^)(UINavigationController *navigationController))handler {
    if (self.viewControllers.count <= 1) return nil;
    
    UIViewController *topViewController = self.topViewController;
    if (self.nx_useNavigationBar && topViewController && [topViewController respondsToSelector:@selector(nx_navigationController:willPopViewController:interactiveType:)]) {
        UIViewController *destinationViewController = viewController ?: topViewController;
        if ([(id<NXNavigationInteractable>)topViewController nx_navigationController:self
                                                               willPopViewController:destinationViewController
                                                                     interactiveType:interactiveType]) {
            return handler(topViewController.navigationController);
        }
    } else {
        return handler(topViewController.navigationController);
    }
    return nil;
}

@end
