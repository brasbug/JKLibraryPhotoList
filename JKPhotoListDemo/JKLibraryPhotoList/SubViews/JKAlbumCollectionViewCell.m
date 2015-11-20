//
//  JKAlbumCollectionViewCell.m
//  JKPhotoListDemo
//
//  Created by Jack on 15/11/19.
//  Copyright © 2015年 宇之楓鷙. All rights reserved.
//

#import "JKAlbumCollectionViewCell.h"



@interface JKAlbumCollectionPhotoCell ()
@property (nonatomic, readwrite, strong) UIButton *selectButton;


@end

@implementation JKAlbumCollectionPhotoCell


- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        _imageView = [UIImageView new];
        _imageView.contentMode = UIViewContentModeScaleAspectFill;
        _imageView.clipsToBounds = YES;
        [self.contentView addSubview:_imageView];
        
        _selectButton = [UIButton new];
        [_selectButton setImage:[UIImage imageNamed:@"addpic_icon_pitchon_rest"] forState:UIControlStateNormal];
        [_selectButton setImage:[UIImage imageNamed:@"addpic_icon_pitchon"] forState:UIControlStateSelected];
        [_selectButton addTarget:self action:@selector(buttonClicked) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:_selectButton];
    }
    return self;
}

- (void)layoutSubviews{
    [super layoutSubviews];
    
    self.imageView.frame = self.contentView.bounds;
    
    self.selectButton.size = CGSizeMake(self.width / 2, self.height / 2);
    self.selectButton.left = self.width / 2;
    self.selectButton.top = 0;
    self.selectButton.imageEdgeInsets = UIEdgeInsetsMake(10 * self.width / 100 , 10* self.width / 100, 10* self.width / 100, 10* self.width / 100 );
    
}

- (void)buttonClicked{
    if (self.selectButtonClicked) {
        BOOL result =  self.selectButtonClicked(!self.selectButton.isSelected);
        if (result) {
            self.selectButton.selected = !self.selectButton.isSelected;
        }
    }
}



@end

@implementation JKAlbumCollectionCamaraCell

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        _imageView = [UIImageView new];
        _imageView.contentMode = UIViewContentModeCenter;
        _imageView.image = [UIImage imageNamed:@"uploadpic_album_icon_camera"];
        _imageView.clipsToBounds = YES;
        
        self.contentView.backgroundColor = [UIColor whiteColor];
        [self.contentView addSubview:_imageView];
    }
    return self;
}

- (void)layoutSubviews{
    [super layoutSubviews];
    
    self.imageView.frame = self.contentView.bounds;
}


@end

