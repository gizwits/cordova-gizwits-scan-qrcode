# gizscanqrcode

> 二维码扫描插件

## 支持平台
* iOS
* android

## 效果预览 （iOS & android）
<img src="https://raw.githubusercontent.com/wiki/gizwits/cordova-gizwits-scan-qrcode/iOS1.jpg" width=180/> <img src="https://raw.githubusercontent.com/wiki/gizwits/cordova-gizwits-scan-qrcode/android1.png" width=180/>

## 使用说明

> 1.添加插件
```
// 1.cordova目录
cd <your cordova directory>
// 2.添加 gizscanqrcode插件
cordova plugin add gizscanqrcode
// 
// 添加 gizscanqrcode插件(指定版本)
cordova plugin add gizscanqrcode@版本号
// 删除 gizscanqrcode插件
cordova plugin rm com.gizscanqrcode
```

> 2.插件使用
```
cordova.plugins.gizscanqrcode.scan(
    {
        "title": "我是标题",     //(标题文字)
        "color": "#4e8dec",      //(导航栏颜色)
        "describe": "我是提示语",//(提示用户文字)
        "statusBarColor": "white",//(状态栏字体颜色 white为白 其他为默认)
        "borderColor": "#4e8dec" //(扫描框颜色)
    },
    function (result) {
        console.log(result);//二维码数据
    },
    function (error) {
        console.log(error);//失败暂时返回空
    }
);
```









