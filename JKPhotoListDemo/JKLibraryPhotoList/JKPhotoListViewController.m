//
//  JKPhotoListViewController.m
//  apollo
//
//  Created by Jack on 15/11/19.
//  Copyright © 2015年 季 浩勉. All rights reserved.
//

#import "JKPhotoListViewController.h"
#import "JKPhotoCollection.h"
#import "JKPhotoAsset.h"
#import "JKAlbumCollectionPhotoCell.h"
#import <AVFoundation/AVFoundation.h>


@interface JKPhotoListViewController ()<UICollectionViewDataSource,UICollectionViewDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate>

@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) JKPhotoCollection                *activeCollection;
@property (nonatomic, strong) JKPhotoLibrary                   *photoLibrary;
@property (nonatomic, strong) NSArray                           *photoAlbums;
@property (nonatomic, weak)   JKUserContentHelper              *ucHelper;

@property (nonatomic, assign) NSUInteger                         maxnum;
@property (nonatomic, assign) NSInteger                          oldSelectNum;

@property (nonatomic, assign) CGFloat cellWidth;
//@property (nonatomic, strong)

@end


NSMutableArray *selectArray;
NSMutableArray *selectPhotoInfos;

@implementation JKPhotoListViewController


- (instancetype)init{
    if (self = [super init]) {
        self.view.backgroundColor = [UIColor whiteColor];
        _maxnum = 9;
        selectArray = [NSMutableArray new];
        selectPhotoInfos = [NSMutableArray new];
        CGFloat balanceValue = 100;
        NSInteger viewCount = [UIScreen mainScreen].bounds.size.width / balanceValue;
        CGFloat width = self.view.width -( viewCount - 1 ) * 10 - 30;
        width = width / viewCount;
        _cellWidth = width;
    }
    return self;
}


- (UICollectionView *)collectionView
{
    if (_collectionView) {
        return _collectionView;
    }

    CGFloat margin = 15;
    UICollectionViewFlowLayout *layout = [UICollectionViewFlowLayout new];
        layout.itemSize = CGSizeMake(self.cellWidth, self.cellWidth);
    layout.sectionInset = UIEdgeInsetsMake(margin, margin, margin, margin);
    layout.minimumInteritemSpacing = 10;
    layout.minimumLineSpacing = layout.minimumInteritemSpacing;
    
    self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:[UICollectionViewFlowLayout new]];
    _collectionView.delegate = self;
    _collectionView.dataSource = self;
    
    [self.collectionView registerClass:[JKAlbumCollectionPhotoCell class] forCellWithReuseIdentifier:@"photoCell"];
    [self.collectionView registerClass:[JKAlbumCollectionCamaraCell class] forCellWithReuseIdentifier:@"cameraCell"];
    _collectionView.backgroundColor = [UIColor clearColor];
    return _collectionView;
}

- (void)viewDidLayoutSubviews{
    [super viewDidLayoutSubviews];
    
//    self.toolBar.size = CGSizeMake(self.view.width, 50);
//    self.toolBar.left = 0;
//    self.toolBar.bottom = self.view.height;
//    
//    self.previewButton.centerY = self.toolBar.height / 2;
//    self.previewButton.left = 15;
//    
    
    self.collectionView.width = self.view.width;
    self.collectionView.height = self.view.height ;
    
    UICollectionViewFlowLayout *layout = [UICollectionViewFlowLayout new];
    
    CGFloat margin = 15;
    layout.itemSize = CGSizeMake(self.cellWidth, self.cellWidth);
    layout.sectionInset = UIEdgeInsetsMake(margin, margin, margin, margin);
    layout.minimumInteritemSpacing = 10;
    layout.minimumLineSpacing = layout.minimumInteritemSpacing;
    self.collectionView.collectionViewLayout = layout;
    
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.ucHelper = [JKUserContentHelper shareInstance];
    
    selectArray = [NSMutableArray new];
    selectPhotoInfos = [NSMutableArray new];
    self.title = @"相册";
    
    [self.view addSubview:self.collectionView];
    
    [self requestPermissionAndFetchData];
    
    self.oldSelectNum = self.ucHelper.currentSelectedPhotos.count;
    
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
            cell.imageView.image = result;
        }];
        cell.selectButton.selected = [selectArray containsObject:asset.identifier];
        cell.selectButtonClicked = ^(BOOL selected){
            @strongify(self);
            JKPhotoAsset *asset = [self.activeCollection objectAtIndex:indexPath.row - 1];
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
        }
        else
        {
            [self openCamera];
        }
    }
    
}


- (BOOL)selectAsset:(JKPhotoAsset *)asset{
    if (self.ucHelper.currentSelectedPhotos.count >= self.maxnum) {
        return NO;
    }
    [selectArray addObject:asset.identifier];
    [selectPhotoInfos addObject:asset];
    [self.ucHelper selectPhoto:asset];
    return YES;
}
- (BOOL)deselectAsset:(JKPhotoAsset *)asset{
    JKPhotoAsset *photoInfo = [self.ucHelper photoWithSelectedIdentifier:asset.identifier];
    [selectPhotoInfos removeObject:photoInfo];
    [selectArray removeObject:asset.identifier];
    [self.ucHelper deselectPhoto:photoInfo];
    return YES;
}


//- (void)

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


- (void)openCamera{
    if (![UIImagePickerController isSourceTypeAvailable: UIImagePickerControllerSourceTypeCamera]) {
        return;
    }
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    if (authStatus == AVAuthorizationStatusDenied || authStatus == AVAuthorizationStatusRestricted) {
        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:nil message:@"请在iPhone的“设置－隐私－相机”选项中，允许大众点评访问您的相机" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
        [alertView show];
        return;
    }
    UIImagePickerController *camaraPicker = [[UIImagePickerController alloc] init];
    camaraPicker.delegate = self;
    camaraPicker.allowsEditing = NO;
    camaraPicker.sourceType = UIImagePickerControllerSourceTypeCamera;
    [self presentViewController:camaraPicker animated:YES completion:nil];
}
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    UIImageWriteToSavedPhotosAlbum(info[UIImagePickerControllerOriginalImage], self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
    @weakify(self)
    [self dismissViewControllerAnimated:YES completion:^{
        @strongify(self)
        NSLog(@"%@",info);
//        UGCPhotoWithExtroInfo *photoInfo = [UGCPhotoWithExtroInfo new];
//        photoInfo.identifier = [NSString NV_uuidString];
//        [photoInfo saveImageToFilePathWithImage:info[UIImagePickerControllerOriginalImage]];
//        [self.ucHelper selectPhoto:photoInfo];
//        [self nextButtonClicked];
    }];
}
- (void)image:(UIImage*)image didFinishSavingWithError:(NSError*)error contextInfo:(void*)contextInfo
{
    [self requestPermissionAndFetchData];
}

@end
