#import "GizScanQrcodeView.h"
#import <AVFoundation/AVFoundation.h>

@interface GizScanQrcodeView()<AVCaptureMetadataOutputObjectsDelegate>

@property (nonatomic) AVCaptureSession *session;
@property (nonatomic) AVCaptureMetadataOutput *output;
@property (nonatomic) UIView *captureView;
@property (nonatomic) AVCaptureVideoPreviewLayer *previewLayer;
@property (nonatomic) CAShapeLayer *maskLayer;
@property (weak, nonatomic) IBOutlet UIImageView *boundaryView;
@property (nonatomic) UIImageView *scanLine;
@property (nonatomic, strong) UIView *loadingView;

@end

@implementation GizScanQrcodeView

- (instancetype)initWithCoder:(NSCoder *)coder{
    self = [super initWithCoder:coder];
    if (self) {
        [self setup];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.captureView.frame = self.bounds;
    self.previewLayer.frame = self.captureView.bounds;
    self.maskLayer.frame = self.captureView.bounds;
    
    [self updateMaskLayer];
    [self updateScanLine];
}

- (void)setup {
    [self setupCaptureSessionWithCompletedBlock:^(BOOL success) {
        if (!success) {
            return;
        }
        
        [self addPreviewLayer];
        [self addMaskLayer];
        
        [self sendSubviewToBack:self.captureView];
        self.scanLine = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"scanLine"]];
        self.scanLine.image = [self.scanLine.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];

        [self setLoading];
        
        [self startScan];
        
        //增加监听
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(appWillEnterForegroundNotification)
                                                     name:UIApplicationWillEnterForegroundNotification
                                                   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sessionDidStartRunning) name:AVCaptureSessionDidStartRunningNotification object:nil];
    }];
}

- (void)sessionDidStartRunning{
    if (self.loadingView) {
        [self.loadingView removeFromSuperview];
    }
}

- (void)setLoading{
    self.loadingView = [[UIView alloc] init];
    [self addSubview:self.loadingView];
    self.loadingView.translatesAutoresizingMaskIntoConstraints = NO;
    self.loadingView.backgroundColor = [UIColor blackColor];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[loadingView]-0-|" options:0 metrics:nil views:@{@"loadingView": self.loadingView}]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[loadingView]-0-|" options:0 metrics:nil views:@{@"loadingView": self.loadingView}]];
    
    UIActivityIndicatorView *loading = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    [self.loadingView addSubview:loading];
    [loading startAnimating];
    loading.translatesAutoresizingMaskIntoConstraints = NO;
    [self.loadingView addConstraint:[NSLayoutConstraint constraintWithItem:loading attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.loadingView attribute:NSLayoutAttributeCenterY multiplier:1 constant:-60]];
    [self.loadingView addConstraint:[NSLayoutConstraint constraintWithItem:loading attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.loadingView attribute:NSLayoutAttributeCenterX multiplier:1 constant:0]];
    
    UILabel *tip = [[UILabel alloc] init];
    tip.font = [UIFont systemFontOfSize:15];
    tip.textAlignment = NSTextAlignmentCenter;
    tip.textColor = [UIColor whiteColor];
