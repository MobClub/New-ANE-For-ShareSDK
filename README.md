# New-ANE-For-ShareSDK

This is the new version and new sample of ShareSDK for ANE.

supported original ShareSDK version:

- iOS - v3.2.1 
- Android - V2.7.1


- 如需中文文档,[请看这里](http://wiki.mob.com/sharesdk-ios-for-ane/)

## Getting Start Guide(iOS)

#### Step 1 : Add ANE Component To Your Project 

#####1.Download the project New-ANE-For-ShareSDK

#####2.Add ANE component to your project
Open your Adobe Flash project with FlashBuilder,and set the properties（属性).In the window,you should choose "ActionScription building path(ActionScript构建路径)" ->"Native Extention(本机扩展)",and then add the File ShareSDK.ane from  
 ANESample/package.

![image](http://wiki.mob.com/wp-content/uploads/2015/12/1.jpg)

And then choose "ActionScription Building(ActionScript构建打包)" -> "Apple iOS" -> "Native Extention(本机扩展)", place a tick in the box.

![image](http://wiki.mob.com/wp-content/uploads/2015/12/2.jpg)

#####3.Copy ShareSDK.bundle,ShareSDKUI.bundle and other resource

Download the [ShareSDK v3.x](https://github.com/MobClub/ShareSDK3.x-for-iOS).Copy ShareSDK.bundle,ShareSDKUI.bundle(from ShareSDK) to your  YourANEProjec/src.
In addition, if your need some platform and it's SDK(such as Sina,you may need to use it's WeiboSDK),you should copy the bundle and .a file(if they exist) to YourANEProject/src .

For example, when you need Sina platform and it's SDK,you should copy libWeiboSDK.a and WeiboSDK.bundle from ShareSDK/support/PlatformSDK/SinaWeiboSDK to YourANEProject/src.

#####4.Set the URL Scheme
For the SSO login or Sharing on Wechat or QQ/QZone, you need to set URL Schemes.Open yourProject-app.xml, find the node <iPhone><InfoAdditions> and set the url scheme.

![image](http://wiki.mob.com/wp-content/uploads/2015/12/3.jpg)


#### Step 2 : Configuration Setting 

#####1. import the name space

        import cn.sharesdk.ane.PlatformID;
        import cn.sharesdk.ane.ShareSDKExtension;
        import cn.sharesdk.ane.ShareType;

#####2. creat an instance of ShareSDKExtension

        private var shareSDK:ShareSDKExtension = new ShareSDKExtension();

#####3. set the platform's configuration

i.creat a "total" Object to add the platform's object.'
ii.creat the objects to set platforms configuration
iii.call initSDK passing and appkey(you can apply for an appkey from mob.com) and call setPlatformConfig pass the total object.
iiii. set action's call back by call setPlatformActionListener 

here is the example code:

        var totalConf:Object = new Object();

        var sinaConf:SinaWeibo = new SinaWeibo();				
        sinaConf.setAppKey("568898243");
        sinaConf.setAppSecret("38a4f8204cc784f81f9f0daaf31e02e3");
        sinaConf.setRedirectUrl("http://www.sharesdk.cn");
        sinaConf.setAuthType("both");
        totalConf[PlatformID.SinaWeibo] = sinaConf.getPlatformConf();

        shareSDK.initSDK("6c7d91b85e4b");  
        shareSDK.setPlatformConfig(totalConf);
        shareSDK.setPlatformActionListener(onComplete, onError, onCancel);


#####4. set the call back Funtion

        public function onComplete(reqId:int, platform:int, action:String, res:Object):void
        {
        var json:String = (res == null ? "" : JSON.stringify(res));
        var message:String = "onComplete\nPlatform=" + platform + ", action=" + action + "\nres=" + json + "\n reqId=" + reqId;
        shareSDK.toast(message);
        }		
        public function onCancel(reqId:int, platform:int, action:String):void 
        {
        var message:String = "onCancel\nPlatform=" + platform + ", action=" + action + "\n reqId=" + reqId;
        shareSDK.toast(message);
        }		
        public function onError(reqId:int, platform:int, action:String, err:Object):void 
        {
        var json:String = (err == null ? "" : JSON.stringify(err));
        var message:String = "onError\nPlatform=" + platform + ", action=" + action + "\nres=" + json + "\n reqId=" + reqId;
        shareSDK.toast(message);
        }


#### Step 3 : Authorization and Sharing

1.Authorization

        shareSDK.authorize(PlatformID.WechatSeries);

2.Getting Userinfo

        shareSDK.getUserInfo(PlatformID.TencentWeibo);

3.Sharing

        //creat a ShareContent
        var shareParams:ShareContent = new ShareContent();
        
        //set it
        shareParams.setText("ShareSDK 3.0 for ANE Text");
        shareParams.setTitle("ShareSDK 3.0 for ANE Title");
        shareParams.setUrl("http://mob.com");
        shareParams.setImagePath("http://f1.sharesdk.cn/imgs/2014/02/26/owWpLZo_638x960.jpg");
        shareParams.setShareType(ShareType.SSDKContentTypeImage)

        //customize the ShareContent of specified platform (optional)	
        var sinaParams:ShareContent = new ShareContent();
        sinaParams.setText("SinaWeibo Text");
        var file:File = File.applicationDirectory.resolvePath("mac.jpeg");
        sinaParams.setImagePath(file.nativePath);
        sinaParams.setShareType(ShareType.SSDKContentTypeImage)
        shareParams.setShareContentCustomize(PlatformID.SinaWeibo, sinaParams);
    
        //customize the menu order(optional)
        var shareList:Array = new Array(PlatformID.SinaWeibo,PlatformID.WeChat);
        
        //share by a menu list
        shareSDK.showPlatformList(null, shareParams, 320, 460);

4.More methods please refer to our demo - ANEDemo.


#### Step 4 : Custom Your ANE Component(optional)

There is a Xcode project named ShareSDKForANE in the iOS folder in this project.Open the Xcode project,the bridge code Object-C is in the ShareSDKForANE.m.(This Xcode project and the Object-C in it depends on ShareSDK iOS V3.x.How to add ShareSDK iOS V3.x to this Xcode project,please [Check  ShareSDK3.x-for-iOS](https://github.com/MobClub/ShareSDK3.x-for-iOS))

- 1.There are some DEFINE in ShareSDKForANE.m.For some platforms you don't need ,you can comment out or delete the DEFINE.

        #define __SHARESDK_SINA_WEIBO__
        #define __SHARESDK_WECHAT__
        #define __SHARESDK_QQ__
        //#define __SHARESDK_RENREN__
        //#define __SHARESDK_YIXIN__

- 2.After modified ShareSDKForANE.m,you should build the project with with Simulator and iOS Device.In the "Bulid" folder of the project,you will find two kinds of libShareSDKForANE.a(Simulator and iOS Device).Please copy these  two libShareSDKForANE.a to ANESample/package/iPhone-ARM ,and to ANESample/package/iPhone-ARMiPhone-x86(Simulator for x86,iOS Device for ARM).

- 3.Then copy the ShareSDK folder in the xcode project to ANESample/package/iPhone-ARM ,and to ANESample/package/iPhone-ARMiPhone-x86,and delete all the bundle file and .a file in th libraries,incldude the bundle file and .a in the ShareSDK/Support/PlatformSDK (I believe that you have finished the copy work in "Step 1" - "3.Copy ShareSDK.bundle,ShareSDKUI.bundle and other resource" that copy the bundle and .a you need to the ANE project).

![image](http://wiki.mob.com/wp-content/uploads/2015/12/4.jpg)

- 4.Open ANESample/package/platformoptions.xml,you can delete some platform's framework's path you don't need.

- 5.Finally,go to ANESample/package/ with Terminal ,excute $sh ane.sh,then you will get a new ANE component for a while.

## Getting Start Guide(Android)

Coming soon ......
