#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, GizscanqrcodeResult) {
    GizscanqrcodeResultUnknown,
    GizscanqrcodeResultSuccess,
    GizscanqrcodeResultError,
    GizscanqrcodeResultCancel,
};

@interface ScanQrcodeVC : UIViewController

/**
 * dictionary
 *
 * key --- value
 *
 * title --- 扫描二维码
 * color --- 4e8dec
 * describe --- 请扫描设备二维码
 *
 */
@property (nonatomic, strong) NSDictionary *scanQrcodeAttr;

/**
 * scan code result block
 */
@property (nonatomic, copy) void(^scancodeCallback)(GizscanqrcodeResult resultCode, NSString *result);

@end