//    tip.text = @"相机开启中";
    tip.translatesAutoresizingMaskIntoConstraints = NO;
    [self.loadingView addSubview:tip];
    
    [self.loadingView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[tip]-0-|" options:0 metrics:nil views:@{@"tip": tip}]];
    [self.loadingView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[loading]-12-[tip]" options:0 metrics:nil views:@{@"loading": loading, @"tip": tip}]];
    
}

- (void)appWillEnterForegroundNotification{
    if (self.isScan) {
         [self doAnimateFrame];
    }
}

- (void)setupCaptureSessionWithCompletedBlock:(void(^)(BOOL))completed {
    dispatch_async(dispatch_get_main_queue(), ^{
        self.session = [[AVCaptureSession alloc] init];
        AVCaptureDevice *captureDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
        NSError *error = nil;
        
        AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:captureDevice error:&error];
        if (!input) {
            [self.delegate scanError:error];
            completed(NO);
            return;
        }
        [self.session addInput:input];
        
        AVCaptureMetadataOutput *output = [[AVCaptureMetadataOutput alloc] init];
        [self.session addOutput:output];
        //设置扫码支持的编码格式(如下设置条形码和二维码兼容)
        NSMutableArray *types = [[NSMutableArray alloc] init];
        if ([output.availableMetadataObjectTypes containsObject:AVMetadataObjectTypeQRCode]) {
            [types addObject:AVMetadataObjectTypeQRCode];
        }
        if ([output.availableMetadataObjectTypes containsObject:AVMetadataObjectTypeEAN13Code]) {
            [types addObject:AVMetadataObjectTypeEAN13Code];
        }
        if ([output.availableMetadataObjectTypes containsObject:AVMetadataObjectTypeEAN8Code]) {
            [types addObject:AVMetadataObjectTypeEAN8Code];
        }
        if ([output.availableMetadataObjectTypes containsObject:AVMetadataObjectTypeCode128Code]) {
            [types addObject:AVMetadataObjectTypeUPCECode];
        }
        if ([output.availableMetadataObjectTypes containsObject:AVMetadataObjectTypeCode128Code]) {
            [types addObject:AVMetadataObjectTypeCode39Code];
        }
        if ([output.availableMetadataObjectTypes containsObject:AVMetadataObjectTypeCode128Code]) {
            [types addObject:AVMetadataObjectTypeCode39Mod43Code];
        }
        if ([output.availableMetadataObjectTypes containsObject:AVMetadataObjectTypeCode128Code]) {
            [types addObject:AVMetadataObjectTypeCode93Code];
        }
        if ([output.availableMetadataObjectTypes containsObject:AVMetadataObjectTypeCode128Code]) {
            [types addObject:AVMetadataObjectTypeCode128Code];
        }
        if ([output.availableMetadataObjectTypes containsObject:AVMetadataObjectTypeCode128Code]) {
            [types addObject:AVMetadataObjectTypePDF417Code];
        }
        output.metadataObjectTypes = types;
        [output setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
        self.output = output;
        completed(YES);
    });
}

- (void)addPreviewLayer {
    self.captureView = [[UIView alloc] initWithFrame:self.bounds];
    [self addSubview:self.captureView];
    
    AVCaptureVideoPreviewLayer *previewLayer = [AVCaptureVideoPreviewLayer layerWithSession:self.session];
    previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    [self.captureView.layer addSublayer:previewLayer];
    previewLayer.frame = self.layer.bounds;
    self.previewLayer = previewLayer;
}

- (void)addMaskLayer {
    CAShapeLayer *maskLayer = [CAShapeLayer layer];
    maskLayer.backgroundColor = [UIColor blackColor].CGColor;
    maskLayer.opacity = 0.5;
    [self.captureView.layer addSublayer:maskLayer];
    maskLayer.frame = self.layer.bounds;
    self.maskLayer = maskLayer;
    
    [self updateMaskLayer];
}

- (void)updateMaskLayer {
    if (!self.session) {
        return;
    }
    CAShapeLayer *layer = [CAShapeLayer layer];
    UIBezierPath *path = [UIBezierPath bezierPathWithRect:self.maskLayer.bounds];
    [path appendPath:[UIBezierPath bezierPathWithRect:self.boundaryView.frame]];
    layer.path = path.CGPath;
    layer.fillRule = kCAFillRuleEvenOdd;
    layer.fillColor = [UIColor blackColor].CGColor;
    self.maskLayer.mask = layer;
    
    CGFloat height = CGRectGetHeight(self.maskLayer.frame);
    CGFloat width = CGRectGetWidth(self.maskLayer.frame);
    CGRect rect = self.boundaryView.frame;
    CGRect interestRect = CGRectMake(CGRectGetMinY(rect)/height, CGRectGetMinX(rect)/width, CGRectGetHeight(rect)/height, CGRectGetWidth(rect)/width);
    [self.output setRectOfInterest:interestRect];
}

- (void)startScan {
    if (!self.session) {
        return;
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.session startRunning];
        [self updateScanLine];
        self.isScan = YES;
    });
}

- (void)stopScan {
    if (!self.session) {
        return;
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.session stopRunning];
        self.isScan = NO;
        [self updateScanLine];
    });
}

- (void)updateScanLine {
    if (!self.session) {
        return;
    }
    if (self.session.isRunning) {
        if (!self.scanLine.superview) {
            [self.boundaryView addSubview:self.scanLine];
        }
        
        [self doAnimateFrame];
        
    } else {
        [self.scanLine removeFromSuperview];
    }
}

- (void)setScanLineColor:(UIColor *)scanLineColor{
    self.scanLine.tintColor = scanLineColor;
    self.scanLine.image = [self.scanLine.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
}

- (void)doAnimateFrame{
    if (![self.scanLine.layer.animationKeys containsObject:@"AnimateFrame"]) {
        CABasicAnimation* theAnim;
        
        CGRect frame = self.boundaryView.bounds;
        frame.size.height = 4;
        self.scanLine.frame = frame;
        
        theAnim = [CABasicAnimation animationWithKeyPath:@"position"];
        theAnim.fromValue = [NSValue valueWithCGPoint:self.scanLine.layer.position];
        CGPoint newPosition = CGPointMake(self.scanLine.layer.position.x, CGRectGetHeight(self.boundaryView.bounds) - CGRectGetHeight(frame));
        theAnim.toValue = [NSValue valueWithCGPoint:newPosition];
        theAnim.duration = 1.0;
        theAnim.autoreverses = YES;
        theAnim.repeatCount = HUGE_VALF;
        [self.scanLine.layer addAnimation:theAnim forKey:@"AnimateFrame"];
    }
}

#pragma mark - AVCaptureMetadataOutputObjectsDelegate
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection {
    AVMetadataMachineReadableCodeObject *metadataObj = [metadataObjects firstObject];
    if ([metadataObj.type isEqualToString:AVMetadataObjectTypeQRCode]) {
        NSString *result = metadataObj.stringValue;
        if (result) {
            [self stopScan];
            [self.delegate scanSuccess:result];
        }
    }
    if ([metadataObj.type isEqualToString:AVMetadataObjectTypeEAN13Code] || [metadataObj.type isEqualToString:AVMetadataObjectTypeEAN8Code] || [metadataObj.type isEqualToString:AVMetadataObjectTypeUPCECode] || [metadataObj.type isEqualToString:AVMetadataObjectTypeCode39Code]|| [metadataObj.type isEqualToString:AVMetadataObjectTypeCode39Mod43Code] || [metadataObj.type isEqualToString:AVMetadataObjectTypeCode93Code] || [metadataObj.type isEqualToString:AVMetadataObjectTypeCode128Code] || [metadataObj.type isEqualToString:AVMetadataObjectTypePDF417Code]) {
        NSString *result = metadataObj.stringValue;
        if (result) {
            [self stopScan];
            [self.delegate scanSuccess:result];
        }
    }
}


@end
