//
//  Demo1ViewController.m
//  微博照片选择
//
//  Created by 洪欣 on 17/2/17.
//  Copyright © 2017年 洪欣. All rights reserved.
//

#import "Demo1ViewController.h"
#import "HXPhotoPicker.h"

@interface Demo1ViewController ()<HXAlbumListViewControllerDelegate,UIImagePickerControllerDelegate>
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UILabel *total;
//@property (weak, nonatomic) IBOutlet UILabel *photo;
//@property (weak, nonatomic) IBOutlet UILabel *video;
@property (weak, nonatomic) IBOutlet UILabel *original;
@property (weak, nonatomic) IBOutlet UISwitch *camera;
@property (strong, nonatomic) HXPhotoManager *manager;
@property (weak, nonatomic) IBOutlet UITextField *photoText;
@property (weak, nonatomic) IBOutlet UITextField *videoText;
@property (weak, nonatomic) IBOutlet UITextField *columnText;
@property (weak, nonatomic) IBOutlet UISwitch *addCamera; 
@property (weak, nonatomic) IBOutlet UISwitch *showHeaderSection;
@property (weak, nonatomic) IBOutlet UISwitch *reverse;
@property (weak, nonatomic) IBOutlet UISegmentedControl *selectedTypeView;
@property (weak, nonatomic) IBOutlet UISwitch *saveAblum;
@property (weak, nonatomic) IBOutlet UISwitch *icloudSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *downloadICloudAsset;
@property (weak, nonatomic) IBOutlet UISegmentedControl *tintColor;
@property (weak, nonatomic) IBOutlet UISwitch *hideOriginal;
@property (weak, nonatomic) IBOutlet UISwitch *synchTitleColor;
@property (weak, nonatomic) IBOutlet UISegmentedControl *navBgColor;
@property (weak, nonatomic) IBOutlet UISegmentedControl *navTitleColor;
@property (weak, nonatomic) IBOutlet UISwitch *useCustomCamera;
@property (strong, nonatomic) UIColor *bottomViewBgColor; 
@end

@implementation Demo1ViewController

