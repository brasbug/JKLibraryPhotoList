//
//  NVCustomSegment.m
//  NVCustomSegmentTest
//
//  Created by Yi Lin on 6/18/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//
#import <QuartzCore/QuartzCore.h>
#import "NVPopoverView.h"
#import "UIView+layout.h"

NSString *NVPopoverWillAppearNotification   = @"NVPopoverWillAppearNotification";
NSString *NVPopoverDidAppearNotification    = @"NVPopoverDidAppearNotification";
NSString *NVPopoverWillDismissNotification  = @"NVPopoverWillDismissNotification";
NSString *NVPopoverDidDismissNotification   = @"NVPopoverDidDismissNotification";

static BOOL _isShown = NO;

@interface NVPopoverView()

@property (nonatomic, assign) NVPopoverPosition position;

@end

@implementation NVPopoverView

+ (NVPopoverView *)sharedPopoverView
{
    static NVPopoverView *gPopoverView = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        gPopoverView = [[NVPopoverView alloc] init];
    });
    return gPopoverView;
}

+ (BOOL)popoverIsShowed
{
    return _isShown;
}

+ (void)setShown:(BOOL)show
{
    @synchronized(self) {
        _isShown = show;   
    }
}

#pragma mark - init Methods

- (void)internalInit
{
    self.backgroundColor = [UIColor colorWithWhite:0.25 alpha:0.5];
    self.clipsToBounds = YES;
}

