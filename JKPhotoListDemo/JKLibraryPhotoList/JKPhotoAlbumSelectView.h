//
//  JKPhotoAlbumSelectView.h
//  apollo
//
//  Created by Jack on 15/11/19.
//  Copyright © 2015年 宇之楓鷙. All rights reserved.
//

#import <UIKit/UIKit.h>
@class JKPhotoCollection;
@interface JKPhotoAlbumSelectView : UIView

@property (nonatomic, strong) NSArray *albums;
@property (nonatomic, copy) void(^photoAlbumSelected)(JKPhotoCollection *collection);

@end
