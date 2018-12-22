//
//  CVViewController.m
//  CVOpenTemplate
//
//  Created by Washe on 02/01/2013.
//  Copyright (c) 2013 foundry. All rights reserved.
//

#import "CVViewController.h"
#import "CVWrapper.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MediaPlayer.h>
#import <AssetsLibrary/AssetsLibrary.h>

@interface CVViewController ()<UIImagePickerControllerDelegate,UINavigationControllerDelegate,UIScrollViewDelegate>

{
    UIImagePickerController *_imagePickerController;
    UIButton *_recommendButton;
    UIImage *image1;
    NSMutableArray *imageArray;
    NSTimer *timer;
    NSInteger pictureCount;
    NSInteger SetCount;//设置的连拍数
    NSMutableArray *arr;
}
@end

@implementation CVViewController

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    imageArray = [NSMutableArray arrayWithCapacity:0];
    arr = [NSMutableArray arrayWithCapacity:0];
    
    if (![QBImagePickerController isAccessible]) {
        NSLog(@"Error: Source is not accessible.");
    }
    image1 = [[UIImage alloc] init];
    _recommendButton = [UIButton buttonWithType:UIButtonTypeSystem];
    _recommendButton.frame = CGRectMake(self.view.bounds.size.width/2.0 - 50,self.view.bounds.size.height - 80,100,40);
    [_recommendButton setTitle:@"拍照" forState:0];
    _recommendButton.titleLabel.lineBreakMode = 0;
    _recommendButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    _recommendButton.titleLabel.font = [UIFont systemFontOfSize:17];
    _recommendButton.backgroundColor = [UIColor redColor];
    [_recommendButton setTitleColor:[UIColor whiteColor] forState:0];
    [_recommendButton addTarget:self action:@selector(recommendButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_recommendButton];
}

- (void)recommendButtonPressed
{
    pictureCount = 0;
    
    UIImagePickerControllerSourceType sourceType = UIImagePickerControllerSourceTypeCamera;
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {    //    if (!
        _imagePickerController = [[UIImagePickerController alloc] init];//初始化
        _imagePickerController.delegate = self;
        _imagePickerController.sourceType = sourceType;
        _imagePickerController.allowsEditing = NO;//设置可编辑
        _imagePickerController.showsCameraControls = NO;//不使用系统默认拍照按钮
        _imagePickerController.cameraDevice = UIImagePickerControllerCameraDeviceRear;
        
        [self presentViewController:_imagePickerController animated:YES completion:nil];
        
        UIButton *Butto = [UIButton buttonWithType:UIButtonTypeCustom];
        Butto.backgroundColor = [UIColor whiteColor];
        Butto.frame = CGRectMake(self.view.bounds.size.width/2.0 - 40,self.view.bounds.size.height - 120,80,80);
        Butto.layer.cornerRadius = 40;
        Butto.layer.masksToBounds = YES;
        //    [Butto addTarget:self action:@selector(tackCam:) forControlEvents:UIControlEventTouchUpInside];
        
        [_imagePickerController.view addSubview:Butto];
        UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
        backButton.frame = CGRectMake(20,30,50,44);
        [backButton setTitle:@"取消" forState:0];
        backButton.backgroundColor = [UIColor clearColor];
        backButton.frame = CGRectMake(35,self.view.bounds.size.height - 100,40,40);
        [backButton addTarget:self action:@selector(back:) forControlEvents:UIControlEventTouchUpInside];
        [_imagePickerController.view addSubview:backButton];
        
        UIView *nview = [[UIView alloc] init];
        nview.backgroundColor = [UIColor whiteColor];
        nview.frame = CGRectMake(self.view.bounds.size.width/2.0 - 30,self.view.bounds.size.height - 110,60,60);
        nview.layer.cornerRadius = 30;
        nview.layer.borderWidth = 3;
        nview.layer.borderColor = [UIColor blackColor].CGColor;
        nview.layer.masksToBounds = YES;
        [_imagePickerController.view addSubview:nview];
        
        UIButton *takePhotoBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        takePhotoBtn.backgroundColor = [UIColor clearColor];
        takePhotoBtn.frame = CGRectMake(self.view.bounds.size.width/2.0 - 40,self.view.bounds.size.height - 120,80,80);
        takePhotoBtn.layer.cornerRadius = 40;
        takePhotoBtn.layer.masksToBounds = YES;
        [takePhotoBtn addTarget:self action:@selector(tackCam:) forControlEvents:UIControlEventTouchUpInside];
        [_imagePickerController.view addSubview:takePhotoBtn];
    }
}

