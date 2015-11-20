//
//  JKUserContentHelper.h
//  JKPhotoListDemo
//
//  Created by Jack on 15/11/20.
//  Copyright © 2015年 宇之楓鷙. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JKPhotoAsset.h"

@interface JKUserContentHelper : NSObject

@property (nonatomic)         NSArray   *currentSelectedPhotos;
@property (nonatomic, assign) NSInteger  maxSelectNum;

+(instancetype)shareInstance;

- (void)createNewPhotoSelectContextAndRemoveOldOneWithMaxNum:(NSInteger)maxNum;
- (void)invalidateSelectPhotoContext;


- (void)selectPhoto:(JKPhotoAsset *)photoAsset;
- (void)deselectPhoto:(JKPhotoAsset *)photoAsset;
- (void)addPhotosToContextFromArray:(NSArray *)array;
- (void)deletePhotosFromContextInArray:(NSArray *)array;
- (JKPhotoAsset *)photoWithSelectedIdentifier:(NSString *)key;

@end
