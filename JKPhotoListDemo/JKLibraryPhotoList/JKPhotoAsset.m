//
//  JKPhotoAsset.m
//  apollo
//
//  Created by Jack on 15/11/19.
//  Copyright © 2015年 宇之楓鷙. All rights reserved.
//

#import "JKPhotoAsset.h"
#import "JKPhotoLibraryTools.h"
#import <Photos/Photos.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import <UIKit/UIKit.h>
#import <ImageIO/ImageIO.h>
#import <CoreImage/CoreImage.h>
#import <ImageIO/ImageIO.h>

@interface JKPhotoAsset ()


@property (nonatomic, strong) PHAsset *photoAsset;
@property (nonatomic, strong) ALAsset *alAsset;
@property (nonatomic, copy)   void(^getFullImageresultBlock)(UIImage *);
@property (nonatomic, copy)   void(^getDisplayResultBlock)(UIImage *);
@property (nonatomic, readwrite, strong) NSDictionary *exif;

@end

@implementation JKPhotoAsset


#pragma mark - property
- (BOOL)isVideo{
    return NO;
}

- (CLLocation *)location{
    if ([JKPhotoLibraryTools photoFrameworkIsValid]) {
        return self.photoAsset.location;
    }
    else {
        return [self.alAsset valueForProperty:ALAssetPropertyLocation];
    }
}


#pragma mark - LifeCycle;
- (instancetype)init{
    return nil;
}

- (instancetype)initInternal{
    if (self = [super init]) {
    }
    return self;
}

- (instancetype)initWithAsset:(id)object{
    if (self = [self initInternal]) {
        if ([JKPhotoLibraryTools photoFrameworkIsValid]) {
            _photoAsset = object;
        }
        else {
            _alAsset = object;
        }
    }
    return self;
}

- (void)getThumbImageWithSize:(CGSize)size withComplete:(void(^)(UIImage *))resultBlock{
    if (self.photoAsset) {
        PHImageRequestOptions *option = [PHImageRequestOptions new];
        option.synchronous = YES;
        option.version = PHImageRequestOptionsVersionCurrent;
        PHImageManager *manager = [PHImageManager defaultManager];
        [manager requestImageForAsset:self.photoAsset targetSize:size contentMode:PHImageContentModeAspectFill options:option resultHandler:^(UIImage * __nullable result, NSDictionary * __nullable info) {
            resultBlock(result);
        }];
    }
    else {
        resultBlock([UIImage imageWithCGImage:self.alAsset.thumbnail]);
    }
}

- (void)getDisplayImagewithComplete:(void(^)(UIImage *))resultBlock{
    if (self.photoAsset) {
        self.getDisplayResultBlock = resultBlock;
        [self performSelectorInBackground:@selector(getDisplayImageBackground) withObject:nil];
    }
    else {
        dispatch_async(dispatch_get_main_queue(), ^{
            NSArray *array = [self.alAsset valueForProperty:ALAssetPropertyRepresentations];
            if (array.count) {
                NSLog(@"%@",array.description);
            }
            UIImage *bigImage = [UIImage imageWithCGImage:[self.alAsset defaultRepresentation].fullScreenImage
                                                    scale:[self.alAsset defaultRepresentation].scale
                                              orientation:UIImageOrientationUp];
            
            resultBlock(bigImage);
        });
    }
}

- (void)getDisplayImageBackground{
    PHImageRequestOptions *option = [PHImageRequestOptions new];
    option.synchronous = YES;
    option.resizeMode = PHImageRequestOptionsResizeModeFast;
    PHImageManager *manager = [PHImageManager defaultManager];
    [manager requestImageForAsset:self.photoAsset targetSize:CGSizeMake([UIScreen mainScreen].bounds.size.height * [UIScreen mainScreen].scale, [UIScreen mainScreen].bounds.size.height * [UIScreen mainScreen].scale) contentMode:PHImageContentModeAspectFill options:option resultHandler:^(UIImage * __nullable result, NSDictionary * __nullable info) {
        if (self.getDisplayResultBlock) {
            dispatch_async(dispatch_get_main_queue(), ^{
                self.getDisplayResultBlock(result);
                self.getDisplayResultBlock = nil;
            });
        }
    }];
}

- (UIImage *)getDisplayImage{
    if (self.photoAsset) {
        PHImageRequestOptions *option = [PHImageRequestOptions new];
        option.synchronous = YES;
        option.resizeMode = PHImageRequestOptionsResizeModeFast;
        option.version = PHImageRequestOptionsVersionCurrent;
        PHImageManager *manager = [PHImageManager defaultManager];
        __block UIImage *returnResult = nil;
        [manager requestImageForAsset:self.photoAsset targetSize:CGSizeMake([UIScreen mainScreen].bounds.size.height * [UIScreen mainScreen].scale, [UIScreen mainScreen].bounds.size.height * [UIScreen mainScreen].scale) contentMode:PHImageContentModeAspectFill options:option resultHandler:^(UIImage * __nullable result, NSDictionary * __nullable info) {
            returnResult = result;
            
        }];
        return returnResult;
    }
    else {
        return [UIImage imageWithCGImage:[self.alAsset defaultRepresentation].fullScreenImage
                                   scale:[self.alAsset defaultRepresentation].scale
                             orientation:UIImageOrientationUp];
    }
}

