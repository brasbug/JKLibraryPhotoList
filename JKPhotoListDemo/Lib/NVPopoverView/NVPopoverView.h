//
//  NVPopoverView.h
//  NVPopoverViewTest
//
//  Created by Yi Lin on 6/18/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, NVPopoverPosition) {
    NVPopoverPositionBelow          = 1,
    NVPopoverPositionScreenBottom   = 2
};

typedef NS_ENUM(NSInteger, NVPopoverDismissAnimationType){
    NVPopoverDismissAnimationTypeNone,
    NVPopoverDismissAnimationTypeFadeout,
    NVPopoverDismissAnimationTypeSlideOut
};

extern NSString *NVPopoverWillAppearNotification;
extern NSString *NVPopoverDidAppearNotification;
extern NSString *NVPopoverWillDismissNotification;
extern NSString *NVPopoverDidDismissNotification;

@protocol NVPopoverViewDelegate;

@interface NVPopoverView : UIView<UIGestureRecognizerDelegate>

@property (weak,nonatomic) id<NVPopoverViewDelegate> delegate;
/**
 *  popoverview中实际展示内容的view
 */
@property (strong,nonatomic) UIView *componentsView;
/**
 *  componentsView相对popoverview的位置
 */
@property (nonatomic, assign) CGPoint componentsViewOrigin;

+ (NVPopoverView *)sharedPopoverView;

+ (BOOL)popoverIsShowed; 

+ (void)dismissPopoverViewAnimated:(BOOL)animate;

+ (void)dismissPopoverViewWithAnimation:(NVPopoverDismissAnimationType)animationType;

/**
 *  展示popoverview，根据targetView和position重新计算popoverview的frame
 */
- (void)showPopoverViewInView:(UIView *)targetView position:(NVPopoverPosition)thePosition animated:(BOOL)animate;

/**
 *  展示popoverview, 需要先自定义popoverview的frame，默认为screen bounds
 */
- (void)showInPosition:(NVPopoverPosition)thePosition animated:(BOOL)animate;

- (void)removeAllSubviews;

@end

@protocol NVPopoverViewDelegate <NSObject>

@optional
- (void)popoverViewWillAppear:(NVPopoverView *)popOverView;
- (void)popoverViewDidAppear:(NVPopoverView *)popOverView;
- (void)popoverViewWillDismiss:(NVPopoverView *)popOverView;
- (void)popoverViewDidDismiss:(NVPopoverView *)popOverView;

@end
