//
//  JKPhotoLibrary.h
//  apollo
//
//  Created by Jack on 15/11/19.
//  Copyright © 2015年 季 浩勉. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class JKPhotoCollection;


typedef enum : NSInteger {
    JKPLAuthorizationStatusNotDetermined = 0,
    JKPLAuthorizationStatusDenied,
    JKPLAuthorizationStatusAuthorized
} JKPLAuthorizationStatus;


@interface JKPhotoLibrary : NSObject

@property (nonatomic, readonly)  JKPhotoCollection * _Nonnull dianpingAlbum;

+ (nullable instancetype)sharePhotoLibrary;

+ (JKPLAuthorizationStatus)authorizationStatus;


+ (void)requestAuthorizationWithCompletionBlock:(nonnull void(^)(BOOL))completion;

- (void)fetchCollectionsWithCompletionBlock:(nonnull void(^)( NSArray * _Nullable))completion;

- (void)createAlbumWithName:(nonnull NSString *)name withCallBack:(nonnull void(^)(BOOL result))callback;

- (void)saveImageToDianpingAlbum:(nonnull UIImage *)image WithCallBack:(nonnull void(^)(BOOL  result))callback;

//- (void)saveImageToAlbumName:(nonnull NSString *)name album:(nonnull UIImage *)image  WithCallBack:(nonnull void(^)(BOOL  result))callback;

@end
