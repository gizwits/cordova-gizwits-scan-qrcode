# gizscanqrcode

> 二维码扫描插件

## 支持平台
* iOS
* android

## 效果预览
<img src="https://raw.githubusercontent.com/wiki/gizwits/cordova-gizwits-scan-qrcode/iOS_1.2.0_1.jpg" width=180/> <img src="https://raw.githubusercontent.com/wiki/gizwits/cordova-gizwits-scan-qrcode/iOS_1.2.0_2.jpg" width=180/>

## 使用说明

> 1.添加/删除插件

```
// 添加 gizscanqrcode 插件
cordova plugin add gizscanqrcode
// 添加 gizscanqrcode 插件(指定版本)
cordova plugin add gizscanqrcode@版本号
// 添加插件，同时配置iOS平台相机以及相册访问权限提示语
cordova plugin add gizscanqrcode --variable camera_usage_description=相机使用说明 --variable photo_library_usage_description=相册访问说明
```
```
// 删除 gizscanqrcode插件
cordova plugin rm gizscanqrcode
```

> 2.插件使用

```
/**
 * 参数可传空，则全部为默认，定制哪项添加哪项即可。
 * 
 * callback:
   {"resultCode": "Int",    //(0: unknown; 1: success; 2: error; 3: 用户取消扫描; 4: 摄像头不可用)
        "result": "String"
   }
 */
cordova.plugins.gizscanqrcode.scan(
    {//全部参数
     "baseColor": "#4e8dec",             //(边框、按钮、导航栏等背景颜色，优先级最低，单独设置可覆盖)

     //bar
     "title": "我是标题",                 //(标题文字)
     "barColor": "4e8dec",               //(导航栏颜色)
     "statusBarColor": "white",          //(状态栏字体颜色 white为白，不填为默认)

     //describe string
     "describe": "我是提示语",            //(提示用户文字，支持 \n 换行，多行文字需注意小屏幕设备适配问题)
     "describeFontSize": "15",          //(字体大小)
     "describeLineSpacing": "8",        //(行间距)
     "describeColor": "ffffff",         //(文字颜色)

     //scan border
     "borderColor": "4e8dec",           //(扫描框颜色)
     "borderScale": "0.6",              //(边框大小，0.1 ~ 1)

     //choose photo button
     "choosePhotoEnable": "true",       //(支持相册选取, 默认false)
     "choosePhotoBtnTitle": "相册",      //(选取按钮文字)
     "choosePhotoBtnColor": "4e8dec",   //(选取按钮颜色)

     //flashlight
     "flashlightEnable": "true"         //(支持手电筒, 默认false)
    },
    function (result) {
        console.log(result);//二维码数据
    },
    function (error) {
        console.log(error);//原因
    }
);
```







