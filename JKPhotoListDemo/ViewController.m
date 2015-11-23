//
//  ViewController.m
//  JKPhotoListDemo
//
//  Created by Jack on 15/11/19.
//  Copyright © 2015年 宇之楓鷙. All rights reserved.
//

#import "ViewController.h"
#import "JKLibraryPhotoList/JKPhotoListViewController.h"
#import "testViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}
- (IBAction)btnPressed:(id)sender {
    testViewController *vc = [testViewController new];
    [[JKUserContentHelper shareInstance]createNewPhotoSelectContextAndRemoveOldOneWithMaxNum:4];
    vc.view.backgroundColor = [UIColor whiteColor];
    [self.navigationController pushViewController:vc animated:YES];
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