- (void)getImagewithComplete:(void (^)(UIImage *))resultBlock{
    if (self.photoAsset) {
        self.getFullImageresultBlock = resultBlock;
        [self performSelectorInBackground:@selector(getImageBackground) withObject:nil];
    }
    else {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
            UIImage *bigImage = [self getImageFromAlAssets];
            dispatch_async(dispatch_get_main_queue(), ^{
                resultBlock(bigImage);
            });
        });
    }
}

- (void)getImageBackground{
    PHImageRequestOptions *option = [PHImageRequestOptions new];
    option.synchronous = YES;
    option.version = PHImageRequestOptionsVersionCurrent;
    PHImageManager *manager = [PHImageManager defaultManager];
    [manager requestImageDataForAsset:self.photoAsset options:option resultHandler:^(NSData * _Nullable imageData, NSString * _Nullable dataUTI, UIImageOrientation orientation, NSDictionary * _Nullable info) {
        CGImageSourceRef imageSource = CGImageSourceCreateWithData((__bridge CFDataRef)imageData, NULL);
        self.exif = (__bridge_transfer NSDictionary *)CGImageSourceCopyPropertiesAtIndex(imageSource, 0, NULL);
        if (self.getFullImageresultBlock) {
            dispatch_async(dispatch_get_main_queue(), ^{
                self.getFullImageresultBlock([UIImage imageWithData:imageData]);
                self.getFullImageresultBlock = nil;
            });
        }
    }];
}

- (UIImage *)getImage{
    if (self.photoAsset) {
        PHImageRequestOptions *option = [PHImageRequestOptions new];
        option.synchronous = YES;
        PHImageManager *manager = [PHImageManager defaultManager];
        __block UIImage *returnResult = nil;
        [manager requestImageDataForAsset:self.photoAsset options:option resultHandler:^(NSData * _Nullable imageData, NSString * _Nullable dataUTI, UIImageOrientation orientation, NSDictionary * _Nullable info) {
            CGImageSourceRef imageSource = CGImageSourceCreateWithData((__bridge CFDataRef)imageData, NULL);
            self.exif = (__bridge_transfer NSDictionary *)CGImageSourceCopyPropertiesAtIndex(imageSource, 0, NULL);
            returnResult = [UIImage imageWithData:imageData];
        }];
        return returnResult;
    }
    else {
        return [self getImageFromAlAssets];
        
    }
    
}

- (UIImage *)getImageFromAlAssets{
    ALAssetRepresentation *rep = [self.alAsset defaultRepresentation];
    NSString *adj = [rep metadata][@"AdjustmentXMP"];
    self.exif = rep.metadata;
    if (adj) {
        CGImageRef fullResImage = [rep fullResolutionImage];
        NSData *xmlData = [adj dataUsingEncoding:NSUTF8StringEncoding];
        CIImage *image = [CIImage imageWithCGImage:fullResImage];
        NSError *error = nil;
        NSArray *filters = [CIFilter filterArrayFromSerializedXMP:xmlData
                                                 inputImageExtent:[image extent]
                                                            error:&error];
        CIContext *context = [CIContext contextWithEAGLContext:[[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2]];
        if (filters && !error) {
            for (CIFilter *filter in filters) {
                [filter setValue:image forKey:kCIInputImageKey];
                image = [filter outputImage];
            }
            fullResImage = [context createCGImage:image fromRect:[image extent]];
            UIImage *result = [UIImage imageWithCGImage:fullResImage
                                                  scale:[rep scale]
                                            orientation:(UIImageOrientation)[rep orientation]];
            CGImageRelease(fullResImage);
            return result;
        }
    }
    return [UIImage imageWithCGImage:[[self.alAsset defaultRepresentation] CGImageWithOptions:@{(NSString *)kCGImageSourceCreateThumbnailWithTransform: @(YES)}]
                               scale:[self.alAsset defaultRepresentation].scale
                         orientation:(UIImageOrientation)[self.alAsset defaultRepresentation].orientation];
}


- (NSString *)identifier {
    if (self.photoAsset) {
        return self.photoAsset.localIdentifier;
    }
    else {
        return [[self.alAsset valueForProperty:ALAssetPropertyAssetURL] absoluteString];
    }
}


@end
