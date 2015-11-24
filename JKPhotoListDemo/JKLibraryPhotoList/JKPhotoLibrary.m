//
//  JKPhotoLibrary.m
//  apollo
//
//  Created by Jack on 15/11/19.
//  Copyright © 2015年 宇之楓鷙. All rights reserved.
//

#import "JKPhotoLibrary.h"
#import <Photos/Photos.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import "JKPhotoCollection+Private.h"
#import "JKPhotoLibraryTools.h"

static JKPhotoLibrary *_photoLibrary;


@interface JKPhotoLibrary ()

@property (nonatomic, strong) ALAssetsLibrary *assertLibrary;
@property (nonatomic, strong, readwrite) JKPhotoCollection *dianpingAlbum;



@end


@implementation JKPhotoLibrary

#pragma mark -- property
+ (instancetype)sharePhotoLibrary{
    @synchronized(self) {
        if (_photoLibrary) return _photoLibrary;
        else {
            JKPhotoLibrary *library = [self new];
            _photoLibrary = library;
            return library;
        }
    }
}


+ (JKPLAuthorizationStatus)authorizationStatus{
    if ([JKPhotoLibraryTools photoFrameworkIsValid]) {
        switch ([PHPhotoLibrary authorizationStatus]) {
            case PHAuthorizationStatusDenied:
                return JKPLAuthorizationStatusDenied;
                break;
            case PHAuthorizationStatusRestricted:
                return JKPLAuthorizationStatusDenied;
                break;
            case PHAuthorizationStatusAuthorized:
                return JKPLAuthorizationStatusAuthorized;
                break;
            default:
                return JKPLAuthorizationStatusNotDetermined;
                break;
        }
    }
    switch ([ALAssetsLibrary authorizationStatus]) {
        case ALAuthorizationStatusDenied:
            return JKPLAuthorizationStatusDenied;
            break;
        case ALAuthorizationStatusRestricted:
            return JKPLAuthorizationStatusDenied;
            break;
        case ALAuthorizationStatusAuthorized:
            return JKPLAuthorizationStatusAuthorized;
            break;
        default:
            return JKPLAuthorizationStatusNotDetermined;
            break;
    }
    
}

- (instancetype)init{
    if (self = [super init]) {
        if ([JKPhotoLibraryTools photoFrameworkIsValid]){
        }
        else {
            _assertLibrary = [ALAssetsLibrary new];
        }
    }
    return self;
}

+ (void)requestAuthorizationWithCompletionBlock:(nonnull void(^)(BOOL))completion
{
    if ([self authorizationStatus] == JKPLAuthorizationStatusNotDetermined) {
        if ([JKPhotoLibraryTools photoFrameworkIsValid]) {
            [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
                completion(status == PHAuthorizationStatusAuthorized);
            }];
        }
        else {
            ALAssetsLibrary *library = [ALAssetsLibrary new];
            [library enumerateGroupsWithTypes:ALAssetsGroupAll usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
                *stop = YES;
                dispatch_async(dispatch_get_main_queue(), ^{
                    completion(YES);
                });
            } failureBlock:^(NSError *error) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    completion(NO);
                });
            }];
        }
        return;
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        completion([self authorizationStatus] == JKPLAuthorizationStatusAuthorized);
    });
}

- (void)fetchCollectionsWithCompletionBlock:(nonnull void(^)( NSArray * _Nullable))completion{
    if ([JKPhotoLibraryTools photoFrameworkIsValid]) {
        [self performSelectorInBackground:@selector(fetchPhotoFrameworkCollectionInBackground:) withObject:completion];
        return;
    }
    else {
        NSMutableArray *array = [NSMutableArray array];
        [self.assertLibrary enumerateGroupsWithTypes:ALAssetsGroupSavedPhotos|ALAssetsGroupAlbum usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
            if (!group) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    JKPhotoCollection *defaultCollectiion = [array firstObject];
                    NSMutableArray *newResult = [NSMutableArray new];
                    for (JKPhotoCollection *collection in array) {
                        if (collection.count) {
                            [newResult addObject:collection];
                        }
                    }
                    if (!newResult.count) {
                        [newResult addObject:defaultCollectiion];
                    }
                    completion([NSArray arrayWithArray:newResult]);
                });
                return;
            }
            JKPhotoCollection *collection = [[JKPhotoCollection alloc] initWithCollectionObject:group];
            if ([collection.name isEqualToString:@"大众点评"]) {
                self.dianpingAlbum = collection;
            }
            [array insertObject:collection atIndex:0];
        } failureBlock:^(NSError *error) {
            NSMutableArray *resultArray = [NSMutableArray new];
            NSEnumerator *enumrator = [array reverseObjectEnumerator];
            id object = nil;
            while ((object = enumrator.nextObject)) {
                [resultArray addObject:object];
            }
            completion([NSArray arrayWithArray:array]);
        }];
    }
}

