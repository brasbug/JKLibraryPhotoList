//
//  JKPhotoLibraryTools.m
//  JKPhotoListDemo
//
//  Created by Jack on 15/11/19.
//  Copyright © 2015年 宇之楓鷙. All rights reserved.
//

#import "JKPhotoLibraryTools.h"

@implementation JKPhotoLibraryTools
+ (BOOL)photoFrameworkIsValid{
    return NSFoundationVersionNumber > NSFoundationVersionNumber_iOS_7_1;
}

@end
