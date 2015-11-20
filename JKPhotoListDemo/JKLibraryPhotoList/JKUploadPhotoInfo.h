//
//  JKUploadPhotoInfo.h
//  JKPhotoListDemo
//
//  Created by Jack on 15/11/20.
//  Copyright © 2015年 宇之楓鷙. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JKPhotoAsset.h"

typedef enum {
    JKPhotoProcessTypeClip        = 1,
    JKPhotoProcessTypeCompression = 1<<1,
    JKPhotoProcessTypeCompose     = 1<<2,
    JKPhotoProcessTypeSaveImage   = 1<<3,
} UGCPhotoProcessType;

@interface JKUploadPhotoInfo : NSObject


@property (nonatomic, assign)   CGSize              photoSize;
@property (nonatomic, strong)   NSString           *filePath;
@property (nonatomic, strong)   NSString           *fileName;
@property (nonatomic, readonly) unsigned long long  fileSize;
@property (nonatomic, strong)   NSString           *fileID;
@property (nonatomic, assign)   NSInteger           picID;
@property (nonatomic, strong)   NSNumber           *lng;
@property (nonatomic, strong)   NSNumber           *lat;
@property (nonatomic, assign)   BOOL                isUploadByQCloud;
@property (nonatomic, strong)   NSString           *callID;
@property (nonatomic, strong)   NSNumber           *result;
@property (nonatomic, assign)   BOOL                binded;
@property (nonatomic, strong)   UIImage            *image;
@property (nonatomic, strong)   NSURL              *remoteUrl;
@property (nonatomic, strong)   NSURL              *thumbUrl;
@property (nonatomic, assign)   NSInteger           processFlag;
@property (nonatomic, assign)   NSInteger           processResultFlag;
@property (nonatomic, assign)   CGRect              clipRect;
@property (nonatomic, strong)   JKPhotoAsset      *photoAsset;
@property (nonatomic, strong)   NSDictionary       *exif;

//Temp
+ (instancetype)photoInfoWithFilePath:(NSString *)filePath;

- (void)saveImageToFilePathOnBackground;
- (void)saveImageToFilePathWithImage:(UIImage *)image;
- (void)deleteImageFromFilePath;

@end