- (void)fetchPhotoFrameworkCollectionInBackground:(void(^)(NSArray *))completion{
    NSMutableArray *array = [NSMutableArray array];
    PHFetchResult *result = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeSmartAlbumUserLibrary options:nil];
    [result enumerateObjectsUsingBlock:^(PHAssetCollection *obj, NSUInteger idx, BOOL * __nonnull stop) {
        [array addObject:[[JKPhotoCollection alloc] initWithCollectionObject:obj]];
    }];
    result = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum subtype:PHAssetCollectionSubtypeAlbumRegular options:nil];
    [result enumerateObjectsUsingBlock:^(PHAssetCollection *obj, NSUInteger idx, BOOL * __nonnull stop) {
        if (!obj.estimatedAssetCount) return;
        JKPhotoCollection *collection = [[JKPhotoCollection alloc] initWithCollectionObject:obj];
        if ([collection.name isEqualToString:@"大众点评"]) {
            self.dianpingAlbum = collection;
        }
        [array addObject:collection];
    }];
    dispatch_async(dispatch_get_main_queue(), ^{
        completion([NSArray arrayWithArray:array]);
    });
}

- (void)createAlbumWithName:(nonnull NSString *)name withCallBack:(nonnull void(^)(BOOL result))callback
{    if (self.assertLibrary) {
        [self.assertLibrary addAssetsGroupAlbumWithName:name resultBlock:^(ALAssetsGroup *group) {
            if (callback) {
                callback(group?YES:NO);
            }
        } failureBlock:^(NSError *error) {
            if (callback) {
                callback(NO);
            }
        }];
    }
    else {
        [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
            PHAssetCollectionChangeRequest *request = [PHAssetCollectionChangeRequest creationRequestForAssetCollectionWithTitle:name];
            self.dianpingAlbum = [[JKPhotoCollection alloc] initWithCollectionObject:request.placeholderForCreatedAssetCollection.localIdentifier];
            
        } completionHandler:^(BOOL success, NSError * _Nullable error) {
            if (callback) {
                callback(success);
            }
        }];
    }
}

- (void)saveImageToDianpingAlbum:(nonnull UIImage *)image WithCallBack:(nonnull void(^)(BOOL  result))callback
{
    if (!self.dianpingAlbum) {
        [self fetchCollectionsWithCompletionBlock:^(NSArray *collections) {
            if (!self.dianpingAlbum) {
                [self createAlbumWithName:@"大众点评" withCallBack:^(BOOL result) {
                    if (!self.dianpingAlbum) {
                        callback(NO);
                        return;
                    }
                    [self saveImageToDianpingAlbum:image WithCallBack:callback];
                }];
                return;
            }
            [self saveImageToDianpingAlbum:image WithCallBack:callback];
        }];
        return;
    }
    if (self.assertLibrary) {
        [self.assertLibrary writeImageToSavedPhotosAlbum:image.CGImage orientation:(ALAssetOrientation)image.imageOrientation completionBlock:^(NSURL *assetURL, NSError *error) {
            if (error) {
                callback(NO);
                return;
            }
            
            [self.assertLibrary assetForURL:assetURL resultBlock:^(ALAsset *asset) {
                if (!assetURL) {
                    callback(NO);
                    return;
                }
                callback([self.dianpingAlbum.assetsGroup addAsset:asset]);
            } failureBlock:^(NSError *error) {
                callback(NO);
            }];
            
        }];
        
    } else {
        [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
            PHAssetChangeRequest *assetsRequest = [PHAssetChangeRequest creationRequestForAssetFromImage:image];
            PHAssetCollectionChangeRequest *request = [PHAssetCollectionChangeRequest changeRequestForAssetCollection:self.dianpingAlbum.assetCollection];
            [request addAssets:@[assetsRequest.placeholderForCreatedAsset]];
        } completionHandler:^(BOOL success, NSError * _Nullable error) {
            callback(success);
        }];
    }
}

- (void)saveImageToAlbumName:(nonnull NSString *)name album:(nonnull UIImage *)image  WithCallBack:(nonnull void(^)(BOOL  result))callback
{
    
}


@end
