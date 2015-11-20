
//
//  JKPhotoCollection.m
//  apollo
//
//  Created by Jack on 15/11/19.
//  Copyright © 2015年 季 浩勉. All rights reserved.
//

#import "JKPhotoCollection.h"
#import <Photos/Photos.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import "JKPhotoAsset+Private.h"
#import "JKPhotoLibraryTools.h"

@interface JKPhotoCollection ()


@property (nonatomic, strong) NSMutableArray *Assets;
@property (nonatomic, strong) NSString *localIdentifier;
@property (nonatomic, strong) PHAssetCollection *assetCollection;
@property (nonatomic, strong) ALAssetsGroup *assetsGroup;
@property (nonatomic, strong) PHFetchResult *photoFetchResult;


@end

@implementation JKPhotoCollection


#pragma mark - property
- (NSString *)name{
    if (self.assetCollection) {
        return self.assetCollection.localizedTitle;
    }
    else {
        return [self.assetsGroup valueForProperty:ALAssetsGroupPropertyName];
    }
}

- (PHAssetCollection *)assetCollection{
    if (!_assetCollection && _localIdentifier.length) {
        PHFetchResult *result = [PHAssetCollection fetchAssetCollectionsWithLocalIdentifiers:@[self.localIdentifier] options:nil];
        _assetCollection = result.firstObject;
    }
    return _assetCollection;
}


- (PHFetchResult *)photoFetchResult{
    if (!_photoFetchResult) {
        PHFetchOptions *options = [PHFetchOptions new];
        NSSortDescriptor *descriptor = [NSSortDescriptor sortDescriptorWithKey:@"modificationDate" ascending:NO];
        options.sortDescriptors = @[descriptor];
        _photoFetchResult = [PHAsset fetchAssetsInAssetCollection:self.assetCollection options:options];
    }
    return _photoFetchResult;
}

- (NSInteger)count{
    if (self.assetCollection) {
        return [self.photoFetchResult countOfAssetsWithMediaType:PHAssetMediaTypeImage];
    }
    else {
        return [self.assetsGroup numberOfAssets];
    }
}

- (void)getPostImageWithComplete:(void(^)(UIImage *))completion{
    if (self.assetCollection){
        [self performSelectorInBackground:@selector(getPostImageInBackground:) withObject:completion];
    }
    else {
        dispatch_async(dispatch_get_main_queue(), ^{
            completion([UIImage imageWithCGImage:self.assetsGroup.posterImage]);
        });
    }
}

- (void)getPostImageInBackground:(void (^)(UIImage *))completion{
    PHFetchResult *result = [PHAsset fetchKeyAssetsInAssetCollection:self.assetCollection options:nil];
    if (!result.count) {
        dispatch_async(dispatch_get_main_queue(), ^{
            completion(nil);
        });
        return;
    }
    PHAsset *keyImage = [result objectAtIndex:0];
    PHImageRequestOptions *option = [PHImageRequestOptions new];
    option.synchronous = YES;
    PHImageManager *manager = [PHImageManager defaultManager];
    [manager requestImageForAsset:keyImage targetSize:CGSizeMake(200, 200) contentMode:PHImageContentModeAspectFill options:option resultHandler:^(UIImage * __nullable result, NSDictionary * __nullable info) {
        dispatch_async(dispatch_get_main_queue(), ^{
            completion(result);
        });
    }];
}



- (instancetype)init{
    return nil;
}

- (instancetype)initInternal{
    if (self = [super init]) {
        _Assets = [NSMutableArray new];
    }
    return self;
}

- (instancetype)initWithCollectionObject:(id)object{
    if (self = [self initInternal]) {
        if ([JKPhotoLibraryTools photoFrameworkIsValid]) {
            if ([object isKindOfClass:[NSString class]]) {
                _localIdentifier = object;
            } else {
                _assetCollection = object;
            }
        }
        else {
            _assetsGroup = object;
            [_assetsGroup setAssetsFilter:[ALAssetsFilter allPhotos]];
        }
    }
    return self;
}

- (void)preloadPicWithCompletion:(void(^)())completion{
    [self performSelectorInBackground:@selector(readAssetsFromPhotoLibraryWithCompletionBlock:) withObject:completion];
}


- (JKPhotoAsset *)objectAtIndex:(NSInteger)index{
    if (index >= self.count) {
        return nil;
    }
    JKPhotoAsset *result = self.Assets[index];
    if (result) return result;
    return self.Assets[index];
}

- (void)readAssetsFromPhotoLibraryWithCompletionBlock:(void(^)())completion{
    if (self.assetCollection) {
        for (PHAsset *asset in self.photoFetchResult) {
            if (asset.mediaType == PHAssetMediaTypeImage) {
                [self.Assets addObject:[[JKPhotoAsset alloc] initWithAsset:asset]];
            }
        }
    }
    else {
        [self.assetsGroup enumerateAssetsWithOptions:NSEnumerationReverse usingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop) {
            if (result) {
                [self.Assets addObject:[[JKPhotoAsset alloc] initWithAsset:result]];
            }
        }];
    }
    if (completion) {
        dispatch_async(dispatch_get_main_queue(), completion);
    }
}



@end
