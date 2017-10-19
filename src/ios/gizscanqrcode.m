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
    scanVC.scancodeCallback = ^(BOOL result, NSString *text){
        [self configScanqrcodeCallbackWithResult:result text:text];
    };
    
    if (command.arguments && command.arguments.firstObject) {
        id firstObj = command.arguments.firstObject;
        if ([firstObj isKindOfClass:[NSDictionary class]]) {
            NSDictionary *attrs = (NSDictionary *)firstObj;
            if (attrs.count) {
                scanVC.scanQrcodeAttr = command.arguments.firstObject;
            }
        }
    }
    
    [self.viewController presentViewController:scanVC animated:YES completion:nil];
}

- (void)configScanqrcodeCallbackWithResult:(BOOL)result text:(NSString *)text{
    if (result) {
        [self.commandDelegate sendPluginResult:[CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:text] callbackId:self.command.callbackId];
    } else{
        [self.commandDelegate sendPluginResult:[CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:nil] callbackId:self.command.callbackId];
    }
    
}

@end
