#import "GizScanQrcodeAttr.h"
#import <objc/runtime.h>

#define myColor(R, G, B, A) [UIColor colorWithRed:R/255.0 green:G/255.0 blue:B/255.0 alpha:A]

@implementation GizScanQrcodeAttr

- (instancetype)initWithDict:(NSDictionary *)dict {
    self = [super init];
    if (self) {
        [self setDefaultParameters];
        if ([dict isKindOfClass:[NSDictionary class]]) {
            [dict enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
                [self setValue:obj forKey:key];
            }];
        }
        [self setDefaultColor];
        if (self.borderScale < 0.1) {
            self.borderScale = 0.1;
        }
        if (self.borderScale > 1) {
            self.borderScale = 1;
        }
    }
    return self;
}

- (void)setDefaultParameters{
    self.title = @"扫描二维码";
    self.statusBarColor = @"white";
    self.describe = @"请扫描设备二维码";
    self.describeFontSize = 16;
    self.describeLineSpacing = 12;
    self.borderScale = 0.6;
    self.choosePhotoEnable = false;
    self.choosePhotoBtnTitle = @"从相册选择";
}

- (void)setDefaultColor{
    if (!self.baseColor) {
        self.baseColor = [self colorWithHexString:@"#4e8dec" alpha:1];
    }
    if (!self.barColor) {
        self.barColor = self.baseColor;
    }
    if (!self.borderColor) {
        self.borderColor = self.baseColor;
    }
    if (!self.choosePhotoBtnColor) {
        self.choosePhotoBtnColor = self.baseColor;
    }
    if (!self.describeColor) {
        self.describeColor = [self colorWithHexString:@"#ffffff" alpha:1];
    }
}

- (void)setValue:(id)value forKey:(NSString *)key {
    if (value == [NSNull null]) {
        return;
    }
    objc_property_t property = class_getProperty([self class], key.UTF8String);
    if (property) {
        NSString *attributes = [NSString stringWithUTF8String:property_getAttributes(property)];
        if ([attributes rangeOfString:@"T@\"NSString\""].location != NSNotFound) {
            value = [value stringObject];
        }
    }
    //color
    if ([key isEqualToString:@"barColor"] || [key isEqualToString:@"borderColor"] || [key isEqualToString:@"choosePhotoBtnColor"] || [key isEqualToString:@"describeColor"] || [key isEqualToString:@"baseColor"]) {
        value = [self colorWithHexString:value alpha:1];
    }
    [super setValue:value forKey:key];
}

- (void)setValue:(id)value forUndefinedKey:(NSString *)key {
}

#pragma mark - utils
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

@end

#pragma mark -
@implementation NSObject (Model)
- (NSDictionary *)dictionaryObject {
    if ([self isKindOfClass:[NSDictionary class]]) {
        return (NSDictionary *)self;
    }
    return nil;
}

- (NSArray *)arrayObject {
    if ([self isKindOfClass:[NSArray class]]) {
        return (NSArray *)self;
    }
    return nil;
}

- (NSString *)stringObject {
    if ([self isKindOfClass:[NSString class]]) {
        return (NSString *)self;
    } else if ([self isKindOfClass:[NSNumber class]]) {
        NSNumber *number = (NSNumber *)self;
        return number.stringValue;
    }
    return nil;
}

- (NSNumber *)numberObject {
    if ([self isKindOfClass:[NSNumber class]]) {
        return (NSNumber *)self;
    }
    return nil;
}

@end
