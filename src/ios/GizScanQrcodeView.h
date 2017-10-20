#import <UIKit/UIKit.h>

@protocol GizScanQrcodeViewDelegate <NSObject>
- (void)scanSuccess:(NSString *)text;
- (void)scanError:(NSError *)error;
@end

@interface GizScanQrcodeView : UIView
@property (weak, nonatomic) id <GizScanQrcodeViewDelegate> delegate;
@property (nonatomic) BOOL isScan;
@property(nonatomic, strong) UIColor *scanLineColor;
- (void)startScan;
- (void)stopScan;

@end
