//
//  JKPhotoAsset.h
//  apollo
//
//  Created by Jack on 15/11/19.
//  Copyright © 2015年 季 浩勉. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class UIImage;
@class CLLocation;

@interface JKPhotoAsset : NSObject

@property (nonatomic, readonly) BOOL          isVideo;
@property (nonatomic, readonly) CLLocation   *location;
@property (nonatomic, readonly) NSString     *identifier;
@property (nonatomic, readonly) NSDictionary *exif;

- (void)getThumbImageWithSize:(CGSize)size withComplete:(void(^)(UIImage *))resultBlock;
- (void)getDisplayImagewithComplete:(void(^)(UIImage *))resultBlock;
- (UIImage *)getDisplayImage;
- (void)getImagewithComplete:(void (^)(UIImage *))resultBlock;
- (UIImage *)getImage;
@end
