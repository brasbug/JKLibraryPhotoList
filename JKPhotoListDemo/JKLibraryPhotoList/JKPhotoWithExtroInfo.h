//
//  JKPhotoWithExtroInfo.h
//  JKPhotoListDemo
//
//  Created by Jack on 15/11/20.
//  Copyright © 2015年 宇之楓鷙. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface JKPhotoWithExtroInfo : NSObject

@property (nonatomic, strong) NSMutableArray *tags;
@property (nonatomic, strong) NSMutableArray *stickers;
@property (nonatomic, strong) NSString       *identifier;
@property (nonatomic, strong) NSString       *title;
@property (nonatomic, assign) CGSize         viewSize;

@end
