var exec = require('cordova/exec');

/*
arg0:
	{"title": "我是标题",     //(标题文字)
     "color": "#4e8dec",      //(导航栏颜色)
     "describe": "我是提示语",//(提示用户文字)
     "statusBarColor": "white",//(状态栏字体颜色 white为白 其他为默认)
     "borderColor": "#4e8dec" //(扫描框颜色)
    }
*/
exports.scan = function (arg0, success, error) {
    exec(success, error, 'gizscanqrcode', 'scan', [arg0]);
};
