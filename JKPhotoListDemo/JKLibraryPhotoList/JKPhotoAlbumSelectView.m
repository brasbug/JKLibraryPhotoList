//
//  JKPhotoAlbumSelectView.m
//  apollo
//
//  Created by Jack on 15/11/19.
//  Copyright © 2015年 宇之楓鷙. All rights reserved.
//

#import "JKPhotoAlbumSelectView.h"
#import "JKPhotoAlbumSelectCell.h"


@interface JKPhotoAlbumSelectView ()<UITableViewDataSource,UITableViewDelegate>

@property (nonatomic,strong) UITableView * tableView;

@end


@implementation JKPhotoAlbumSelectView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _tableView = [UITableView new];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        [self addSubview:_tableView];
    }
    return self;
}

- (void)layoutSubviews{
    [super layoutSubviews];
    
    self.tableView.frame = self.bounds;
}

- (void)setAlbums:(NSArray *)albums{
    _albums = albums;
    [self.tableView reloadData];
}




@end
