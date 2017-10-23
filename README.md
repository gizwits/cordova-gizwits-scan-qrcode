# gizscanqrcode

> 二维码扫描插件

## 支持平台
* iOS
* android

## 使用说明

> 1.添加插件
```
// cordova目录
cd <your cordova directory>
// 添加 gizscanqrcode插件
cordova plugin add <gizscanqrcode本地目录>
```

> 2.插件使用
```
cordova.plugins.gizscanqrcode.scan(
    {
        "title": "我是标题",     //(标题文字)
        "color": "#4e8dec",      //(导航栏颜色)
        "describe": "我是提示语",//(提示用户文字)
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









