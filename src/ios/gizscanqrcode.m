#import "gizscanqrcode.h"
#import "ScanQrcodeVC.h"

@interface gizscanqrcode()

@property(nonatomic, strong)CDVInvokedUrlCommand *command;

@end

@implementation gizscanqrcode

- (void)scan:(CDVInvokedUrlCommand*)command{
    self.command = command;
    
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
    NSString *resultString = [NSString stringWithFormat:@"{\"resultCode\": \"%@\",\"result\": \"%@\"}", @(resultCode), result];
    if (resultCode == GizscanqrcodeResultSuccess) {
        [self.commandDelegate sendPluginResult:[CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:resultString] callbackId:self.command.callbackId];
    } else{
        [self.commandDelegate sendPluginResult:[CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:resultString] callbackId:self.command.callbackId];
    }
    
}

@end
