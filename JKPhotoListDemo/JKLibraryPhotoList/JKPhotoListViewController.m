//
//  JKPhotoListViewController.m
//  apollo
//
//  Created by Jack on 15/11/19.
//  Copyright © 2015年 季 浩勉. All rights reserved.
//

#import "JKPhotoListViewController.h"
#import "CHTCollectionViewWaterfallLayout.h"
#import "JKPhotoCollection.h"
#import "JKAlbumCollectionViewCell.h"
#import "JKPhotoAsset.h"


@interface JKPhotoListViewController ()<UICollectionViewDataSource,UICollectionViewDelegate,CHTCollectionViewDelegateWaterfallLayout>

@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) JKPhotoCollection                *activeCollection;
//@property (nonatomic, strong)

@end

@implementation JKPhotoListViewController



- (instancetype)init
{
    if (self= [super init]) {
        
    }
    return self;
}

- (UICollectionView *)collectionView
{
    if (_collectionView) {
        return _collectionView;
    }
    
    CGFloat margin = 15;
    CGFloat balanceValue = 100;
    NSInteger viewCount = [UIScreen mainScreen].bounds.size.width / balanceValue;
    CGFloat width = self.view.width -( viewCount - 1 ) * 10 - 30;
    width = width / viewCount;
    
    UICollectionViewFlowLayout *layout = [UICollectionViewFlowLayout new];
        layout.itemSize = CGSizeMake(width, width);
    layout.sectionInset = UIEdgeInsetsMake(margin, margin, margin, margin);
    layout.minimumInteritemSpacing = 10;
    layout.minimumLineSpacing = layout.minimumInteritemSpacing;
    
    _collectionView = [[UICollectionView alloc]initWithFrame:KWindowRect collectionViewLayout:layout];
    _collectionView.delegate = self;
    _collectionView.dataSource = self;
    _collectionView.backgroundColor = [UIColor clearColor];
    
    
    
    return _collectionView;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title = @"相册";
    
    [self.view addSubview:self.collectionView];
    
}


#pragma mark - UICollectionViewDelegate and DataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.activeCollection.count + 1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    if (!indexPath.row) {
        JKAlbumCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cameraCell" forIndexPath:indexPath];
        return cell;
    }
    else {
        JKAlbumCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"photoCell" forIndexPath:indexPath];
        JKPhotoAsset *asset = [self.activeCollection objectAtIndex:indexPath.row - 1];
        @weakify(self);
        [asset getThumbImageWithSize:CGSizeMake(self.cellWidth * [UIScreen mainScreen].scale, self.cellWidth * [UIScreen mainScreen].scale) withComplete:^(UIImage *result) {
            @strongify(self);
            cell.imageView.image = result;
        }];
        cell.selectButton.selected = [selectArray containsObject:asset.identifier];
        cell.selectButtonClicked = ^(BOOL selected){
            @strongify(self);
            UGCPhotoAsset *asset = [self.activeCollection objectAtIndex:indexPath.row - 1];
            if (selected) {
                return [self selectAsset:asset];
            }
            else {
                return [self deselectAsset:asset];
            }
            
        };
        return cell;
    }
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    [collectionView deselectItemAtIndexPath:indexPath animated:NO];
    if (!indexPath.row) {
        if (self.ucHelper.currentSelectedPhotos.count == self.maxnum) {
        } else {
            [self ga_logEventType:NVGaEventTypeTap forLabel:@"camera" userInfo:self.ga_userinfo];
            [self openCamera];
        }
        return;
    }
    [self ga_logEventType:NVGaEventTypeTap forLabel:@"onePreview" userInfo:self.ga_userinfo];
    [self showPreviewWithIndex:@(indexPath.row - 1)];
}

@end