- (id)init 
{
    if(self = [super init]) {
        [self internalInit];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    if(self = [super initWithFrame:frame]) {
        [self internalInit];        
    }
    return self;
}

#pragma mark - Properties
- (void)setComponentsView:(UIView *)theView 
{
    if(theView!= _componentsView) {
        [_componentsView removeFromSuperview];
        _componentsView = theView;
        _componentsViewOrigin = CGPointZero;
        [self addSubview:_componentsView];
        [self setNeedsLayout];
    }
}

- (void)setComponentsViewOrigin:(CGPoint)componentsViewOrigin {
    if (!CGPointEqualToPoint(componentsViewOrigin, _componentsViewOrigin)) {
        _componentsViewOrigin = componentsViewOrigin;
        if (self.componentsView) {
            self.componentsView.origin = componentsViewOrigin;
            [self setNeedsLayout];
        }
    }
}

#pragma mark - Layouts Views
- (void)layoutSubviews
{
    [super layoutSubviews];
}

#pragma mark - Actions & out interface

- (void)showPopoverViewInView:(UIView *)targetView position:(NVPopoverPosition)thePosition animated:(BOOL)animate
{
    self.position = thePosition;
    CGRect selfBounds = [UIScreen mainScreen].bounds;
    CGRect targetViewFrameInScreen = [targetView.superview convertRect:targetView.frame toView:nil];
    
    if(CGRectIsNull(targetViewFrameInScreen) || CGRectIsEmpty(targetViewFrameInScreen))
        targetViewFrameInScreen = targetView.frame;
    
    if(self.position == NVPopoverPositionBelow) {
        const CGFloat yOffset = (targetViewFrameInScreen.origin.y + targetViewFrameInScreen.size.height);
        selfBounds.size.height -= yOffset;
        selfBounds.origin.y = yOffset;
    }
    
    self.frame = selfBounds;
    
    [self showInPosition:thePosition animated:animate];
}

- (void)showInPosition:(NVPopoverPosition)thePosition animated:(BOOL)animate {
    self.position = thePosition;
    if (CGRectEqualToRect(self.frame, CGRectZero)) {
        self.frame = [UIScreen mainScreen].bounds;
    }
    
    self.componentsView.origin = self.componentsViewOrigin;
    
    const UIWindow *keyWin = [UIApplication sharedApplication].keyWindow;
    
    //only allow one instance in front of the win
    NSArray *winSubViews = keyWin.subviews;
    UIView *theView = [winSubViews lastObject];
    if([theView isKindOfClass:[self class]]) {
        [NVPopoverView dismissPopoverViewAnimated:NO];
    }
    
    //add new popover view
    [keyWin addSubview:self];
    [NVPopoverView setShown:YES];
    
    void (^appearDelegateCallback)(BOOL finished) = ^(BOOL finished) {
        //delegate callback
        if([self.delegate respondsToSelector:@selector(popoverViewDidAppear:)]) {
            [self.delegate popoverViewDidAppear:self];
        }
        
        [[NSNotificationCenter defaultCenter] postNotificationName:NVPopoverDidAppearNotification
                                                            object:self
                                                          userInfo:nil];
    };
    
    if([self.delegate respondsToSelector:@selector(popoverViewWillAppear:)]) {
        [self.delegate popoverViewWillAppear:self];
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:NVPopoverWillAppearNotification
                                                        object:self
                                                      userInfo:nil];
    if(animate) {
        [self layoutSubviews];
        
        const CGPoint rightOrigin = self.componentsView.origin;
        CGPoint startOrigin = rightOrigin;
        if (self.position == NVPopoverPositionBelow) {
            startOrigin.y -= self.componentsView.height;
        }
        else if (self.position == NVPopoverPositionScreenBottom) {
            startOrigin.y += self.componentsView.height;
        }
        
        self.componentsView.origin = startOrigin;
        [UIView animateWithDuration:0.5
                              delay:0
                            options:UIViewAnimationOptionCurveEaseInOut
                         animations:^{
                             self.componentsView.origin = rightOrigin;
                         } completion:appearDelegateCallback];
        
    }
    else {
        appearDelegateCallback(YES);
    }
}

+ (void)dismissPopoverViewAnimated:(BOOL)animate
{
    if (animate) {
        [NVPopoverView dismissPopoverViewWithAnimation:NVPopoverDismissAnimationTypeFadeout];
    } else {
        [NVPopoverView dismissPopoverViewWithAnimation:NVPopoverDismissAnimationTypeNone];
    }
}

+ (void)dismissPopoverViewWithAnimation:(NVPopoverDismissAnimationType)animationType {
    const UIWindow *keyWin = [UIApplication sharedApplication].keyWindow;
    NSArray *winSubViews = keyWin.subviews;
    
    if([NVPopoverView popoverIsShowed]) {
        UIView *theView = nil;
        for (UIView *view in winSubViews) {
            if([view isKindOfClass:[self class]]) {
                theView = view;
                break;
            }
        }
        //not Found
        if(!theView)
            return;
        
        NVPopoverView *popoverView = (NVPopoverView *)theView;
        
        // Found remove
        void (^viewDismissLogic)(BOOL finished) = ^(BOOL finished) {
            [theView removeFromSuperview];
            
            if([popoverView.delegate respondsToSelector:@selector(popoverViewDidDismiss:)]) {
                [popoverView.delegate popoverViewDidDismiss:popoverView];
            }
            
            [[NSNotificationCenter defaultCenter] postNotificationName:NVPopoverDidDismissNotification
                                                                object:self
                                                              userInfo:nil];
            
            [NVPopoverView setShown:NO];
            popoverView.alpha = 1;
        };
        
        if([popoverView.delegate respondsToSelector:@selector(popoverViewWillDismiss:)]) {
            [popoverView.delegate popoverViewWillDismiss:popoverView];
        }
        
        [[NSNotificationCenter defaultCenter] postNotificationName:NVPopoverWillDismissNotification
                                                            object:self
                                                          userInfo:nil];
        
        if(animationType == NVPopoverDismissAnimationTypeFadeout) {
            [UIView animateWithDuration:0.25
                             animations:^{
                                 popoverView.alpha = 0;
                             } completion:viewDismissLogic];
        } else if(animationType == NVPopoverDismissAnimationTypeSlideOut) {
            CGPoint targetOrigin = popoverView.componentsView.origin;
            
            if (popoverView.position == NVPopoverPositionBelow) {
                targetOrigin.y -= popoverView.componentsView.height;
            }
            else if (popoverView.position == NVPopoverPositionScreenBottom) {
                targetOrigin.y += popoverView.componentsView.height;
            }
            [UIView animateWithDuration:0.3
                                  delay:0
                                options:UIViewAnimationOptionCurveEaseInOut
                             animations:^{
                                 popoverView.componentsView.origin = targetOrigin;
                             } completion:viewDismissLogic];

        } else {
            viewDismissLogic(YES);
        }
    }
}

- (void)removeAllSubviews
{
    NSArray *array = self.subviews;
    for(UIView *theView in array) {
        [theView removeFromSuperview];
    }
}

#pragma mark - private methods

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    if (self.position == NVPopoverPositionScreenBottom) {
        [NVPopoverView dismissPopoverViewWithAnimation:NVPopoverDismissAnimationTypeSlideOut];
    } else {
        [NVPopoverView dismissPopoverViewAnimated:YES];
    }
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    if (gestureRecognizer.view != touch.view) {
        return NO;
    }
    return YES;
}

- (void)dealloc
{
    self.delegate = nil;
}

@end