- (HXPhotoManager *)manager
{
    if (!_manager) {
        _manager = [[HXPhotoManager alloc] initWithType:HXPhotoManagerSelectedTypePhoto];
        _manager.configuration.videoMaxNum = 5;
        _manager.configuration.deleteTemporaryPhoto = NO;
        _manager.configuration.lookLivePhoto = YES;
        _manager.configuration.saveSystemAblum = YES; 
//        _manager.configuration.supportRotation = NO;
//        _manager.configuration.cameraCellShowPreview = NO;
//        _manager.configuration.themeColor = [UIColor redColor];
        _manager.configuration.navigationBar = ^(UINavigationBar *navigationBar) {
//            [navigationBar setBackgroundImage:[UIImage imageNamed:@"APPCityPlayer_bannerGame"] forBarMetrics:UIBarMetricsDefault];
//            navigationBar.barTintColor = [UIColor redColor];
        };
//        _manager.configuration.sectionHeaderTranslucent = NO;
//        _manager.configuration.navBarBackgroudColor = [UIColor redColor];
//        _manager.configuration.sectionHeaderSuspensionBgColor = [UIColor redColor];
//        _manager.configuration.sectionHeaderSuspensionTitleColor = [UIColor whiteColor];
//        _manager.configuration.statusBarStyle = UIStatusBarStyleLightContent;
//        _manager.configuration.selectedTitleColor = [UIColor redColor];
        __weak typeof(self) weakSelf = self;
        _manager.configuration.photoListBottomView = ^(HXDatePhotoBottomView *bottomView) {
            bottomView.bgView.barTintColor = weakSelf.bottomViewBgColor;
        };
        _manager.configuration.previewBottomView = ^(HXDatePhotoPreviewBottomView *bottomView) {
            bottomView.bgView.barTintColor = weakSelf.bottomViewBgColor;
        };
        _manager.configuration.albumListCollectionView = ^(UICollectionView *collectionView) {
//            NSSLog(@"albumList:%@",collectionView);
        };
        _manager.configuration.photoListCollectionView = ^(UICollectionView *collectionView) {
//            NSSLog(@"photoList:%@",collectionView);
        };
        _manager.configuration.previewCollectionView = ^(UICollectionView *collectionView) {
//            NSSLog(@"preview:%@",collectionView);
        };
//        _manager.configuration.movableCropBox = YES;
//        _manager.configuration.movableCropBoxEditSize = YES;
//        _manager.configuration.movableCropBoxCustomRatio = CGPointMake(1, 1);
        
        // 使用自动的相机  这里拿系统相机做示例
        _manager.configuration.shouldUseCamera = ^(UIViewController *viewController, HXPhotoConfigurationCameraType cameraType, HXPhotoManager *manager) {
            
            // 这里拿使用系统相机做例子
            UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
            imagePickerController.delegate = (id)weakSelf;
            imagePickerController.allowsEditing = NO;
            NSString *requiredMediaTypeImage = ( NSString *)kUTTypeImage;
            NSString *requiredMediaTypeMovie = ( NSString *)kUTTypeMovie;
            NSArray *arrMediaTypes;
            if (cameraType == HXPhotoConfigurationCameraTypePhoto) {
                arrMediaTypes=[NSArray arrayWithObjects:requiredMediaTypeImage,nil];
            }else if (cameraType == HXPhotoConfigurationCameraTypeVideo) {
                arrMediaTypes=[NSArray arrayWithObjects:requiredMediaTypeMovie,nil];
            }else {
                arrMediaTypes=[NSArray arrayWithObjects:requiredMediaTypeImage, requiredMediaTypeMovie,nil];
            }
            [imagePickerController setMediaTypes:arrMediaTypes];
            // 设置录制视频的质量
            [imagePickerController setVideoQuality:UIImagePickerControllerQualityTypeHigh];
            //设置最长摄像时间
            [imagePickerController setVideoMaximumDuration:60.f];
            imagePickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
            imagePickerController.navigationController.navigationBar.tintColor = [UIColor whiteColor];
            imagePickerController.modalPresentationStyle=UIModalPresentationOverCurrentContext;
            [viewController presentViewController:imagePickerController animated:YES completion:nil];
        };
    }
    return _manager;
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    [picker dismissViewControllerAnimated:YES completion:nil];
    
    NSString *mediaType = [info objectForKey:UIImagePickerControllerMediaType];
    HXPhotoModel *model;
    if ([mediaType isEqualToString:(NSString *)kUTTypeImage]) {
        UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
        model = [HXPhotoModel photoModelWithImage:image];
        if (self.manager.configuration.saveSystemAblum) {
            [HXPhotoTools savePhotoToCustomAlbumWithName:self.manager.configuration.customAlbumName photo:model.thumbPhoto];
        }
    }else  if ([mediaType isEqualToString:(NSString *)kUTTypeMovie]) {
        NSURL *url = info[UIImagePickerControllerMediaURL];
        NSDictionary *opts = [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:NO]
                                                         forKey:AVURLAssetPreferPreciseDurationAndTimingKey];
        AVURLAsset *urlAsset = [AVURLAsset URLAssetWithURL:url options:opts];
        float second = 0;
        second = urlAsset.duration.value/urlAsset.duration.timescale;
        model = [HXPhotoModel photoModelWithVideoURL:url videoTime:second];
        if (self.manager.configuration.saveSystemAblum) {
            [HXPhotoTools saveVideoToCustomAlbumWithName:self.manager.configuration.customAlbumName videoURL:url];
        }
    }
    if (self.manager.configuration.useCameraComplete) {
        self.manager.configuration.useCameraComplete(model);
    }
}
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:nil];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"清空选择" style:UIBarButtonItemStylePlain target:self action:@selector(didRightClick)];
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
}
- (void)didRightClick {
    [self.manager clearSelectedList];
    self.total.text = @"总数量：0   ( 照片：0   视频：0 )";
    self.original.text = @"NO";
}
- (IBAction)goAlbum:(id)sender {
    self.camera.on = NO;
    if (self.tintColor.selectedSegmentIndex == 0) {
        self.manager.configuration.themeColor = self.view.tintColor;
        self.manager.configuration.cellSelectedTitleColor = nil;
    }else if (self.tintColor.selectedSegmentIndex == 1) {
        self.manager.configuration.themeColor = [UIColor redColor];
        self.manager.configuration.cellSelectedTitleColor = [UIColor redColor];
    }else if (self.tintColor.selectedSegmentIndex == 2) {
        self.manager.configuration.themeColor = [UIColor whiteColor];
        self.manager.configuration.cellSelectedTitleColor = [UIColor whiteColor];
    }else if (self.tintColor.selectedSegmentIndex == 3) {
        self.manager.configuration.themeColor = [UIColor blackColor];
        self.manager.configuration.cellSelectedTitleColor = [UIColor blackColor];
    }else if (self.tintColor.selectedSegmentIndex == 4) {
        self.manager.configuration.themeColor = [UIColor orangeColor];
        self.manager.configuration.cellSelectedTitleColor = [UIColor orangeColor];
    }else {
        self.manager.configuration.themeColor = self.view.tintColor;
        self.manager.configuration.cellSelectedTitleColor = nil;
    }
    
    if (self.navBgColor.selectedSegmentIndex == 0) {
        self.manager.configuration.navBarBackgroudColor = nil;
        self.manager.configuration.statusBarStyle = UIStatusBarStyleDefault;
        self.manager.configuration.sectionHeaderTranslucent = YES;
        self.bottomViewBgColor = nil;
        self.manager.configuration.cellSelectedBgColor = nil;
        self.manager.configuration.selectedTitleColor = nil;
        self.manager.configuration.sectionHeaderSuspensionBgColor = nil;
        self.manager.configuration.sectionHeaderSuspensionTitleColor = nil;
    }else if (self.navBgColor.selectedSegmentIndex == 1) {
        self.manager.configuration.navBarBackgroudColor = [UIColor redColor];
        self.manager.configuration.statusBarStyle = UIStatusBarStyleLightContent;
        self.manager.configuration.sectionHeaderTranslucent = NO;
        self.bottomViewBgColor = [UIColor redColor];
        self.manager.configuration.cellSelectedBgColor = [UIColor redColor];
        self.manager.configuration.selectedTitleColor = [UIColor redColor];
        self.manager.configuration.sectionHeaderSuspensionBgColor = [UIColor redColor];
        self.manager.configuration.sectionHeaderSuspensionTitleColor = [UIColor whiteColor];
    }else if (self.navBgColor.selectedSegmentIndex == 2) {
        self.manager.configuration.navBarBackgroudColor = [UIColor whiteColor];
        self.manager.configuration.statusBarStyle = UIStatusBarStyleDefault;
        self.manager.configuration.sectionHeaderTranslucent = NO;
        self.bottomViewBgColor = [UIColor whiteColor];
        self.manager.configuration.cellSelectedBgColor = self.manager.configuration.themeColor;
        self.manager.configuration.cellSelectedTitleColor = [UIColor whiteColor];
        self.manager.configuration.selectedTitleColor = [UIColor whiteColor];
        self.manager.configuration.sectionHeaderSuspensionBgColor = [UIColor whiteColor];
        self.manager.configuration.sectionHeaderSuspensionTitleColor = [UIColor blackColor];
    }else if (self.navBgColor.selectedSegmentIndex == 3) {
        self.manager.configuration.navBarBackgroudColor = [UIColor blackColor];
        self.manager.configuration.statusBarStyle = UIStatusBarStyleLightContent;
        self.manager.configuration.sectionHeaderTranslucent = NO;
        self.bottomViewBgColor = [UIColor blackColor];
        self.manager.configuration.cellSelectedBgColor = [UIColor blackColor];
        self.manager.configuration.selectedTitleColor = [UIColor blackColor];
        self.manager.configuration.sectionHeaderSuspensionBgColor = [UIColor blackColor];
        self.manager.configuration.sectionHeaderSuspensionTitleColor = [UIColor whiteColor];
    }else if (self.navBgColor.selectedSegmentIndex == 4) {
        self.manager.configuration.navBarBackgroudColor = [UIColor orangeColor];
        self.manager.configuration.statusBarStyle = UIStatusBarStyleLightContent;
        self.manager.configuration.sectionHeaderTranslucent = NO;
        self.bottomViewBgColor = [UIColor orangeColor];
        self.manager.configuration.cellSelectedBgColor = [UIColor orangeColor];
        self.manager.configuration.selectedTitleColor = [UIColor orangeColor];
        self.manager.configuration.sectionHeaderSuspensionBgColor = [UIColor orangeColor];
        self.manager.configuration.sectionHeaderSuspensionTitleColor = [UIColor whiteColor];
    }else {
        self.manager.configuration.navBarBackgroudColor = nil;
        self.manager.configuration.statusBarStyle = UIStatusBarStyleDefault;
        self.manager.configuration.sectionHeaderTranslucent = YES;
        self.bottomViewBgColor = nil;
        self.manager.configuration.cellSelectedBgColor = nil;
        self.manager.configuration.selectedTitleColor = nil;
        self.manager.configuration.sectionHeaderSuspensionBgColor = nil;
        self.manager.configuration.sectionHeaderSuspensionTitleColor = nil;
    }
    
    if (self.navTitleColor.selectedSegmentIndex == 0) {
        self.manager.configuration.navigationTitleColor = nil;
    }else if (self.navTitleColor.selectedSegmentIndex == 1) {
        self.manager.configuration.navigationTitleColor = [UIColor redColor];
    }else if (self.navTitleColor.selectedSegmentIndex == 2) {
        self.manager.configuration.navigationTitleColor = [UIColor whiteColor];
    }else if (self.navTitleColor.selectedSegmentIndex == 3) {
        self.manager.configuration.navigationTitleColor = [UIColor blackColor];
    }else if (self.navTitleColor.selectedSegmentIndex == 4) {
        self.manager.configuration.navigationTitleColor = [UIColor orangeColor];
    }else {
        self.manager.configuration.navigationTitleColor = nil;
    }
    self.manager.configuration.hideOriginalBtn = self.hideOriginal.on;
    self.manager.configuration.filtrationICloudAsset = self.icloudSwitch.on;
    self.manager.configuration.photoMaxNum = self.photoText.text.integerValue;
    self.manager.configuration.videoMaxNum = self.videoText.text.integerValue;
    self.manager.configuration.rowCount = self.columnText.text.integerValue;
    self.manager.configuration.downloadICloudAsset = self.downloadICloudAsset.on;
    self.manager.configuration.saveSystemAblum = self.saveAblum.on;
    self.manager.configuration.showDateSectionHeader = self.showHeaderSection.on;
    self.manager.configuration.reverseDate = self.reverse.on;
    self.manager.configuration.navigationTitleSynchColor = self.synchTitleColor.on;
    self.manager.configuration.useCustomCamera = self.useCustomCamera.on;
    self.manager.configuration.openCamera = self.addCamera.on;
    
//    [self.view hx_presentAlbumListViewControllerWithManager:self.manager delegate:self];
    
    [self hx_presentAlbumListViewControllerWithManager:self.manager delegate:self];
    
//    HXAlbumListViewController *vc = [[HXAlbumListViewController alloc] init];
//    vc.delegate = self;
//    vc.manager = self.manager;
//    HXCustomNavigationController *nav = [[HXCustomNavigationController alloc] initWithRootViewController:vc];

//    [self presentViewController:nav animated:YES completion:nil];
}
- (IBAction)selectTypeClick:(UISegmentedControl *)sender {
    if (sender.selectedSegmentIndex == 0) {
        self.manager.type = HXPhotoManagerSelectedTypePhoto;
    }else if (sender.selectedSegmentIndex == 1) {
        self.manager.type = HXPhotoManagerSelectedTypeVideo;
    }else {
        self.manager.type = HXPhotoManagerSelectedTypePhotoAndVideo;
    }
    [self.manager clearSelectedList];
}

