#import "ScanQrcodeVC.h"
#import "GizScanQrcodeView.h"
#import "GizScanQrcodeAttr.h"
#import <AVFoundation/AVFoundation.h>

@interface ScanQrcodeVC ()<GizScanQrcodeViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (weak, nonatomic) IBOutlet GizScanQrcodeView *scanView;
@property (weak, nonatomic) IBOutlet UIImageView *scanImageView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *descriptionLabel;
@property (weak, nonatomic) IBOutlet UIView *topBarView;
@property (weak, nonatomic) IBOutlet UIButton *choosePhotoBtn;
@property (weak, nonatomic) IBOutlet UIButton *flashLight;
//loading animation
@property (weak, nonatomic) IBOutlet UIView *activityIndicatorBackView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *loadingView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *navBarTopCons;

@property (nonatomic, strong) UIImagePickerController *imagePicker;

@end

@implementation ScanQrcodeVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setSubviews];
    [self configScanQRCodeView];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    if (![self.scanView isScan]) {
        if (!self.loadingView.isAnimating) {
            [self.scanView startScan];
        }
    }
    if (!self.flashLight.hidden) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidBecomeActive:) name:UIApplicationDidBecomeActiveNotification object:nil];
    }
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self.scanView stopScan];
    if (!self.flashLight.hidden) {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidBecomeActiveNotification object:nil];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (UIStatusBarStyle)preferredStatusBarStyle{
    if (self.scanQrcodeAttr) {
        NSString *whiteStatusBar = [self.scanQrcodeAttr objectForKey:@"statusBarColor"];
        if (whiteStatusBar && [[whiteStatusBar uppercaseString] isEqualToString:@"WHITE"]) {
            return UIStatusBarStyleLightContent;
        }
    }
    return UIStatusBarStyleDefault;
}

#pragma mark -setup
- (void)configScanQRCodeView{
    self.scanView.delegate = self;
    [self.scanView startScan];
}

