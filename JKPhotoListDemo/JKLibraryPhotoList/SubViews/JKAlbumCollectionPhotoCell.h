//
//  JKAlbumCollectionViewCell.h
//  JKPhotoListDemo
//
//  Created by Jack on 15/11/19.
//  Copyright © 2015年 宇之楓鷙. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface JKAlbumCollectionPhotoCell : UICollectionViewCell

@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, readonly) UIButton *selectButton;
@property (nonatomic, strong) BOOL (^selectButtonClicked)(BOOL);


@end

@interface JKAlbumCollectionCamaraCell : UICollectionViewCell

@property (nonatomic, strong) UIImageView *imageView;


@end
