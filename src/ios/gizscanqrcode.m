#import "gizscanqrcode.h"
#import "ScanQrcodeVC.h"

@interface gizscanqrcode()

@property(nonatomic, strong)CDVInvokedUrlCommand *command;

@end

@implementation gizscanqrcode

- (void)scan:(CDVInvokedUrlCommand*)command{
    self.command = command;
    
    if (![self checkCameraPermissions]){
        [self configScanqrcodeCallbackWithCode:GizscanqrcodeResultNoPermission result:@"AVAuthorizationStatusDenied or AVAuthorizationStatusRestricted"];
        return;
    }
    
    ScanQrcodeVC *scanVC = [[ScanQrcodeVC alloc] initWithNibName:@"ScanQrcodeVC" bundle:[NSBundle mainBundle]];
    // config scan code viewcontroller
    scanVC.scancodeCallback = ^(GizscanqrcodeResult resultCode, NSString *result){
        [self configScanqrcodeCallbackWithCode:resultCode result:result];
    };
    
    if (command.arguments && command.arguments.firstObject) {
        id firstObj = command.arguments.firstObject;
        if ([firstObj isKindOfClass:[NSDictionary class]]) {
            NSDictionary *attrs = (NSDictionary *)firstObj;
            NSLog(@"\n--------------------- 【gizscanqrcode parameters】 ---------------------\n%@", attrs);
            if (attrs.count) {
                scanVC.scanQrcodeAttr = command.arguments.firstObject;
            }
        }
    }
    
    [self.viewController presentViewController:scanVC animated:YES completion:nil];
}

- (void)configScanqrcodeCallbackWithCode:(GizscanqrcodeResult)resultCode result:(NSString *)result{
    NSDictionary *resultDict = @{@"resultCode": @(resultCode),
                                 @"result": result};
    NSData *resultData = [NSJSONSerialization dataWithJSONObject:resultDict options:0 error:nil];
    NSString *resultString = [[NSString alloc] initWithData:resultData encoding:NSUTF8StringEncoding];
    if (resultCode == GizscanqrcodeResultSuccess) {
        [self.commandDelegate sendPluginResult:[CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:resultString] callbackId:self.command.callbackId];
    } else{
        [self.commandDelegate sendPluginResult:[CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:resultString] callbackId:self.command.callbackId];
    }
}

- (BOOL)checkCameraPermissions{
    if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]){// 摄像头硬件是否好用
        NSString * mediaType = AVMediaTypeVideo;
        AVAuthorizationStatus  authorizationStatus = [AVCaptureDevice authorizationStatusForMediaType:mediaType];
        if (authorizationStatus == AVAuthorizationStatusRestricted|| authorizationStatus == AVAuthorizationStatusDenied) {// 用户是否允许摄像头使用
            return NO;
        }else {
            return YES;
        }
    }else {
        return NO;
    }
}

@end
