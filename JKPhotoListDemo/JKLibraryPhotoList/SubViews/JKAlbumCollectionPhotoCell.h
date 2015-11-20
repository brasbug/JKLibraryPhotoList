//
//  JKAlbumCollectionViewCell.h
//  JKPhotoListDemo
//
//  Created by Jack on 15/11/19.
//  Copyright © 2015年 宇之楓鷙. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^selectButtonBlock)(BOOL selected);

@interface JKAlbumCollectionPhotoCell : UICollectionViewCell

@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, assign) selectButtonBlock selectButtonClicked;;
@property (nonatomic, readonly) UIButton *selectButton;



@end

@interface JKAlbumCollectionCamaraCell : UICollectionViewCell

@property (nonatomic, strong) UIImageView *imageView;


@end