- (void)albumListViewController:(HXAlbumListViewController *)albumListViewController didDoneAllList:(NSArray<HXPhotoModel *> *)allList photos:(NSArray<HXPhotoModel *> *)photoList videos:(NSArray<HXPhotoModel *> *)videoList original:(BOOL)original {
    self.total.text = [NSString stringWithFormat:@"总数量：%ld   ( 照片：%ld   视频：%ld )",allList.count, photoList.count, videoList.count];
    //    [NSString stringWithFormat:@"%ld个",allList.count];
    //    self.photo.text = [NSString stringWithFormat:@"%ld张",photos.count];
    //    self.video.text = [NSString stringWithFormat:@"%ld个",videos.count];
    self.original.text = original ? @"YES" : @"NO";
    NSSLog(@"all - %@",allList);
    NSSLog(@"photo - %@",photoList);
    NSSLog(@"video - %@",videoList);
}

- (IBAction)same:(id)sender {
    UISwitch *sw = (UISwitch *)sender;
    self.manager.configuration.selectTogether = sw.on;
}

- (IBAction)isLookGIFPhoto:(UISwitch *)sender {
    self.manager.configuration.lookGifPhoto = sender.on;
}

- (IBAction)isLookLivePhoto:(UISwitch *)sender {
    self.manager.configuration.lookLivePhoto = sender.on;
}

- (IBAction)addCamera:(id)sender {
    UISwitch *sw = (UISwitch *)sender;
    self.manager.configuration.openCamera = sw.on;
}
- (void)dealloc {
    NSSLog(@"dealloc");
}
@end