- (void)back:(UIButton *)btn
{
    if (arr.count == 0) {
        [self dismissViewControllerAnimated:YES completion:nil];
        return;
    }
    UIImageWriteToSavedPhotosAlbum(arr[0], self, @selector(image:didFinishSavingWithError:contextInfo:), NULL);
    UIImageView *imageView;
    imageView = [[UIImageView alloc] initWithImage:arr[0]];
    __weak typeof(self) wSelf = self;
    [arr removeAllObjects];
    [self dismissViewControllerAnimated:YES completion:^{
        wSelf.imageView = imageView;
        [wSelf.scrollView addSubview:imageView];
        wSelf.scrollView.backgroundColor = [UIColor blackColor];
        wSelf.scrollView.contentSize = wSelf.imageView.bounds.size;
        wSelf.scrollView.maximumZoomScale = 4.0;
        wSelf.scrollView.minimumZoomScale = 0.5;
        wSelf.scrollView.contentOffset = CGPointMake(-(wSelf.scrollView.bounds.size.width-wSelf.imageView.bounds.size.width)/2, -(wSelf.scrollView.bounds.size.height-wSelf.imageView.bounds.size.height)/2);
    }];
    
}

- (void)tackCam:(UIButton *)sender{
    [_imagePickerController takePicture];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info
{
    NSString *mediaType=[info objectForKey:UIImagePickerControllerMediaType];
    //判断资源类型
    if ([mediaType isEqualToString:(NSString *)kUTTypeImage]){
        //如果是图片
        self.imageView.image = info[UIImagePickerControllerEditedImage];
        image1 = info[UIImagePickerControllerOriginalImage];
        image1 = [self reduceImage:image1 percent:0.5];
        CGSize imageSize = image1.size;
        imageSize = CGSizeMake(640,720);
        //压缩图片尺寸
        image1 = [self imageWithImageSimple:image1 scaledToSize:imageSize];
    }
    [arr addObject:image1];
    [self stitch:[arr copy]];
}

- (void) stitch:(NSArray *)info
{
    imageArray = [info mutableCopy];
    UIImage* stitchedImage;
    UIWindow *window = [[UIApplication sharedApplication] keyWindow];
    
    if (imageArray.count > 1) {
        stitchedImage  = [CVWrapper processWithArray:imageArray];
        if (stitchedImage == nil) {
            [window makeToast:@"拼接失败,重新拍照" duration:1.5 position:CSToastPositionCenter];
            [arr removeLastObject];
        }else{
            [window makeToast:@"拼接成功" duration:1.5 position:CSToastPositionCenter];
            [arr removeAllObjects];
            [arr addObject:stitchedImage];
        }
    }else{
        arr = [info mutableCopy];
    }
}

//压缩图片尺寸
- (UIImage*)imageWithImageSimple:(UIImage*)image scaledToSize:(CGSize)newSize
{
    UIGraphicsBeginImageContext(newSize);
    [image drawInRect:CGRectMake(0,0,newSize.width,newSize.height)];
    UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

//压缩图片质量
-(UIImage *)reduceImage:(UIImage *)image percent:(float)percent
{
    NSData *imageData = UIImageJPEGRepresentation(image, percent);
    UIImage *newImage = [self af_safeImageWithData:imageData];
    return newImage;
}

- (UIImage *)af_safeImageWithData:(NSData *)data {
    static NSLock* imageLock = nil;
    UIImage* image = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        imageLock = [[NSLock alloc] init];
    });
    
    [imageLock lock];
    image = [UIImage imageWithData:data];
    [imageLock unlock];
    return image;
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    NSLog(@"取消");
}

- (void)image:(UIImage*)image didFinishSavingWithError:(NSError*)error contextInfo:(void*)contextInfo
{
    if (error) {
        NSLog(@"保存失败");
    }else{
        NSLog(@"保存成功");
    }
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingImage:(UIImage *)selectedImage editingInfo:(NSDictionary *)editingInfo {
    if (_imagePickerController == picker)  {//这里的条件随便你自己定义了
        //**主要就是下面这句话，会让你继续回到take camera的页面
        _imagePickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
    } else {
        [_imagePickerController dismissModalViewControllerAnimated:YES];
    }
}

- (BOOL) shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    return YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}


@end
