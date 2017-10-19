//
//  YOYONScanQrcodeView.m
//  yoyon-bike-lock
//
//  Created by Pp on 2017/6/2.
//  Copyright © 2017年 Gizwits. All rights reserved.
//

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

@end

@implementation GizScanQrcodeView

- (instancetype)initWithCoder:(NSCoder *)coder
{
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
    if ([self setupCaptureSession]) {
        [self addPreviewLayer];
        [self addMaskLayer];
        
        //增加监听
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(appWillEnterForegroundNotification)
                                                     name:UIApplicationWillEnterForegroundNotification
                                                   object:nil];
    }
}

- (void)appWillEnterForegroundNotification{
    if (self.isScan) {
         [self doAnimateFrame];
    }
}

- (BOOL)setupCaptureSession {
    AVCaptureSession *session = [[AVCaptureSession alloc] init];
    
    AVCaptureDevice *captureDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    NSError *error = nil;
    AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:captureDevice error:&error];
    if (input) {
        [session addInput:input];
    }
    else {
        [self.delegate scanError:error];
        return NO;
    }
    
    AVCaptureMetadataOutput *output = [[AVCaptureMetadataOutput alloc] init];
    [session addOutput:output];
    output.metadataObjectTypes = @[AVMetadataObjectTypeQRCode];
    [output setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
    self.output = output;
    
    self.session = session;
    return YES;
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

- (void)awakeFromNib {
    [super awakeFromNib];
    [self sendSubviewToBack:self.captureView];
    self.scanLine = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"scanLine"]];
}

- (void)startScan {
    [self.session startRunning];
    [self updateScanLine];
    self.isScan = YES;
}

- (void)stopScan {
    [self.session stopRunning];
    [self updateScanLine];
    self.isScan = NO;
}

- (void)updateScanLine {
    if (self.session.isRunning) {
        if (!self.scanLine.superview) {
            [self.boundaryView addSubview:self.scanLine];
        }
        
        [self doAnimateFrame];
        
    } else {
        [self.scanLine removeFromSuperview];
    }
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
}


@end
