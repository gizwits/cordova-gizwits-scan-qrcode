#import <Foundation/Foundation.h>

@interface GizScanQrcodeAttr : NSObject

@property(nonatomic, copy)NSString *title;                  //(标题文字)
//describe string
@property(nonatomic, copy)NSString *describe;               //(提示用户文字，支持 \n 换行，多行文字需注意小屏幕设备适配问题)
@property(nonatomic, assign)CGFloat describeFontSize;       //(文字大小)
@property(nonatomic, assign)CGFloat describeLineSpacing;    //(行间距)
@property(nonatomic, strong)UIColor *describeColor;         //(文字颜色)
//border
@property(nonatomic, strong)UIColor *borderColor;           //(扫描框颜色)
@property(nonatomic, assign)CGFloat borderScale;            //(边框大小，0.1 ~ 1)
//choose photo button
@property(nonatomic, assign)BOOL choosePhotoEnable;        //(支持相册选取)
@property(nonatomic, copy)NSString *choosePhotoBtnTitle;    //(选取按钮文字)
@property(nonatomic, strong)UIColor *choosePhotoBtnColor;   //(选取按钮颜色)
//colors
@property(nonatomic, strong)UIColor *baseColor;             //(边框、按钮、导航栏等背景颜色，可单独设置)
@property(nonatomic, strong)UIColor *barColor;            //(导航栏颜色)
@property(nonatomic, copy)NSString *statusBarColor;         //(状态栏字体颜色 white为白 其他为默认)

- (instancetype)initWithDict:(NSDictionary *)dict;

@end

@interface NSObject (Model)
- (NSDictionary *)dictionaryObject;
- (NSArray *)arrayObject;
- (NSString *)stringObject;
- (NSNumber *)numberObject;
@end
