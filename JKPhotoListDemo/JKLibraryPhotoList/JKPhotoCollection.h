//
//  JKPhotoCollection.h
//  apollo
//
//  Created by Jack on 15/11/19.
//  Copyright © 2015年 宇之楓鷙. All rights reserved.
//

#import <Foundation/Foundation.h>

@class UIImage;
@class JKPhotoAsset;

@interface JKPhotoCollection : NSObject

@property (nonatomic, readonly) NSString *name;
@property (nonatomic, readonly) NSInteger count;

- (JKPhotoAsset *)objectAtIndex:(NSInteger)index;
- (void)preloadPicWithCompletion:(void(^)())completion;
- (void)getPostImageWithComplete:(void(^)(UIImage *))completion;

@end
