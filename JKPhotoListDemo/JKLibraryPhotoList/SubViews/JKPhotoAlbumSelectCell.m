//
//  JKPhotoAlbumSelectCell.m
//  JKPhotoListDemo
//
//  Created by Jack on 15/11/24.
//  Copyright © 2015年 宇之楓鷙. All rights reserved.
//

#import "JKPhotoAlbumSelectCell.h"

@implementation JKPhotoAlbumSelectCell


- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        _postImage = [UIImageView new];
        _postImage.contentMode = UIViewContentModeScaleAspectFill;
        _postImage.clipsToBounds = YES;
        [self addSubview:_postImage];
        
        _nameLabel = [UILabel new];
        [self addSubview:_nameLabel];
        
        _countLabel = [UILabel new];
        _countLabel.textColor = [UIColor darkGrayColor];
        _countLabel.font = [UIFont systemFontOfSize:17];
        [self addSubview:_countLabel];
    }
    return self;
}

- (void)layoutSubviews{
    [super layoutSubviews];
    
    self.postImage.size = CGSizeMake(self.height, self.height);
    self.postImage.left = 0;
    self.postImage.top = 0;
    
    [self.nameLabel sizeToFit];
    self.nameLabel.centerY = self.height / 2;
    self.nameLabel.left = self.postImage.right + 10;
    
    [self.countLabel sizeToFit];
    self.countLabel.centerY = self.height / 2;
    self.countLabel.right = self.width - 40;
    
    
}

@end
