//
//  JKPhotoAlbumSelectView.m
//  apollo
//
//  Created by Jack on 15/11/19.
//  Copyright © 2015年 宇之楓鷙. All rights reserved.
//

#import "JKPhotoAlbumSelectView.h"
#import "JKPhotoAlbumSelectCell.h"
#import "JKPhotoCollection.h"

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


#pragma mark- Table View Delegate and DataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return (NSInteger)self.albums.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    JKPhotoAlbumSelectCell *cell = [tableView dequeueReusableCellWithIdentifier:@"albumcell"];
    if (!cell) {
        cell = [[JKPhotoAlbumSelectCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"albumcell"];
    }
    JKPhotoCollection *collection = [self.albums objectAtIndex:indexPath.row];
    [collection getPostImageWithComplete:^(UIImage *result) {
        if (indexPath.row == [tableView indexPathForCell:cell].row) {
            cell.postImage.image = result;
            if (result == nil) {
                cell.postImage.image = [UIImage imageNamed:@"DPNoPicFrame"];
            }
            [cell setNeedsLayout];
        }
    }];
    cell.nameLabel.text = collection.name;
    cell.countLabel.text = [@(collection.count) stringValue];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 72;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    if (self.photoAlbumSelected) {
        self.photoAlbumSelected(self.albums[indexPath.row]);
    }
}






@end