- (void)setSubviews{
    self.navBarTopCons.constant = [UIApplication sharedApplication].statusBarFrame.size.height;
    
    [self setLoadingAnimation:false];
    
    GizScanQrcodeAttr *attr = [[GizScanQrcodeAttr alloc] initWithDict:self.scanQrcodeAttr];
    self.titleLabel.text = attr.title;
    self.topBarView.backgroundColor = attr.barColor;
    //describe string
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:attr.describe];
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    [paragraphStyle setLineSpacing:attr.describeLineSpacing];
    [attributedString addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, attr.describe.length)];
    [self.descriptionLabel setAttributedText:attributedString];
    self.descriptionLabel.textAlignment = NSTextAlignmentCenter;
    self.descriptionLabel.font = [UIFont systemFontOfSize:attr.describeFontSize];
    self.descriptionLabel.textColor = attr.describeColor;
    //border
    self.scanImageView.tintColor = attr.borderColor;
    self.scanImageView.image = [self.scanImageView.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [self.scanView setScanLineColor:attr.borderColor];
    for (NSLayoutConstraint *subCons in self.scanView.constraints) {
        if ([subCons.identifier isEqualToString:@"borderScaleConstraint"]) {
            [self.scanView removeConstraint:subCons];
            NSLayoutConstraint *newCons = [NSLayoutConstraint constraintWithItem:self.scanView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self.scanImageView attribute:NSLayoutAttributeWidth multiplier:1.0 / attr.borderScale constant:0];
            newCons.identifier = @"borderScaleConstraint";
            [self.scanView addConstraint:newCons];
            [self.scanView layoutIfNeeded];
            break;
        }
    }
    //choosePhotoBtn
    [self.choosePhotoBtn setHidden:![attr.choosePhotoEnable boolValue]];
    self.choosePhotoBtn.backgroundColor = attr.choosePhotoBtnColor;
    [self.choosePhotoBtn setTitle:attr.choosePhotoBtnTitle forState:UIControlStateNormal];
    //flashlight
    [self.flashLight setHidden:![attr.flashlightEnable boolValue]];
    if ([attr.flashlightEnable boolValue]) {
        UIImage *selectedImg = [UIImage imageNamed:@"flashlight_open"];
        UIImage *defaultImg = [UIImage imageNamed:@"flashlight_close"];
        selectedImg = [selectedImg imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        defaultImg = [defaultImg imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        [self.flashLight setTintColor:attr.borderColor];
        [self.flashLight setImage:selectedImg forState:UIControlStateSelected];
        [self.flashLight setImage:defaultImg forState:UIControlStateNormal];
    }
    //status bar
    self.view.backgroundColor = attr.barColor;
}

#pragma mark - loading animation
- (void)setLoadingAnimation:(BOOL)loading{
    [self.activityIndicatorBackView setHidden:!loading];
    if (loading) {
        [self.loadingView startAnimating];
        [self.scanView stopScan];
    } else{
        [self.loadingView stopAnimating];
        if (![self.scanView isScan]) {
            [self.scanView startScan];
        }
    }
}

#pragma mark - action
- (IBAction)backAcction:(id)sender {
    NSLog(@"【gizscanqrcode】scan cancel");
    if (self.scancodeCallback) {
        self.scancodeCallback(GizscanqrcodeResultCancel, @"cancel");
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)choosePhotoAction:(id)sender {
    [self setLoadingAnimation:true];
    //调用相册
    self.imagePicker = [[UIImagePickerController alloc]init];
    self.imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    self.imagePicker.delegate = self;
    [self presentViewController:self.imagePicker animated:YES completion:nil];
}

- (IBAction)flashLightAction:(id)sender {
    if ([sender isKindOfClass:[UIButton class]]) {
        UIButton *button = (UIButton *)sender;
        [self turnTheFlashlightOn:!button.selected];
    }
}

#pragma mark - flashlight
- (void)turnTheFlashlightOn:(BOOL)on{
    self.flashLight.selected = on;
    Class captureDeviceClass = NSClassFromString(@"AVCaptureDevice");
    if (captureDeviceClass != nil) {
        AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
        if ([device hasTorch] && [device hasFlash]){
            [device lockForConfiguration:nil];
            if (on) {
                [device setTorchMode:AVCaptureTorchModeOn];
                [device setFlashMode:AVCaptureFlashModeOn];
            } else {
                [device setTorchMode:AVCaptureTorchModeOff];
                [device setFlashMode:AVCaptureFlashModeOff];
            }
            [device unlockForConfiguration];
        }else{
            NSLog(@"初始化失败");
        }
    }else{
        NSLog(@"没有闪光设备");
    }
}

#pragma mark - notifications
- (void)applicationDidBecomeActive:(NSNotification *)notification{
    [self turnTheFlashlightOn: self.flashLight.selected];
}

#pragma mark - UIImagePickerControllerDelegate
-(void)imagePickerController:(UIImagePickerController*)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    [self.presentedViewController dismissViewControllerAnimated:YES completion:^{
        [self parseImagePickerInfo:info];
    }];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [self.presentedViewController dismissViewControllerAnimated:YES completion:^{
        [self setLoadingAnimation:false];
    }];
}

//parse photo
- (void)parseImagePickerInfo:(NSDictionary *)info{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSString *imageInfo = @"" ;
        UIImage *pickImage = info[UIImagePickerControllerOriginalImage];
        CIImage *ciImage = [CIImage imageWithCGImage:[pickImage CGImage]];
        CIDetector *detector = [CIDetector detectorOfType:CIDetectorTypeQRCode context:nil options:@{CIDetectorAccuracy: CIDetectorAccuracyLow}];
        NSArray *feature = [detector featuresInImage:ciImage];
        
        for (CIQRCodeFeature *result in feature) {
            imageInfo = result.messageString;
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self setLoadingAnimation:false];
            if (imageInfo && imageInfo.length) {
                [self scanSuccess:imageInfo];
            } else{
                [self scanError:[NSError errorWithDomain:@"ImagePickerDomain" code:999 userInfo:@{NSLocalizedDescriptionKey: @"解析失败"}]];
            }
        });
    });
}

#pragma mark - GizScanQrcodeViewDelegate
- (void)scanSuccess:(NSString *)text{
    NSLog(@"【gizscanqrcode】scan result: %@", text);
    if (self.scancodeCallback) {
        self.scancodeCallback(GizscanqrcodeResultSuccess, text);
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)scanError:(NSError *)error{
    NSLog(@"【gizscanqrcode】scan error: %@", error);
    if (self.scancodeCallback) {
        NSString *errorString = @"scan error";
        if ([error localizedDescription] && [error localizedDescription].length) {
            errorString = [error localizedDescription];
        }
        self.scancodeCallback(GizscanqrcodeResultError, errorString);
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
