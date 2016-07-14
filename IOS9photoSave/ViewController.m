//
//  ViewController.m
//  IOS9photoSave
//
//  Created by juxiaohui on 16/7/14.
//  Copyright © 2016年 juxiaohui. All rights reserved.
//

#import "ViewController.h"
#import <Photos/Photos.h>

static NSString * const albumName = @"IOS9photoSave";//一般为应用名

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *imageView1;
@property (weak, nonatomic) IBOutlet UIImageView *imageView2;
@property (weak, nonatomic) IBOutlet UIImageView *imageView3;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UITapGestureRecognizer * tap1 =[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(saveImage:)];
    UITapGestureRecognizer * tap2 =[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(saveImage:)];
    UITapGestureRecognizer * tap3 =[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(saveImage:)];
    [self.imageView1 addGestureRecognizer:tap1];
    [self.imageView2 addGestureRecognizer:tap2];
    [self.imageView3 addGestureRecognizer:tap3];

}


-(void)saveImage:(UIGestureRecognizer *)gesture{
    
    UIImageView * imageView = (UIImageView *)gesture.view;
    [self savePhotoWith:imageView.image];
    
}

-(void)savePhotoWith:(UIImage *)image{

    [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
        if (status!=PHAuthorizationStatusAuthorized) return ;//未获得用户授权
        NSError * error=nil;
        //保存照片到相机胶卷
        __block PHObjectPlaceholder *createdAsset = nil;
        [[PHPhotoLibrary sharedPhotoLibrary]performChangesAndWait:^{
           createdAsset= [PHAssetCreationRequest creationRequestForAssetFromImage:image].placeholderForCreatedAsset;
            
        } error:&error];
        
        if (error) {
            NSLog(@"保存失败：%@", error);
            return;
        }else{
            NSLog(@"保存到相机胶卷成功");
        }
        // 拿到自定义的相册对象
        PHAssetCollection *collection = [self collection];
        if (collection == nil) return;
        [[PHPhotoLibrary sharedPhotoLibrary]performChangesAndWait:^{
            [[PHAssetCollectionChangeRequest changeRequestForAssetCollection:collection]insertAssets:@[createdAsset] atIndexes:[NSIndexSet indexSetWithIndex:0]];
        } error:&error];
        if (error) {
            NSLog(@"保存失败：%@", error);
        } else {
            NSLog(@"保存自定义相册成功");
        }
    }];
}

-(PHAssetCollection *)collection{
    //先从相册中查找是否存在自定义的相册
    PHFetchResult<PHAssetCollection *> *collectionResult =[PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum subtype:PHAssetCollectionSubtypeAlbumRegular options:nil];
    //遍历数组
    for (PHAssetCollection * collection in collectionResult) {
        if ([collection.localizedTitle isEqualToString:albumName]) {//如果创建过,返回这个相册
            return collection;
        }
    }
    //没有创建过，手动创建
    __block NSString *collectionId = nil;
    NSError *error = nil;
    [[PHPhotoLibrary sharedPhotoLibrary]performChangesAndWait:^{
      collectionId  =  [PHAssetCollectionChangeRequest creationRequestForAssetCollectionWithTitle:albumName].placeholderForCreatedAssetCollection.localIdentifier;
    } error:&error];
    if (error) {
        NSLog(@"获取相册【%@】失败", albumName);
        return nil;
    }
    //返回手动创建的相册
    return [PHAssetCollection fetchAssetCollectionsWithLocalIdentifiers:@[collectionId] options:nil].lastObject;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
