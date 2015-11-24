//
//  JKUserContentHelper.m
//  JKPhotoListDemo
//
//  Created by Jack on 15/11/20.
//  Copyright © 2015年 宇之楓鷙. All rights reserved.
//

#import "JKUserContentHelper.h"


NSString *  const JKUserContentHelperSelectPhotoChangedNotification = @"JKUserContentHelperSelectPhotoChangedNotification";

static JKUserContentHelper *__contentHelper;
static dispatch_once_t _onceFlag;

@interface JKUserContentHelper ()


@property (nonatomic, strong) NSMutableArray       *selectedPhotos;
@property (nonatomic, strong) NSMutableDictionary  *selectPhotosDic;
//@property (nonatomic, strong) 

@end

@implementation JKUserContentHelper



+ (instancetype)shareInstance{
    if (!__contentHelper) {
        dispatch_once(&_onceFlag, ^{
            __contentHelper = [self new];
        });
    }
    return __contentHelper;
}

- (instancetype)init{
    if (self = [super init]) {
        
    }
    return self;
}

- (void)createNewPhotoSelectContextAndRemoveOldOneWithMaxNum:(NSInteger)maxNum{
    [self invalidateSelectPhotoContext];
    self.selectedPhotos = [NSMutableArray new];
    self.selectPhotosDic = [NSMutableDictionary new];
    self.maxSelectNum = maxNum;
}

- (void)invalidateSelectPhotoContext{
    self.selectedPhotos = nil;
    self.selectPhotosDic = nil;
    self.maxSelectNum = 0;
    
}

- (NSArray *)currentSelectedPhotos{
    if (!self.selectedPhotos) return nil;
    return [NSArray arrayWithArray:self.selectedPhotos];
}

- (void)selectPhoto:(JKPhotoAsset *)photoAsset
{
    [self.selectedPhotos addObject:photoAsset];
    if (![self.selectPhotosDic objectForKey:photoAsset.identifier]) {
        [self.selectPhotosDic setObject:[NSMutableArray new] forKey:photoAsset.identifier];
    }
    [[self.selectPhotosDic objectForKey:photoAsset.identifier]addObject:photoAsset];
    [self notifyPicChanged];
}

- (void)deselectPhoto:(JKPhotoAsset *)photoAsset
{
    if (photoAsset) {
        [self.selectedPhotos removeObject:photoAsset];
        [[self.selectPhotosDic objectForKey:photoAsset.identifier] removeLastObject];
    }
    [self notifyPicChanged];
}


- (void)setCurrentSelectedPhotos:(NSArray *)currentSelectedPhotos
{
    [self.selectedPhotos removeAllObjects];
    [self.selectPhotosDic removeAllObjects];
    for (JKPhotoAsset *photoAsset in currentSelectedPhotos) {
        [self.selectedPhotos addObject:photoAsset];
        if (![self.selectPhotosDic objectForKey:photoAsset.identifier]) {
            [self.selectPhotosDic setObject:[NSMutableArray new] forKey:photoAsset.identifier];
        }
        [[self.selectPhotosDic objectForKey:photoAsset.identifier] addObject:photoAsset];
    }
    [self notifyPicChanged];
}


- (void)addPhotosToContextFromArray:(NSArray *)array{
    for (JKPhotoAsset *photoInfo in array) {
        [self.selectedPhotos addObject:photoInfo];
        if (![self.selectPhotosDic objectForKey:photoInfo.identifier]) {
            [self.selectPhotosDic setObject:[NSMutableArray new] forKey:photoInfo.identifier];
        }
        [[self.selectPhotosDic objectForKey:photoInfo.identifier] addObject:photoInfo];
    }
    [self notifyPicChanged];
}

- (void)deletePhotosFromContextInArray:(NSArray *)array{
    for (JKPhotoAsset *photoInfo in array) {
        [self.selectedPhotos removeObject:photoInfo];
        NSMutableArray *photoArray = [self.selectPhotosDic objectForKey:photoInfo.identifier];
        [photoArray removeObject:photoInfo];
    }
    [self notifyPicChanged];
}

- (JKPhotoAsset *)photoWithSelectedIdentifier:(NSString *)key;
{
    return [[self.selectPhotosDic objectForKey:key] lastObject];
}


- (void)notifyPicChanged{
    [[NSNotificationCenter defaultCenter] postNotificationName:JKUserContentHelperSelectPhotoChangedNotification object:nil];
}


@end
