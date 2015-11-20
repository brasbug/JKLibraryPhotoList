//
//  JKPhotoCollection+Private.h
//  JKPhotoListDemo
//
//  Created by Jack on 15/11/19.
//  Copyright © 2015年 宇之楓鷙. All rights reserved.
//

#import "JKPhotoCollection.h"



@interface JKPhotoCollection (Private)

@property (nonatomic, strong) ALAssetsGroup *assetsGroup;
@property (nonatomic, strong) PHAssetCollection *assetCollection;

- (instancetype)initWithCollectionObject:(id)object;

@end
