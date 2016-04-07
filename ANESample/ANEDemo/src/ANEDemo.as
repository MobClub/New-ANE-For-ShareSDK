package
{
	
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.filesystem.File;
	
	import cn.sharesdk.ane.PlatformID;
	import cn.sharesdk.ane.ShareContent;
	import cn.sharesdk.ane.ShareSDKExtension;
	import cn.sharesdk.ane.platform.Facebook;
	import cn.sharesdk.ane.platform.QQ;
	import cn.sharesdk.ane.platform.QZone;
	import cn.sharesdk.ane.platform.Renren;
	import cn.sharesdk.ane.platform.SinaWeibo;
	import cn.sharesdk.ane.platform.TencentWeibo;
	import cn.sharesdk.ane.platform.Twitter;
	import cn.sharesdk.ane.platform.Wechat;
	import cn.sharesdk.ane.platform.WechatMoments;
	
	public class ANEDemo extends Sprite
	{
		
		private var shareSDK:ShareSDKExtension = new ShareSDKExtension();
		
		public function ANEDemo()
		{
			super();
			
			// 支持 autoOrient
			stage.align = StageAlign.TOP_LEFT;
			stage.scaleMode = StageScaleMode.NO_SCALE;
		
			this.addEventListener(Event.ADDED_TO_STAGE, addedToStageHandler);
				
			var totalConf:Object = new Object();
			
			var sinaConf:SinaWeibo = new SinaWeibo();				
			sinaConf.setAppKey("568898243");
			sinaConf.setAppSecret("38a4f8204cc784f81f9f0daaf31e02e3");
			sinaConf.setRedirectUrl("http://www.sharesdk.cn");
			totalConf[PlatformID.SinaWeibo] = sinaConf.getPlatformConf();
			
			var tencentConf:TencentWeibo = new TencentWeibo();
			tencentConf.setAppKey("801307650");
			tencentConf.setAppSecret("ae36f4ee3946e1cbb98d6965b0b2ff5c");
			tencentConf.setRedirectUri("http://www.sharesdk.cn");
			totalConf[PlatformID.TencentWeibo] = tencentConf.getPlatformConf();
			
			var wechatConf:Wechat = new Wechat();
			wechatConf.setAppId("wx4868b35061f87885");
			wechatConf.setAppSecret("64020361b8ec4c99936c0e3999a9f249");			
			totalConf[PlatformID.WeChat] = wechatConf.getPlatformConf();
			
			var wechatMomentsConf:WechatMoments = new WechatMoments();
			wechatMomentsConf.setAppId("wx4868b35061f87885");
			wechatMomentsConf.setAppSecret("64020361b8ec4c99936c0e3999a9f249");	
			totalConf[PlatformID.WeChatMoments] = wechatMomentsConf.getPlatformConf();
								
			var qqConf:QQ = new QQ();
			qqConf.setAppId("100371282");
			qqConf.setAppKey("aed9b0303e3ed1e27bae87c33761161d");			
			totalConf[PlatformID.QQ] = qqConf.getPlatformConf();
			
			var qzoneConf:QZone = new QZone();
			qzoneConf.setAppId("100371282");
			qzoneConf.setAppKey("aed9b0303e3ed1e27bae87c33761161d");
			totalConf[PlatformID.QZone] = qzoneConf.getPlatformConf();
			
			var renrenConf:Renren = new Renren();
			renrenConf.setAppId("226427");
			renrenConf.setApiKey("fc5b8aed373c4c27a05b712acba0f8c3");
			renrenConf.setSecretKey("f29df781abdd4f49beca5a2194676ca4");
			totalConf[PlatformID.Renren] = renrenConf.getPlatformConf();
					
			var facebookConf:Facebook = new Facebook();
			facebookConf.setConsumerKey("107704292745179");
			facebookConf.setConsumerSecret("38053202e1a5fe26c80c753071f0b573");
			totalConf[PlatformID.Facebook] = facebookConf.getPlatformConf();
			
			var twitterConf:Twitter = new Twitter();
			twitterConf.setConsumerKey("LRBM0H75rWrU9gNHvlEAA2aOy");
			twitterConf.setConsumerSecret("gbeWsZvA9ELJSdoBzJ5oLKX0TU09UOwrzdGfo9Tg7DjyGuMe8G");
			twitterConf.setCallbackUrl("http://mob.com");
			totalConf[PlatformID.Twitter] = twitterConf.getPlatformConf();
			
			shareSDK.initSDK("6c7d91b85e4b");  
			shareSDK.setPlatformConfig(totalConf);
			shareSDK.setPlatformActionListener(onComplete, onError, onCancel);
	
		}
		
		private static const BUTTON_WIDTH:Number = 300;
		private static const BUTTON_HEIGHT:Number = 60;
		
		private function addedToStageHandler(event:Event):void
		{
			
			var authBtn:Button = new Button();
			authBtn.label = "授权";
			authBtn.x = 100;
			authBtn.y = 20;
			authBtn.width = BUTTON_WIDTH;
			authBtn.height = BUTTON_HEIGHT;
			this.addChild(authBtn);
			authBtn.addEventListener(MouseEvent.CLICK, onAuthorizeHandler);
			
			var cancelAuthBtn:Button = new Button();
			cancelAuthBtn.label = "取消授权";
			cancelAuthBtn.x = 100;
			cancelAuthBtn.y = authBtn.y + authBtn.height + 10;
			cancelAuthBtn.width = BUTTON_WIDTH;
			cancelAuthBtn.height = BUTTON_HEIGHT;
			this.addChild(cancelAuthBtn);
			cancelAuthBtn.addEventListener(MouseEvent.CLICK, onCancelAuthHandler);
			
			var hasAuthBtn:Button = new Button();
			hasAuthBtn.label = "检测授权";
			hasAuthBtn.x = 100;
			hasAuthBtn.y = cancelAuthBtn.y + cancelAuthBtn.height + 10;
			hasAuthBtn.width = BUTTON_WIDTH;
			hasAuthBtn.height = BUTTON_HEIGHT;
			this.addChild(hasAuthBtn);
			hasAuthBtn.addEventListener(MouseEvent.CLICK, onIsAuthorizedHandler);
			
			var getUserInfoBtn:Button = new Button();
			getUserInfoBtn.label = "获取用户资料";
			getUserInfoBtn.x = 100;
			getUserInfoBtn.y = hasAuthBtn.y + hasAuthBtn.height + 10;
			getUserInfoBtn.width = BUTTON_WIDTH;
			getUserInfoBtn.height = BUTTON_HEIGHT;
			this.addChild(getUserInfoBtn);
			getUserInfoBtn.addEventListener(MouseEvent.CLICK, onGetUserInfoHandler);
			
			var shareBtn:Button = new Button();
			shareBtn.label = "直接分享";
			shareBtn.x = 100;
			shareBtn.y = getUserInfoBtn.y + getUserInfoBtn.height + 10;
			shareBtn.width = BUTTON_WIDTH;
			shareBtn.height = BUTTON_HEIGHT;
			this.addChild(shareBtn);
			shareBtn.addEventListener(MouseEvent.CLICK, onShareContentHandler);
						
			var shareMenuBtn:Button = new Button();
			shareMenuBtn.label = "显示分享菜单";
			shareMenuBtn.x = 100;
			shareMenuBtn.y = shareBtn.y + shareBtn.height + 10;
			shareMenuBtn.width = BUTTON_WIDTH;
			shareMenuBtn.height = BUTTON_HEIGHT;
			this.addChild(shareMenuBtn);
			shareMenuBtn.addEventListener(MouseEvent.CLICK, onShowPlatformListHandler);
			
			var shareViewBtn:Button = new Button();
			shareViewBtn.label = "显示分享编辑页";
			shareViewBtn.x = 100;
			shareViewBtn.y = shareMenuBtn.y + shareMenuBtn.height + 10;
			shareViewBtn.width = BUTTON_WIDTH;
			shareViewBtn.height = BUTTON_HEIGHT;
			this.addChild(shareViewBtn);
			shareViewBtn.addEventListener(MouseEvent.CLICK, onShowShareContentEditorHandler);
			
			var checkClientBtn:Button = new Button();
			checkClientBtn.label = "检测客户端";
			checkClientBtn.x = 100;
			checkClientBtn.y = shareViewBtn.y + shareViewBtn.height + 10;
			checkClientBtn.width = BUTTON_WIDTH;
			checkClientBtn.height = BUTTON_HEIGHT;
			this.addChild(checkClientBtn);
			checkClientBtn.addEventListener(MouseEvent.CLICK, onIsClientValidHandler);
			
			var getCredentialBtn:Button = new Button();
			getCredentialBtn.label = "获取授权信息";
			getCredentialBtn.x = 100;
			getCredentialBtn.y = checkClientBtn.y + checkClientBtn.height + 10;
			getCredentialBtn.width = BUTTON_WIDTH;
			getCredentialBtn.height = BUTTON_HEIGHT;
			this.addChild(getCredentialBtn);
			getCredentialBtn.addEventListener(MouseEvent.CLICK, onGetAuthInfoHandler);
			
			var addFriendBtn:Button = new Button();
			addFriendBtn.label = "添加好友";
			addFriendBtn.x = 100;
			addFriendBtn.y = getCredentialBtn.y + getCredentialBtn.height + 10;
			addFriendBtn.width = BUTTON_WIDTH;
			addFriendBtn.height = BUTTON_HEIGHT;
			this.addChild(addFriendBtn);
			addFriendBtn.addEventListener(MouseEvent.CLICK, onAddFriendHandler);
			
			var getFriendListBtn:Button = new Button();
			getFriendListBtn.label = "获取好友列表";
			getFriendListBtn.x = 100;
			getFriendListBtn.y = addFriendBtn.y + addFriendBtn.height + 10;
			getFriendListBtn.width = BUTTON_WIDTH;
			getFriendListBtn.height = BUTTON_HEIGHT;
			this.addChild(getFriendListBtn);
			getFriendListBtn.addEventListener(MouseEvent.CLICK, onGetFriendListHandler);
				
		}
		
		public function onComplete(reqId:int, platform:int, action:String, res:Object):void
		{
			var json:String = (res == null ? "" : JSON.stringify(res));
			var message:String = "onComplete\nPlatform=" + platform + ", action=" + action + "\nres=" + json + "\n reqId=" + reqId;
			//var message:String = "onComplete: Platform =" + platform + ", action = " + action + ", uid = " + res["uid"] + ", accessToken = " + res["access_token"];
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
		
		private function onAuthorizeHandler(event:MouseEvent):int
		{
			return shareSDK.authorize(PlatformID.SinaWeibo);
		}
		
		private function onCancelAuthHandler(event:MouseEvent):void
		{
			shareSDK.cancelAuthorize(PlatformID.SinaWeibo);
		}
		
		private function onIsAuthorizedHandler(event:MouseEvent):void
		{
			var isValid:Boolean = shareSDK.isAuthorized(PlatformID.SinaWeibo);
			shareSDK.toast("isValid = " + isValid);
		}
		
		private function onIsClientValidHandler(event:MouseEvent):void
		{
			var isInstalled:Boolean = shareSDK.isClientValid(PlatformID.WeChat);
			
			shareSDK.toast("isInstalled =" + isInstalled);
		}
		private function onGetUserInfoHandler(event:MouseEvent):int
		{
			return shareSDK.getUserInfo(PlatformID.TencentWeibo);
		}
		
		private function onShareContentHandler(event:MouseEvent):int
		{
			var shareParams:ShareContent = new ShareContent();
			shareParams.setText("这是分享的Text");
			shareParams.setTitle("ShareSDK for ANE发布");
			shareParams.setImageUrl("http://f1.sharesdk.cn/imgs/2014/02/26/owWpLZo_638x960.jpg");	
			return shareSDK.shareContent(PlatformID.SinaWeibo, shareParams);
		}
		
		private function onShowPlatformListHandler(event:MouseEvent):int
		{
			var shareParams:ShareContent = new ShareContent();
			//自定义菜单数组
			var shareList:Array = new Array(PlatformID.SinaWeibo,PlatformID.WeChat);	
			shareParams.setText("ShareSDK 3.0 for ANE Text");
			shareParams.setTitle("ShareSDK 3.0 for ANE Title");
			shareParams.setUrl("http://mob.com");
			shareParams.setImageUrl("http://f1.sharesdk.cn/imgs/2014/02/26/owWpLZo_638x960.jpg");
			
			//定制指定平台的分享内容
			var twParams:ShareContent = new ShareContent();
			twParams.setText("ANE TencentWeibo Text");
			twParams.setTitle("ANE TencentWeibo Title");
			twParams.setUrl("http://mob.com");
			
			shareParams.setShareContentCustomize(PlatformID.TencentWeibo, twParams);			
			return shareSDK.showPlatformList(null, shareParams, 320, 460);
		}
		
		private function onShowShareContentEditorHandler(event:MouseEvent):int
		{
			var shareParams:ShareContent = new ShareContent();
			shareParams.setText("ShareSDK 3.0 for ANE Text");
			shareParams.setTitle("ShareSDK 3.0 for ANE Title");
			shareParams.setUrl("http://mob.com");
			shareParams.setImageUrl("http://f1.sharesdk.cn/imgs/2014/02/26/owWpLZo_638x960.jpg");			
			
			return shareSDK.showShareContentEditor(PlatformID.SinaWeibo, shareParams);
		}	
		
		private function onGetAuthInfoHandler(event:MouseEvent):void
		{
			var authInfo:Object = shareSDK.getAuthInfo(PlatformID.SinaWeibo);
			var json:String = (authInfo == null ? "" : JSON.stringify(authInfo));
			shareSDK.toast("authInfo = " + json);
		}
		
		private function onAddFriendHandler(event:MouseEvent):int
		{
			return shareSDK.addFriend(PlatformID.TencentWeibo,"ShareSDK");
		}
		
		private function onGetFriendListHandler(event:MouseEvent):int
		{
			return shareSDK.getFriendList(PlatformID.SinaWeibo,20,1);
		}
		
	}
}