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
#import "JKPhotoAsset.h"
#import "JKPhotoLibrary.h"

#import "JKAlbumCollectionPhotoCell.h"

@interface JKPhotoListViewController ()<UICollectionViewDataSource,UICollectionViewDelegate,CHTCollectionViewDelegateWaterfallLayout>

@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) JKPhotoCollection                *activeCollection;
@property (nonatomic, strong) JKPhotoLibrary                   *photoLibrary;
@property (nonatomic, strong) NSArray                           *photoAlbums;
@property (nonatomic, assign) NSUInteger                         maxnum;


@property (nonatomic, assign) CGFloat cellWidth;
//@property (nonatomic, strong)

@end


NSMutableArray *selectArray;
NSMutableArray *selectPhotoInfos;

@implementation JKPhotoListViewController


- (UICollectionView *)collectionView
{
    if (_collectionView) {
        return _collectionView;
    }
    
    CGFloat balanceValue = 100;
    NSInteger viewCount = [UIScreen mainScreen].bounds.size.width / balanceValue;
    CGFloat width = self.view.width -( viewCount - 1 ) * 10 - 30;
    width = width / viewCount;
    _cellWidth = width;
    CGFloat margin = 15;
    UICollectionViewFlowLayout *layout = [UICollectionViewFlowLayout new];
        layout.itemSize = CGSizeMake(self.cellWidth, self.cellWidth);
    layout.sectionInset = UIEdgeInsetsMake(margin, margin, margin, margin);
    layout.minimumInteritemSpacing = 10;
    layout.minimumLineSpacing = layout.minimumInteritemSpacing;
    
    _collectionView = [[UICollectionView alloc]initWithFrame:KWindowRect collectionViewLayout:layout];
    _collectionView.delegate = self;
    _collectionView.dataSource = self;
    
    [self.collectionView registerClass:[JKAlbumCollectionPhotoCell class] forCellWithReuseIdentifier:@"photoCell"];
    [self.collectionView registerClass:[JKAlbumCollectionCamaraCell class] forCellWithReuseIdentifier:@"cameraCell"];
    _collectionView.backgroundColor = [UIColor clearColor];
    
    
    
    return _collectionView;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    selectArray = [NSMutableArray new];
    selectPhotoInfos = [NSMutableArray new];
    self.title = @"相册";
    
    [self.view addSubview:self.collectionView];
    
    [self requestPermissionAndFetchData];

    
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
        JKAlbumCollectionCamaraCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cameraCell" forIndexPath:indexPath];
        return cell;
    }
    else {
        JKAlbumCollectionPhotoCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"photoCell" forIndexPath:indexPath];
        JKPhotoAsset *asset = [self.activeCollection objectAtIndex:indexPath.row - 1];
        @weakify(self);
        [asset getThumbImageWithSize:CGSizeMake(self.cellWidth * [UIScreen mainScreen].scale, self.cellWidth * [UIScreen mainScreen].scale) withComplete:^(UIImage *result) {
            @strongify(self);
            cell.imageView.image = result;
        }];
        cell.selectButton.selected = [selectArray containsObject:asset.identifier];
        cell.selectButtonClicked = ^(BOOL selected){
            JKPhotoAsset * asset = [self.activeCollection objectAtIndex:indexPath.row - 1];
            if (selected) {
//                return se 
            }
        };
        
        return cell;
    }
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    [collectionView deselectItemAtIndexPath:indexPath animated:NO];
    
    
}





#pragma mark - Getdata

- (void)requestPermissionAndFetchData{
    [JKPhotoLibrary requestAuthorizationWithCompletionBlock:^(BOOL result) {
        if (result) {
            self.photoLibrary = [JKPhotoLibrary sharePhotoLibrary];
            [self performSelectorOnMainThread:@selector(getAlbums) withObject:nil waitUntilDone:NO];

        } else {
            UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:nil message:@"请在iPhone的“设置－隐私－相机”选项中，允许大众点评访问您的相机" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
            [alertView show];
        }
    }];
}

- (void)getAlbums{
    [self.photoLibrary fetchCollectionsWithCompletionBlock:^(NSArray *albums) {
        self.photoAlbums = albums;
        [self setFirstActiveCollection];
        [self preloadAssetsFromActiveCollection];
    }];
}

- (void)setFirstActiveCollection{
    if (self.photoAlbums) {
        self.activeCollection = self.photoAlbums[0];
    }
}

- (void)preloadAssetsFromActiveCollection{
    [self.activeCollection preloadPicWithCompletion:^{
        [self.collectionView reloadData];
    }];
}


@end
