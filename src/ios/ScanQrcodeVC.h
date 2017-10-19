//
//  ScanQrcodeVC.h
//  iostest
//
//  Created by Pp on 2017/10/19.
//
//

#import <UIKit/UIKit.h>

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
@property (nonatomic, copy) void(^scancodeCallback)(BOOL result, NSString *text);

@end
