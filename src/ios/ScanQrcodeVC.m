//
//  ScanQrcodeVC.m
//  iostest
//
//  Created by Pp on 2017/10/19.
//
//

#import "ScanQrcodeVC.h"
#import "GizScanQrcodeView.h"

#define myColor(R, G, B, A) [UIColor colorWithRed:R/255.0 green:G/255.0 blue:B/255.0 alpha:A]

@interface ScanQrcodeVC ()<GizScanQrcodeViewDelegate>

@property (weak, nonatomic) IBOutlet GizScanQrcodeView *scanView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *descriptionLabel;
@property (weak, nonatomic) IBOutlet UIView *topBarView;

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
        [self.scanView startScan];
    }
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self.scanView stopScan];
}

#pragma mark -setup
- (void)configScanQRCodeView{
    self.scanView.delegate = self;
    [self.scanView startScan];
}

- (void)setSubviews{
    if (self.scanQrcodeAttr) {
        NSString *titleString = [self.scanQrcodeAttr objectForKey:@"title"];
        if (titleString) {
            self.titleLabel.text = titleString;
        }
        
        NSString *barColor = [self.scanQrcodeAttr objectForKey:@"color"];
        if (barColor && barColor.length == 6) {
            self.topBarView.backgroundColor = [self colorWithHexString:barColor alpha:1];
        }
        
        NSString *descriptionString = [self.scanQrcodeAttr objectForKey:@"describe"];
        if (descriptionString) {
            self.descriptionLabel.text = descriptionString;
        }
    }
}

#pragma mark -action
- (IBAction)backAcction:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark - GizScanQrcodeViewDelegate
- (void)scanSuccess:(NSString *)text{
    NSLog(@"扫码结果: %@", text);
    if (self.scancodeCallback) {
        self.scancodeCallback(YES, text);
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)scanError:(NSError *)error{
    NSLog(@"扫码失败: %@", error);
    if (self.scancodeCallback) {
        self.scancodeCallback(NO, @"扫码失败");
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark -others
- (UIColor *)colorWithHexString:(NSString *)hexString alpha:(CGFloat)alphaValue {
    NSString *cString = [[hexString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] uppercaseString];
    if (cString.length < 6)
        return [UIColor clearColor];
    if ([cString hasPrefix:@"0X"])
        cString = [cString substringFromIndex:2];
    if ([cString hasPrefix:@"#"])
        cString = [cString substringFromIndex:1];
    if (cString.length != 6)
        return [UIColor clearColor];
    NSRange range;
    range.location = 0;
    range.length = 2;
    NSString *rString = [cString substringWithRange:range];
    range.location = 2;
    NSString *gString = [cString substringWithRange:range];
    range.location = 4;
    NSString *bString = [cString substringWithRange:range];
    unsigned int r, g, b;
    [[NSScanner scannerWithString:rString] scanHexInt:&r];
    [[NSScanner scannerWithString:gString] scanHexInt:&g];
    [[NSScanner scannerWithString:bString] scanHexInt:&b];
    
    return myColor(r, g, b, alphaValue);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
